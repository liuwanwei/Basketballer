//
//  TimeStopPromptView.m
//  Basketballer
//
//  Created by maoyu on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TimeStopPromptView.h"

@implementation TimeStopPromptView
@synthesize parentController = _parentController;

- (id)initWithFrame:(CGRect)frame {
    NSArray * nib =[[NSBundle mainBundle] loadNibNamed:@"TimeStopPromptView" owner:self options:nil];
    self = [nib objectAtIndex:0];
    self.frame = frame;
    return self;
}

- (IBAction)resumeGame:(id)sender {
    [self.parentController startGame:nil];
    [self removeFromSuperview];
}

@end
