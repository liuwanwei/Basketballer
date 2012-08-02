//
//  TimeoutPromptViewController.h
//  Basketballer
//
//  Created by lixiaoyu on 12-7-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayGameViewController.h"

#define kTimeoutOverMessage @"kTimeoutOver"

typedef enum{
    PromptModeTimeout = 0,
    PromptModeRest = 1
}PromptMode;

@interface TimeoutPromptViewController : UIView<UIAlertViewDelegate>

@property (nonatomic, strong) NSDate * timeoutTargetTime;
@property (nonatomic, weak) NSTimer * timeoutCountDownTimer;
@property (nonatomic, weak) IBOutlet UILabel * timeoutTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel * promptLabel;
@property (nonatomic, weak) PlayGameViewController * parentController;
@property (nonatomic) NSInteger mode;
@property (nonatomic, weak) IBOutlet UIButton * resumeMathButton;
@property (nonatomic, weak) IBOutlet UIButton * stopTimeOutButton;

- (IBAction)resumeGame:(id)sender;
- (void)startTimeout;

@end
