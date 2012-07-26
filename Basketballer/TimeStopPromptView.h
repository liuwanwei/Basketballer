//
//  TimeStopPromptView.h
//  Basketballer
//
//  Created by maoyu on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayGameViewController.h"

@interface TimeStopPromptView : UIView

@property (nonatomic, weak) PlayGameViewController * parentController;

- (IBAction)resumeGame:(id)sender;
@end
