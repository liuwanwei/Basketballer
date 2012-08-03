//
//  WEPopoverContainerView.h
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

/**
 * @brief Properties for the container view determining the area where the actual content view can/may be displayed. Also Images can be supplied for the arrow images and background.
 */
 
 typedef struct {
	CGColorRef topColor;
	CGColorRef botColor;
	CGColorRef lineColor;
	CGSize size;		// image size
	CGRect contentRect;	// returned parameter after image is drawn
	CGFloat radius;
	CGFloat borderWidth;
	CGFloat calloutHeight;
	CGFloat calloutRatio;		// width of base relative to height - default to 0.75f
	UIPopoverArrowDirection direction;
} popupSpec;

@interface WEPopoverContainerViewProperties : NSObject
#ifndef DRAW_IMAGES
@property(nonatomic, strong) NSString *bgImageName;
@property(nonatomic, strong) NSString *upArrowImageName;
@property(nonatomic, strong) NSString *downArrowImageName;
@property(nonatomic, strong) NSString *leftArrowImageName;
@property(nonatomic, strong) NSString *rightArrowImageName;
#endif
@property(nonatomic, assign) CGFloat leftBgMargin;
@property(nonatomic, assign) CGFloat rightBgMargin;
@property(nonatomic, assign) CGFloat topBgMargin;
@property(nonatomic, assign) CGFloat bottomBgMargin;
@property(nonatomic, assign) CGFloat leftContentMargin;
@property(nonatomic, assign) CGFloat rightContentMargin;
@property(nonatomic, assign) CGFloat topContentMargin;
@property(nonatomic, assign) CGFloat bottomContentMargin;
#ifndef DRAW_IMAGES
@property(nonatomic, assign) NSInteger topBgCapSize;
@property(nonatomic, assign) NSInteger leftBgCapSize;
@property(nonatomic, assign) CGFloat arrowMargin;
@property(nonatomic, assign) CGFloat arrowOffset;
#endif
@property(nonatomic, assign) BOOL useLayerShadows;

#ifdef DRAW_IMAGES
@property(nonatomic, assign) popupSpec spec;
#endif

@end

@class WEPopoverContainerView;

/**
 * @brief Container/background view for displaying a popover view.
 */
@interface WEPopoverContainerView : UIView
/**
 * @brief The current arrow direction for the popover.
 */
@property (nonatomic, readonly) UIPopoverArrowDirection arrowDirection;

/**
 * @brief The content view being displayed.
 */
@property (nonatomic, strong) UIView *contentView;

/**
 * @brief Initializes the position of the popover with a size, anchor rect, display area and permitted arrow directions and optionally the properties. 
 * If the last is not supplied the defaults are taken (requires images to be present in bundle representing a black rounded background with partial transparency).
 */
- (id)initWithSize:(CGSize)theSize 
		anchorRect:(CGRect)anchorRect 
	   displayArea:(CGRect)displayArea
permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
		properties:(WEPopoverContainerViewProperties *)properties;	

/**
 * @brief To update the position of the popover with a new anchor rect, display area and permitted arrow directions
 */
- (void)updatePositionWithAnchorRect:(CGRect)anchorRect 
						 displayArea:(CGRect)displayArea
			permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;	

@end
