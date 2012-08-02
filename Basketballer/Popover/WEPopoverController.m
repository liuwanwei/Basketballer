//
//  WEPopoverController.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverController.h"
#import "WEPopoverParentView.h"
#import "UIBarButtonItem+WEPopover.h"

#define FADE_DURATION 0.25


@interface WEPopoverController()
@property (nonatomic, assign, readwrite) UIView *view;
@property (nonatomic, assign, readwrite, getter=isPopoverVisible) BOOL popoverVisible;
@property (nonatomic, assign, readwrite) UIPopoverArrowDirection popoverArrowDirection;

- (UIView *)keyView;
- (void)updateBackgroundPassthroughViews;
- (void)setView:(UIView *)v;
- (CGRect)displayAreaForView:(UIView *)theView;
- (WEPopoverContainerViewProperties *)defaultContainerViewProperties;
- (void)dismissPopoverAnimated:(BOOL)animated userInitiated:(BOOL)userInitiated;

@end

@implementation WEPopoverController
{
	WETouchableView *backgroundView;
}
@synthesize contentViewController;
@synthesize popoverContentSize;
@synthesize popoverVisible;
@synthesize popoverArrowDirection;
@synthesize delegate;
@synthesize view;
@synthesize containerViewProperties;
@synthesize context;
@synthesize passthroughViews;

- (id)init {
	if ((self = [super init])) {
	}
	return self;
}

- (id)initWithContentViewController:(UIViewController *)viewController {
	if ((self = [self init])) {
		self.contentViewController = viewController;
	}
	return self;
}

- (void)dealloc {
	[self dismissPopoverAnimated:NO];
}

- (void)setContentViewController:(UIViewController *)vc {
	if (vc != contentViewController) {
		contentViewController = vc;
		popoverContentSize = CGSizeZero;
	}
}

//Overridden setter to copy the passthroughViews to the background view if it exists already
- (void)setPassthroughViews:(NSArray *)array {
	if (array) {
		passthroughViews = [[NSArray alloc] initWithArray:array];
	} else {
		passthroughViews = nil;
	}
	[self updateBackgroundPassthroughViews];
}

- (void)wepAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)theContext {
	
	if ([animationID isEqual:@"FadeIn"]) {
		self.view.userInteractionEnabled = YES;
		popoverVisible = YES;
		[contentViewController viewDidAppear:YES];
	} else {
		popoverVisible = NO;
		[contentViewController viewDidDisappear:YES];
		[self.view removeFromSuperview];
		self.view = nil;
		[backgroundView removeFromSuperview];
		backgroundView = nil;
		
		NSNumber *num = (__bridge_transfer NSNumber *)theContext;
		BOOL userInitiatedDismissal = [num boolValue];
		
		if (userInitiatedDismissal) {
			//Only send message to delegate in case the user initiated this event, which is if he touched outside the view
			[delegate popoverControllerDidDismissPopover:self];
		}
	}
}

- (void)dismissPopoverAnimated:(BOOL)animated {
	
	[self dismissPopoverAnimated:animated userInitiated:NO];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item 
			   permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
							   animated:(BOOL)animated {
	
	UIView *v = [self keyView];
	CGRect rect = [item frameInView:v];
	
	return [self presentPopoverFromRect:rect inView:v permittedArrowDirections:arrowDirections animated:animated];
}

- (void)presentPopoverFromRect:(CGRect)rect 
						inView:(UIView *)theView 
	  permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
					  animated:(BOOL)animated {
	
	
	[self dismissPopoverAnimated:NO];
	
	//First force a load view for the contentViewController so the popoverContentSize is properly initialized
	[contentViewController view];
	
	if (CGSizeEqualToSize(popoverContentSize, CGSizeZero)) {
		popoverContentSize = contentViewController.contentSizeForViewInPopover;
	}
	
	CGRect displayArea = [self displayAreaForView:theView];
	
	WEPopoverContainerViewProperties *props = self.containerViewProperties ? self.containerViewProperties : [self defaultContainerViewProperties];
	WEPopoverContainerView *containerView = [[WEPopoverContainerView alloc] initWithSize:self.popoverContentSize anchorRect:rect displayArea:displayArea permittedArrowDirections:arrowDirections properties:props];
	popoverArrowDirection = containerView.arrowDirection;
	
	UIView *keyView = self.keyView;
	
	backgroundView = [[WETouchableView alloc] initWithFrame:keyView.bounds];
	backgroundView.contentMode = UIViewContentModeScaleToFill;
	backgroundView.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin |
									   UIViewAutoresizingFlexibleWidth |
									   UIViewAutoresizingFlexibleRightMargin |
									   UIViewAutoresizingFlexibleTopMargin |
									   UIViewAutoresizingFlexibleHeight |
									   UIViewAutoresizingFlexibleBottomMargin);
	backgroundView.backgroundColor = [UIColor clearColor];
	backgroundView.delegate = self;
	
	[keyView addSubview:backgroundView];
	
	containerView.frame = [theView convertRect:containerView.frame toView:backgroundView];
	
	[backgroundView addSubview:containerView];
	
	containerView.contentView = contentViewController.view;
	containerView.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin |
									  UIViewAutoresizingFlexibleRightMargin);
	
	self.view = containerView;
	[self updateBackgroundPassthroughViews];
	
	[contentViewController viewWillAppear:animated];
	
	[self.view becomeFirstResponder];
	
	if (animated) {
		self.view.alpha = 0.0;
		
		[UIView beginAnimations:@"FadeIn" context:nil];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(wepAnimationDidStop:finished:context:)];
		[UIView setAnimationDuration:FADE_DURATION];
		
		self.view.alpha = 1.0;
		
		[UIView commitAnimations];
	} else {
		popoverVisible = YES;
		[contentViewController viewDidAppear:animated];
	}	
}

- (void)repositionPopoverFromRect:(CGRect)rect
						   inView:(UIView *)theView
		 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections {
	
	CGRect displayArea = [self displayAreaForView:theView];
	WEPopoverContainerView *containerView = (WEPopoverContainerView *)self.view;
	[containerView updatePositionWithAnchorRect:rect
									displayArea:displayArea
					   permittedArrowDirections:arrowDirections];
	
	popoverArrowDirection = containerView.arrowDirection;
	containerView.frame = [theView convertRect:containerView.frame toView:backgroundView];
}

#pragma mark -
#pragma mark WETouchableViewDelegate implementation

- (void)viewWasTouched:(WETouchableView *)view {
	if (popoverVisible) {
		if (!delegate || [delegate popoverControllerShouldDismissPopover:self]) {
			[self dismissPopoverAnimated:YES userInitiated:YES];
		}
	}
}

- (UIView *)keyView {
	UIWindow *w = [[UIApplication sharedApplication] keyWindow];
	return w;
#if 0 // DFH - this caused me some grief, no idea why it was added
	if (w.subviews.count > 0) {
		return [w.subviews objectAtIndex:0];
	} else {
		return w;
	}
#endif
}

- (void)setView:(UIView *)v {
	if (view != v) {
		view = v;
	}
}

- (void)updateBackgroundPassthroughViews {
	backgroundView.passthroughViews = passthroughViews;
}


- (void)dismissPopoverAnimated:(BOOL)animated userInitiated:(BOOL)userInitiated {
	if (self.view) {
		[contentViewController viewWillDisappear:animated];
		popoverVisible = NO;
		[self.view resignFirstResponder];
		if (animated) {
			
			self.view.userInteractionEnabled = NO;
			[UIView beginAnimations:@"FadeOut" context:(__bridge_retained void *)[NSNumber numberWithBool:userInitiated]];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(wepAnimationDidStop:finished:context:)];
			
			[UIView setAnimationDuration:FADE_DURATION];
			
			self.view.alpha = 0.0;
			
			[UIView commitAnimations];
		} else {
			[contentViewController viewDidDisappear:animated];
			[self.view removeFromSuperview];
			self.view = nil;
			[backgroundView removeFromSuperview];
			backgroundView = nil;
		}
	}
}

- (CGRect)displayAreaForView:(UIView *)theView {
	CGRect displayArea = CGRectZero;
	if ([theView conformsToProtocol:@protocol(WEPopoverParentView)] && [theView respondsToSelector:@selector(displayAreaForPopover)]) {
		displayArea = [(id <WEPopoverParentView>)theView displayAreaForPopover];
	} else {
		displayArea = [[[UIApplication sharedApplication] keyWindow] convertRect:[[UIScreen mainScreen] applicationFrame] toView:theView];
	}
	return displayArea;
}

//Enable to use the simple popover style
- (WEPopoverContainerViewProperties *)defaultContainerViewProperties {
	WEPopoverContainerViewProperties *ret = [WEPopoverContainerViewProperties new];
	
	CGFloat bgMargin = 6.0;
	CGFloat contentMargin = 2.0;
	
	ret.leftBgMargin = bgMargin;
	ret.rightBgMargin = bgMargin;
	ret.topBgMargin = bgMargin;
	ret.bottomBgMargin = bgMargin;
	ret.leftContentMargin = contentMargin;
	ret.rightContentMargin = contentMargin;
	ret.topContentMargin = contentMargin;
	ret.bottomContentMargin = contentMargin;
#ifdef DRAW_IMAGES
	{
		popupSpec spec;
		spec.topColor = [[UIColor greenColor] CGColor];
		spec.botColor = [[UIColor blueColor] CGColor];
		spec.lineColor = [[UIColor redColor] CGColor];
		spec.size = CGSizeMake(64, 32);
		spec.radius = 6;
		spec.borderWidth = 2.0f;
		spec.calloutHeight = 10.0f;
		spec.calloutRatio = 0.75f;
		spec.direction = UIPopoverArrowDirectionDown;
		ret.spec = spec;
	}
#else	
	CGSize imageSize = CGSizeMake(30.0f, 30.0f);
	NSString *bgImageName = @"popoverBgSimple.png";

	ret.leftBgCapSize = (NSInteger)imageSize.width/2;
	ret.topBgCapSize = (NSInteger)imageSize.height/2;
	ret.bgImageName = bgImageName;
	ret.arrowMargin = 1.0;
	ret.upArrowImageName = @"popoverArrowUpSimple.png";
	ret.downArrowImageName = @"popoverArrowDownSimple.png";
	ret.leftArrowImageName = @"popoverArrowLeftSimple.png";
	ret.rightArrowImageName = @"popoverArrowRightSimple.png";
#endif
	return ret;
}

@end
