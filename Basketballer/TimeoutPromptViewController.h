//
//  TimeoutPromptViewController.h
//  Basketballer
//
//  Created by lixiaoyu on 12-7-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayGameViewController.h"

enum PromptMode {
    timeoutMode = 0,
    restMode = 1
    };

@interface TimeoutPromptViewController : UIView

@property (nonatomic, strong) NSDate * timeoutTargetTime;
@property (nonatomic, weak) NSTimer * timeoutCountDownTimer;
@property (nonatomic, weak) IBOutlet UILabel * timeoutTimeLabel;
@property (nonatomic, weak) PlayGameViewController * parentController;
@property (nonatomic) NSInteger mode;

- (IBAction)resumeGame:(id)sender;

- (void)startTimeout;

@end
