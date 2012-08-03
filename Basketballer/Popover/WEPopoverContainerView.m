//
//  WEPopoverContainerViewProperties.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WEPopoverContainerView.h"

@interface WEPopoverContainerViewProperties ()

#ifdef DRAW_IMAGES
+ (UIImage *)popupBox:(popupSpec *)specP;
#endif

@end

@interface WEPopoverContainerView()

- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;
- (CGRect)contentRect;
- (CGSize)contentSize;
- (void)setProperties:(WEPopoverContainerViewProperties *)props;
- (void)initFrame;

@end

@implementation WEPopoverContainerView
{
	UIImage *bgImage;
	
	WEPopoverContainerViewProperties *properties;
#ifndef DRAW_IMAGES		
	UIImage *arrowImage;
	CGRect arrowRect;
	CGPoint arrowOffset;
#endif
	CGRect bgRect;
	CGPoint offset;
	
	CGSize correctedSize;
}
@synthesize arrowDirection, contentView;

- (id)initWithSize:(CGSize)theSize 
		anchorRect:(CGRect)anchorRect 
	   displayArea:(CGRect)displayArea
permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
		properties:(WEPopoverContainerViewProperties *)theProperties {
	if ((self = [super initWithFrame:CGRectZero])) {
		
		[self setProperties:theProperties];
		correctedSize = CGSizeMake(theSize.width + properties.leftBgMargin + properties.rightBgMargin + properties.leftContentMargin + properties.rightContentMargin, 
								   theSize.height + properties.topBgMargin + properties.bottomBgMargin + properties.topContentMargin + properties.bottomContentMargin);	
		[self determineGeometryForSize:correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
		[self initFrame];
		self.backgroundColor = [UIColor clearColor];

#ifdef DRAW_IMAGES
		{
			popupSpec ps = properties.spec;
			ps.direction = arrowDirection;
			ps.size = bgRect.size;
			bgImage = [WEPopoverContainerViewProperties popupBox:&ps];
			properties.spec = ps;
		}
#else
		UIImage *theImage = [UIImage imageNamed:properties.bgImageName];
		bgImage = [theImage stretchableImageWithLeftCapWidth:properties.leftBgCapSize topCapHeight:properties.topBgCapSize];
#endif		
		//self.clipsToBounds = NO;	// DFH - cannot get layer shadows if set to NO
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[bgImage drawInRect:bgRect blendMode:kCGBlendModeNormal alpha:1.0];
#ifndef DRAW_IMAGES
	[arrowImage drawInRect:arrowRect blendMode:kCGBlendModeNormal alpha:1.0]; 
#endif
}

- (void)updatePositionWithAnchorRect:(CGRect)anchorRect 
						 displayArea:(CGRect)displayArea
			permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections {
	[self determineGeometryForSize:correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
	[self initFrame];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	return CGRectContainsPoint(self.contentRect, point);	
} 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)setContentView:(UIView *)v {
	if (v != contentView) {
		[contentView removeFromSuperview]; // DFH - old bug
		contentView = v;		
		contentView.frame = self.contentRect;		
		[self addSubview:contentView];
	}
}

- (void)initFrame {
#ifdef DRAW_IMAGES
	CGRect theFrame = CGRectOffset(bgRect, offset.x, offset.y);
#else	
	CGRect theFrame = CGRectOffset(CGRectUnion(bgRect, arrowRect), offset.x, offset.y);
	
	//If arrow rect origin is < 0 the frame above is extended to include it so we should offset the other rects
	arrowOffset = CGPointMake(MAX(0, -arrowRect.origin.x), MAX(0, -arrowRect.origin.y));
	bgRect = CGRectOffset(bgRect, arrowOffset.x, arrowOffset.y);
	arrowRect = CGRectOffset(arrowRect, arrowOffset.x, arrowOffset.y);
#endif	
	self.frame = CGRectIntegral(theFrame); 
}																		 

- (CGSize)contentSize {
	return self.contentRect.size;
}

- (CGRect)contentRect {
#ifdef DRAW_IMAGES
	CGRect r = properties.spec.contentRect;

	CGRect rect = CGRectMake(r.origin.x + properties.leftBgMargin + properties.leftContentMargin, 
							 r.origin.y + properties.topBgMargin + properties.topContentMargin, 
							 r.size.width - properties.leftBgMargin - properties.rightBgMargin - properties.leftContentMargin - properties.rightContentMargin,
							 r.size.height - properties.topBgMargin - properties.bottomBgMargin - properties.topContentMargin - properties.bottomContentMargin);
#else
	CGRect rect = CGRectMake(properties.leftBgMargin + properties.leftContentMargin + arrowOffset.x, 
							 properties.topBgMargin + properties.topContentMargin + arrowOffset.y, 
							 bgRect.size.width - properties.leftBgMargin - properties.rightBgMargin - properties.leftContentMargin - properties.rightContentMargin,
							 bgRect.size.height - properties.topBgMargin - properties.bottomBgMargin - properties.topContentMargin - properties.bottomContentMargin);
#endif
	return rect;
}

- (void)setProperties:(WEPopoverContainerViewProperties *)props {
	if (properties != props) {
		properties = props;
	}
}

#ifdef DRAW_IMAGES
- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections {	

	//NSLog(@"COMING IN: size=%@ anchorRect=%@ displayArea=%@", NSStringFromCGSize(theSize), NSStringFromCGRect(anchorRect), NSStringFromCGRect(displayArea) );
	
	//Determine the frame, it should not go outside the display area
	UIPopoverArrowDirection theArrowDirection = UIPopoverArrowDirectionUp;
	
	offset =  CGPointZero;
	bgRect = CGRectZero;
	arrowDirection = UIPopoverArrowDirectionUnknown;
	
	CGFloat biggestSurface = 0.0f;
	CGFloat currentMinMargin = 0.0f;

	while (theArrowDirection <= UIPopoverArrowDirectionRight) {
		
		if (!(supportedArrowDirections & theArrowDirection)) {
			theArrowDirection <<= 1;
			continue;
		}

		CGRect theBgRect = CGRectZero;
		CGPoint theOffset = CGPointZero;
		CGFloat xArrowOffset = 0;
		CGFloat yArrowOffset = 0;
		CGPoint anchorPoint = CGPointZero;
		CGFloat addedWidth = 0;
		CGFloat addedHeight = 0;
		CGFloat padding  = properties.spec.calloutHeight;

			
		switch (theArrowDirection) {
		case UIPopoverArrowDirectionUp:
			
			anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMaxY(anchorRect));
			
			xArrowOffset = theSize.width / 2;
						
			addedHeight = padding;
			break;
		case UIPopoverArrowDirectionDown:
			
			anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMinY(anchorRect));
			
			xArrowOffset = theSize.width / 2;
			yArrowOffset = theSize.height + padding;
						
			addedHeight = padding;
			break;
		case UIPopoverArrowDirectionLeft:
			
			anchorPoint = CGPointMake(CGRectGetMaxX(anchorRect), CGRectGetMidY(anchorRect));
			
			yArrowOffset = theSize.height / 2;
						
			addedWidth = padding;
			break;
		case UIPopoverArrowDirectionRight:
			
			anchorPoint = CGPointMake(CGRectGetMinX(anchorRect), CGRectGetMidY(anchorRect));
			
			xArrowOffset = theSize.width + padding;
			yArrowOffset = theSize.height / 2;
			
			addedWidth = padding;
			break;
		}

		theOffset = CGPointMake(anchorPoint.x - xArrowOffset, anchorPoint.y - yArrowOffset);
		if (theOffset.x < 0) {
			theOffset.x = 0;
		} else if (theOffset.x + theSize.width > displayArea.size.width) {
			theOffset.x = displayArea.size.width - theSize.width;
		}
		if (theOffset.y < displayArea.origin.y) {
			theOffset.y = displayArea.origin.y;
		} else if ((theOffset.y + theSize.height + addedHeight) > (displayArea.size.height + displayArea.origin.y)) {
			// display has a negative y offset due to way this is created
			theOffset.y = displayArea.size.height + displayArea.origin.y - theSize.height - addedHeight;
		}

		theBgRect = CGRectMake(0, 0, theSize.width+addedWidth, theSize.height+addedHeight);
		
		CGRect bgFrame = CGRectOffset(theBgRect, theOffset.x, theOffset.y);

		CGFloat minMarginLeft = CGRectGetMinX(bgFrame) - CGRectGetMinX(displayArea);
		CGFloat minMarginRight = CGRectGetMaxX(displayArea) - CGRectGetMaxX(bgFrame); 
		CGFloat minMarginTop = CGRectGetMinY(bgFrame) - CGRectGetMinY(displayArea); 
		CGFloat minMarginBottom = CGRectGetMaxY(displayArea) - CGRectGetMaxY(bgFrame); 

// Don't change the rect size - causes drawing problems		
		if (minMarginLeft < 0) {
			// Popover is too wide and clipped on the left; decrease width
			// and move it to the right
//			theOffset.x -= minMarginLeft;
//			theBgRect.size.width += minMarginLeft;
			minMarginLeft = 0;
		}
		if (minMarginRight < 0) {
			// Popover is too wide and clipped on the right; decrease width.
//			theBgRect.size.width += minMarginRight;
			minMarginRight = 0;
		}
		if (minMarginTop < 0) {
			// Popover is too high and clipped at the top; decrease height
			// and move it down
//			theOffset.y -= minMarginTop;
//			theBgRect.size.height += minMarginTop;
			minMarginTop = 0;
		}
		if (minMarginBottom < 0) {
			// Popover is too high and clipped at the bottom; decrease height.
//			theBgRect.size.height += minMarginBottom;
			minMarginBottom = 0;
		}
		bgFrame = CGRectOffset(theBgRect, theOffset.x, theOffset.y);
		
		CGFloat minMargin = MIN(minMarginLeft, minMarginRight);
		minMargin = MIN(minMargin, minMarginTop);
		minMargin = MIN(minMargin, minMarginBottom);
		
		// Calculate intersection and surface
		CGRect intersection = CGRectIntersection(displayArea, bgFrame);
		CGFloat surface = intersection.size.width * intersection.size.height;
		
		if (surface >= biggestSurface && minMargin >= currentMinMargin) {
			biggestSurface = surface;
			offset = theOffset;
			bgRect = theBgRect;
			arrowDirection = theArrowDirection;
			currentMinMargin = minMargin;
		}
	
		theArrowDirection <<= 1;
	}

	if(properties.useLayerShadows) {
		// self.clipsToBounds = NO; // does not work - for some reason has to be set at init time

		CALayer *layer = self.layer;
		layer.shadowRadius = 5;
		layer.shadowOpacity = 1.0f;
		layer.shadowOffset = CGSizeMake(0, 3);
		//layer.masksToBounds = NO;
	} else {
		self.clipsToBounds = NO;
	}
	
	//NSLog(@"LEAVING: bgRect=%@, correctedSize=%@ offset=%@", NSStringFromCGRect(bgRect), NSStringFromCGSize(correctedSize), NSStringFromCGPoint(offset) );
}
#else
- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections {	
	
	//Determine the frame, it should not go outside the display area
	UIPopoverArrowDirection theArrowDirection = UIPopoverArrowDirectionUp;
	
	offset =  CGPointZero;
	bgRect = CGRectZero;
	arrowRect = CGRectZero;
	arrowDirection = UIPopoverArrowDirectionUnknown;
	
	CGFloat biggestSurface = 0.0f;
	CGFloat currentMinMargin = 0.0f;
	
	UIImage *upArrowImage = [UIImage imageNamed:properties.upArrowImageName];
	UIImage *downArrowImage = [UIImage imageNamed:properties.downArrowImageName];
	UIImage *leftArrowImage = [UIImage imageNamed:properties.leftArrowImageName];
	UIImage *rightArrowImage = [UIImage imageNamed:properties.rightArrowImageName];
	
	while (theArrowDirection <= UIPopoverArrowDirectionRight) {
		
		if ((supportedArrowDirections & theArrowDirection)) {
			
			CGRect theBgRect = CGRectZero;
			CGRect theArrowRect = CGRectZero;
			CGPoint theOffset = CGPointZero;
			CGFloat xArrowOffset = 0.0;
			CGFloat yArrowOffset = 0.0;
			CGPoint anchorPoint = CGPointZero;
			
			switch (theArrowDirection) {
				case UIPopoverArrowDirectionUp:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMaxY(anchorRect));
					
					xArrowOffset = theSize.width / 2 - upArrowImage.size.width / 2;
					yArrowOffset = properties.topBgMargin - upArrowImage.size.height;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - upArrowImage.size.width / 2, anchorPoint.y  - yArrowOffset);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.x < 0) {
						xArrowOffset += theOffset.x;
						theOffset.x = 0;
					} else if (theOffset.x + theSize.width > displayArea.size.width) {
						xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
						theOffset.x = displayArea.size.width - theSize.width;
					}
					
					//Cap the arrow offset
					xArrowOffset = MAX(xArrowOffset, properties.leftBgMargin + properties.arrowMargin);
					xArrowOffset = MIN(xArrowOffset, theSize.width - properties.rightBgMargin - properties.arrowMargin - upArrowImage.size.width);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, upArrowImage.size.width, upArrowImage.size.height);
					
					break;
				case UIPopoverArrowDirectionDown:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMinY(anchorRect));
					
					xArrowOffset = theSize.width / 2 - downArrowImage.size.width / 2;
					yArrowOffset = theSize.height - properties.bottomBgMargin;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - downArrowImage.size.width / 2, anchorPoint.y - yArrowOffset - downArrowImage.size.height);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.x < 0) {
						xArrowOffset += theOffset.x;
						theOffset.x = 0;
					} else if (theOffset.x + theSize.width > displayArea.size.width) {
						xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
						theOffset.x = displayArea.size.width - theSize.width;
					}
					//Cap the arrow offset
					xArrowOffset = MAX(xArrowOffset, properties.leftBgMargin + properties.arrowMargin);
					xArrowOffset = MIN(xArrowOffset, theSize.width - properties.rightBgMargin - properties.arrowMargin - downArrowImage.size.width);
					
					theArrowRect = CGRectMake(xArrowOffset , yArrowOffset - properties.arrowOffset, downArrowImage.size.width, downArrowImage.size.height);
					
					break;
				case UIPopoverArrowDirectionLeft:
					
					anchorPoint = CGPointMake(CGRectGetMaxX(anchorRect), CGRectGetMidY(anchorRect));
					
					xArrowOffset = properties.leftBgMargin - leftArrowImage.size.width;
					yArrowOffset = theSize.height / 2  - leftArrowImage.size.height / 2;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset, anchorPoint.y - yArrowOffset - leftArrowImage.size.height / 2);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
									
					if (theOffset.y < 0) {
						yArrowOffset += theOffset.y;
						theOffset.y = 0;
					} else if (theOffset.y + theSize.height > displayArea.size.height) {
						yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
						theOffset.y = displayArea.size.height - theSize.height;
					}
					
					//Cap the arrow offset
					yArrowOffset = MAX(yArrowOffset, properties.topBgMargin + properties.arrowMargin);
					yArrowOffset = MIN(yArrowOffset, theSize.height - properties.bottomBgMargin - properties.arrowMargin - leftArrowImage.size.height);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, leftArrowImage.size.width, leftArrowImage.size.height);
					
					break;
				case UIPopoverArrowDirectionRight:
					
					anchorPoint = CGPointMake(CGRectGetMinX(anchorRect), CGRectGetMidY(anchorRect));
					
					xArrowOffset = theSize.width - properties.rightBgMargin;
					yArrowOffset = theSize.height / 2  - rightArrowImage.size.width / 2;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - rightArrowImage.size.width, anchorPoint.y - yArrowOffset - rightArrowImage.size.height / 2);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.y < 0) {
						yArrowOffset += theOffset.y;
						theOffset.y = 0;
					} else if (theOffset.y + theSize.height > displayArea.size.height) {
						yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
						theOffset.y = displayArea.size.height - theSize.height;
					}
					
					//Cap the arrow offset
					yArrowOffset = MAX(yArrowOffset, properties.topBgMargin + properties.arrowMargin);
					yArrowOffset = MIN(yArrowOffset, theSize.height - properties.bottomBgMargin - properties.arrowMargin - rightArrowImage.size.height);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, rightArrowImage.size.width, rightArrowImage.size.height);
					
					break;
			}
			
			CGRect bgFrame = CGRectOffset(theBgRect, theOffset.x, theOffset.y);
			
			CGFloat minMarginLeft = CGRectGetMinX(bgFrame) - CGRectGetMinX(displayArea);
			CGFloat minMarginRight = CGRectGetMaxX(displayArea) - CGRectGetMaxX(bgFrame); 
			CGFloat minMarginTop = CGRectGetMinY(bgFrame) - CGRectGetMinY(displayArea); 
			CGFloat minMarginBottom = CGRectGetMaxY(displayArea) - CGRectGetMaxY(bgFrame); 
							
			if (minMarginLeft < 0) {
			    // Popover is too wide and clipped on the left; decrease width
			    // and move it to the right
			    theOffset.x -= minMarginLeft;
			    theBgRect.size.width += minMarginLeft;
			    minMarginLeft = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionRight) {
			        theArrowRect.origin.x = CGRectGetMaxX(theBgRect) - properties.rightBgMargin;
			    }
			}
			if (minMarginRight < 0) {
			    // Popover is too wide and clipped on the right; decrease width.
			    theBgRect.size.width += minMarginRight;
			    minMarginRight = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionLeft) {
			        theArrowRect.origin.x = CGRectGetMinX(theBgRect) - leftArrowImage.size.width + properties.leftBgMargin;
			    }
			}
			if (minMarginTop < 0) {
			    // Popover is too high and clipped at the top; decrease height
			    // and move it down
			    theOffset.y -= minMarginTop;
			    theBgRect.size.height += minMarginTop;
			    minMarginTop = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionDown) {
			        theArrowRect.origin.y = CGRectGetMaxY(theBgRect) - properties.bottomBgMargin;
			    }
			}
			if (minMarginBottom < 0) {
			    // Popover is too high and clipped at the bottom; decrease height.
			    theBgRect.size.height += minMarginBottom;
			    minMarginBottom = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionUp) {
			        theArrowRect.origin.y = CGRectGetMinY(theBgRect) - upArrowImage.size.height + properties.topBgMargin;
			    }
			}
			bgFrame = CGRectOffset(theBgRect, theOffset.x, theOffset.y);
            
			CGFloat minMargin = MIN(minMarginLeft, minMarginRight);
			minMargin = MIN(minMargin, minMarginTop);
			minMargin = MIN(minMargin, minMarginBottom);
			
			// Calculate intersection and surface
			CGRect intersection = CGRectIntersection(displayArea, bgFrame);
			CGFloat surface = intersection.size.width * intersection.size.height;
			
			if (surface >= biggestSurface && minMargin >= currentMinMargin) {
				biggestSurface = surface;
				offset = theOffset;
				arrowRect = theArrowRect;
				bgRect = theBgRect;
				arrowDirection = theArrowDirection;
				currentMinMargin = minMargin;
			}
		}
		
		theArrowDirection <<= 1;
	}
	
	switch (arrowDirection) {
		case UIPopoverArrowDirectionUp:
			arrowImage = upArrowImage;
			break;
		case UIPopoverArrowDirectionDown:
			arrowImage = downArrowImage;
			break;
		case UIPopoverArrowDirectionLeft:
			arrowImage = leftArrowImage;
			break;
		case UIPopoverArrowDirectionRight:
			arrowImage = rightArrowImage;
			break;
	}
	
	if(properties.useLayerShadows) {
		// self.clipsToBounds = NO; // does not work - for some reason has to be set at init time

		CALayer *layer = self.layer;
		layer.shadowRadius = 5;
		layer.shadowOpacity = 1.0f;
		layer.shadowOffset = CGSizeMake(0, 3);
		//layer.masksToBounds = NO;
	} else {
		self.clipsToBounds = NO;
	}
}
#endif
@end



@implementation WEPopoverContainerViewProperties
#ifdef DRAW_IMAGES
@synthesize spec;
#else
@synthesize bgImageName, upArrowImageName, downArrowImageName, leftArrowImageName, rightArrowImageName;
@synthesize arrowMargin, arrowOffset;
@synthesize topBgCapSize, leftBgCapSize;
#endif
@synthesize topBgMargin, bottomBgMargin, leftBgMargin, rightBgMargin;
@synthesize leftContentMargin, rightContentMargin, topContentMargin, bottomContentMargin, useLayerShadows;

#ifdef DRAW_IMAGES
// Size is the bounding box
+ (UIImage *)popupBox:(popupSpec *)specP
{
	popupSpec spec = *specP;
	
	assert((2*spec.radius+spec.borderWidth) < spec.size.width && (2*spec.radius+spec.borderWidth) < spec.size.height);

	if(!isnormal(spec.calloutRatio)) spec.calloutRatio = 0.75f;

	CGFloat margin = spec.borderWidth/2;
	
	CGRect rrect;
	rrect.origin = CGPointMake(0,0);
	rrect.size = CGSizeMake(spec.size.width+spec.borderWidth, spec.size.height+spec.borderWidth);
	CGSize imageSize = rrect.size;

	switch(spec.direction) {
	case UIPopoverArrowDirectionLeft:
		rrect.origin.x += spec.calloutHeight;
	case UIPopoverArrowDirectionRight:
		rrect.size.width -= spec.calloutHeight;
		break;
	case UIPopoverArrowDirectionUp:
		rrect.origin.y += spec.calloutHeight;
	case UIPopoverArrowDirectionDown:
		rrect.size.height -= spec.calloutHeight;
		break;
	}
	{
		CGRect contentFrame;
		contentFrame.origin = rrect.origin;
		contentFrame.size = spec.size;
		// get inside the border
		contentFrame = CGRectInset(contentFrame, spec.borderWidth, spec.borderWidth);
		// We now have the location to place the content into
		specP->contentRect = CGRectIntegral(rrect);
		NSLog(@"CONTENT_RECT: %@", NSStringFromCGRect(specP->contentRect));
	}
	// inset so we have enough room to draw the border
	rrect = CGRectInset(rrect, margin, margin);
	

NSLog(@"IMAGE_SIZE=%@ RRECT=%@", NSStringFromCGSize(imageSize), NSStringFromCGRect(rrect));
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Apple Code found on Internet		
	// Drawing with a white stroke color 
	CGContextSetStrokeColorWithColor(context, spec.lineColor); 
	// NOTE: At this point you may want to verify that your radius is no more than half 
	// the width and height of your rectangle, as this technique degenerates for those cases. 

	// In order to draw a rounded rectangle, we will take advantage of the fact that 
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc 
	// in order to create the path from the current position and the destination position. 

	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions 
	// on the x and y lengths of the given rectangle. 
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect); 
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect); 

	// Next, we will go around the rectangle in the order given by the figure below. 
	//       minx    midx    maxx 
	// miny    2       3       4 
	// midy    1       9       5 
	// maxy    8       7       6 
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't 
	// form a closed path, so we still need to close the path to connect the ends correctly. 
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows. 
	// You could use a similar technique to create any shape with rounded corners. 

	CGFloat baseAdjust = spec.calloutHeight*spec.calloutRatio;

	// Start at 1 
	CGContextMoveToPoint(context, minx, midy+baseAdjust); 
	if(spec.direction == UIPopoverArrowDirectionLeft) {
		CGContextAddLineToPoint(context, margin, midy);
		CGContextAddLineToPoint(context, minx, midy-baseAdjust);
	}
	// Add an arc through 2 to 3 
	CGContextAddArcToPoint(context, minx, miny, midx-baseAdjust, miny, spec.radius);
	if(spec.direction == UIPopoverArrowDirectionUp) {
		CGContextAddLineToPoint(context, midx-baseAdjust, miny);
		CGContextAddLineToPoint(context, midx, margin);
		CGContextAddLineToPoint(context, midx+baseAdjust, miny);
	}
	// Add an arc through 4 to 5 
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy-baseAdjust, spec.radius); 
	
	if(spec.direction == UIPopoverArrowDirectionRight) {
		CGContextAddLineToPoint(context, maxx, midy-baseAdjust);
		CGContextAddLineToPoint(context, imageSize.width-margin, midy);
		CGContextAddLineToPoint(context, maxx, midy+baseAdjust);
	}
	// Add an arc through 6 to 7 
	CGContextAddArcToPoint(context, maxx, maxy, midx+baseAdjust, maxy, spec.radius); 

	if(spec.direction == UIPopoverArrowDirectionDown) {
		CGContextAddLineToPoint(context, midx+baseAdjust, maxy);
		CGContextAddLineToPoint(context, midx, imageSize.height-margin);
		CGContextAddLineToPoint(context, midx-baseAdjust, maxy);
	}
	// Add an arc through 8 to 9 
	CGContextAddArcToPoint(context, minx, maxy, minx, midy+baseAdjust, spec.radius);
	//CGContextAddLineToPoint(context, maxx, midy-baseAdjust);

	// Close the path 
	CGContextClosePath(context);

	CGPathRef path = CGContextCopyPath(context);
	

	// Fill the path 
	{
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextSaveGState(context);

		CGContextClip(context);
		const void *colors[2] = { spec.topColor, spec.botColor };
		CFArrayRef colorArray = CFArrayCreate(NULL, colors, 2, &kCFTypeArrayCallBacks);
		const CGFloat locations[2] = { 0, 1 };
		CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorArray, locations);
		CFRelease(colorArray);
		CGContextDrawLinearGradient(context, gradient, CGPointMake(midx, miny), CGPointMake(midx, maxy), kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

		CGGradientRelease(gradient);
		CGColorSpaceRelease(colorSpace);

		CGContextRestoreGState(context);
	}
	
	CGContextAddPath(context, path);
	CGPathRelease(path);

	CGContextSetStrokeColorWithColor(context, spec.lineColor);
	CGContextSetLineWidth(context, spec.borderWidth);
	CGContextDrawPath(context, kCGPathStroke);

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}
#endif

@end

