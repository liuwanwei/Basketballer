//
//  UIImageView+Additional.m
//  Basketballer
//
//  Created by maoyu on 14-10-9.
//
//

#import "UIImageView+Additional.h"

@implementation UIImageView (Additional)

- (void)makeCircle {
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.masksToBounds = YES;
}

@end
