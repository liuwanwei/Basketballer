//
//  StartMatchView.m
//  Basketballer
//
//  Created by maoyu on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StartMatchView.h"
#import "AppDelegate.h"

@implementation StartMatchView

- (id)initWithFrame:(CGRect)frame {
    NSArray * nib =[[NSBundle mainBundle] loadNibNamed:@"StartMatchView" owner:self options:nil];
    self = [nib objectAtIndex:0];
    self.frame = frame;
    return self;
}

- (IBAction)startGame:(UIButton *)sender {
    [[[AppDelegate delegate] playGameViewController] startGame];
    [self removeFromSuperview];
}

@end
