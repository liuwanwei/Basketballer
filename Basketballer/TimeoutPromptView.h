//
//  TimeoutPromptViewController.h
//  Basketballer
//
//  Created by lixiaoyu on 12-7-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchUnderWay.h"
#import "PlayGameViewController.h"

#define TimeoutPromptViewTimeOver           @"TimeoutPromptViewTimeOver"
#define TimeoutPromptViewStartGame          @"TimeoutPromptViewStartGame"
#define TimeoutPromptViewPauseGame          @"TimeoutPromptViewPauseGame"

typedef enum{
    PromptModeTimeout       = 0,      // 暂停
    PromptModeQuarterTime   = 1,      // 节间休息，包括半场休息
}PromptMode;

@interface TimeoutPromptView : UIView<UIAlertViewDelegate>

@property (nonatomic) NSInteger mode;
@property (nonatomic, weak) IBOutlet UILabel * timeoutTimeLabel;
//@property (nonatomic, weak) IBOutlet UILabel * statePromptLabel;
//@property (nonatomic, weak) IBOutlet UILabel * soundEffectLabel;
//@property (nonatomic, weak) IBOutlet UIButton * resumeMathButton;
//@property (nonatomic, weak) IBOutlet UIButton * resumeMathBgButton;
//@property (nonatomic, weak) IBOutlet UIButton * soundButton;
//@property (nonatomic ,weak) IBOutlet UIButton * soundBgButton;

- (IBAction)resumeGame:(id)sender;
- (IBAction)showPlaySoundView:(id)sender;

- (void)startTimeoutCountdown;
- (void)stopTimeoutCountdown;
- (void)updateLayout;

@end
