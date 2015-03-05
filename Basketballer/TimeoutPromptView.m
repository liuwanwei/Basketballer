//
//  TimeoutPromptView.m
//  Basketballer
//
//  Created by maoyu on 12-7-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TimeoutPromptView.h"
#import "GameSetting.h"
#import "ActionManager.h"
#import "AppDelegate.h"
#import "BaseRule.h"
#import "TeamStatistics.h"
#import "SoundManager.h"

@interface TimeoutPromptView () {
    MatchUnderWay * _match;
    NSTimer * _timeoutCountDownTimer;
}
@end

@implementation TimeoutPromptView
@synthesize mode = _mode;
@synthesize timeoutTimeLabel = _timeoutTimeLabel;
@synthesize soundEffectLabel = _soundEffectLabel;
@synthesize resumeMathButton = _resumeMathButton;
@synthesize resumeMathBgButton = _resumeMathBgButton;
@synthesize soundButton = _soundButton;
@synthesize soundBgButton = _soundBgButton;
@synthesize statePromptLabel = _statePromptLabel;

#pragma 私有函数
- (void)showAlertView{
    UIAlertView * alertView;
    alertView = [[UIAlertView alloc] 
                 initWithTitle:LocalString(@"BeginMatchPrompt") 
                 message:LocalString(@"CountdownToTheEnd") delegate:self 
                 cancelButtonTitle:LocalString(@"No")  
                 otherButtonTitles:LocalString(@"Yes")  , nil];
    [alertView show];
}

// 这个函数只调用一次，用于获取本次倒计时的起始秒数，所以应该通过init方式传过来。
- (NSInteger)getTimeoutLength {
    if(_mode == PromptModeTimeout) {
        AppDelegate * delegate = [AppDelegate delegate];
        _match.timeoutCountdownSeconds = delegate.playGameViewController.selectedStatistics.timeoutLength;
    }else {
        _match.timeoutCountdownSeconds = [_match.rule restTimeLengthAfterPeriod:_match.period];        
    }
        
    return _match.timeoutCountdownSeconds;
}

- (void)updateTimeoutCountdownLabel:(NSInteger) time{
    NSInteger minuteLeft = time / 60;
    NSInteger secondLeft = time % 60;
    NSString * timeLeftString = [NSString stringWithFormat:@"%.2d : %.2d",(int)minuteLeft, (int)secondLeft];
    self.timeoutTimeLabel.text = timeLeftString;
}

- (void)startTimeoutCountdownTimer {
    _timeoutCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeoutCountDown) userInfo:nil repeats:YES];
}

// 停止暂停计数器
- (void)stopTimeoutCountdown {
    [_timeoutCountDownTimer invalidate];
}

- (void)stopTimeout:(BOOL)prompt{
    [self stopTimeoutCountdown];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTimeoutOverMessage object:nil];
    
    if (prompt) {
        // 提示继续计时
        [self showAlertView];
    }else{
        // 不提示直接开始计时
        [[[AppDelegate delegate] playGameViewController] startGame];
    }
}

// 停止暂停
- (IBAction)stopButtonClicked:(id)sender{
    [self stopTimeout:YES];
}

- (void)updateTimeoutCountDown {
    _match.timeoutCountdownSeconds --;
    [self updateTimeoutCountdownLabel:_match.timeoutCountdownSeconds];
    if(_match.timeoutCountdownSeconds  <= 0) {
        [self stopTimeout:YES];
    }
}

#pragma 类成员函数
- (void)updateLayout {
    UIImage * playImage = [UIImage imageNamed:@"resume"];
    UIImage * timeoutImage = nil;
    [self.resumeMathButton setBackgroundImage:playImage forState:UIControlStateNormal];
    [self.statePromptLabel setText:LocalString(@"StartMatch")];
    [self.soundButton setHidden:YES];
    [self.soundButton setEnabled:NO];
    switch (_match.state) {
        case MatchStatePrepare:
            self.backgroundColor = [UIColor clearColor];
            [self.timeoutTimeLabel setHidden:YES];
            [self.statePromptLabel setText:LocalString(@"StartMatch")];
            break;
        case MatchStateTimeoutTemp:
            self.backgroundColor = [UIColor clearColor];
            break;
        case MatchStatePlaying:
            self.backgroundColor = [UIColor clearColor];
            timeoutImage = [UIImage imageNamed:@"timeout"];
            [self.resumeMathButton setBackgroundImage:timeoutImage forState:UIControlStateNormal];
            [self.resumeMathButton setEnabled:YES];
            [self.resumeMathBgButton setEnabled:YES];
            [self.statePromptLabel setText:LocalString(@"Pause")];
            break;
        case MatchStatePeriodFinished:
            self.backgroundColor = [UIColor clearColor];
            [self.timeoutTimeLabel setHidden:YES];
            [self.resumeMathButton setHidden:NO];
            [self.resumeMathButton setEnabled:YES];
            [self.resumeMathBgButton setEnabled:YES];
            [self.statePromptLabel setHidden:NO];
            break;
        case MatchStateQuarterTime:
        case MatchStateTimeout:
            [self.timeoutTimeLabel setHidden:NO];
            [self.resumeMathButton setHidden:YES];
            [self.statePromptLabel setHidden:YES];
            [self.resumeMathButton setEnabled:NO];
            [self.resumeMathBgButton setEnabled:NO];
            [self.soundButton setHidden:YES];
            [self.soundButton setEnabled:NO];
            [self.soundBgButton setEnabled:NO];
            [self.soundEffectLabel setHidden:YES];
            break;
        case MatchStateTimeoutFinished:
        case MatchStateQuarterTimeFinished:
            self.backgroundColor = [UIColor clearColor];
            [self.resumeMathButton setHidden:NO];
            [self.resumeMathButton setEnabled:YES];
            [self.resumeMathBgButton setEnabled:YES];
            [self.statePromptLabel setHidden:NO];
            [self.soundButton setHidden:YES];
            [self.soundButton setEnabled:NO];
            [self.soundBgButton setEnabled:YES];
            [self.soundEffectLabel setHidden:NO];
            [self.timeoutTimeLabel setHidden:YES];
            break;
        default:
            break;
    }
}


#pragma 事件函数
- (id)initWithFrame:(CGRect)frame {
    NSArray * nib =[[NSBundle mainBundle] loadNibNamed:@"TimeoutPromptView" owner:self options:nil];
    self = [nib objectAtIndex:0];
//    self.frame = frame;
    _match = [MatchUnderWay defaultMatch];
    
    self.soundEffectLabel.text = LocalString(@"SoundEffect");
    
    return self;
}

- (void)startTimeoutCountdown {
    [self updateTimeoutCountdownLabel:[self getTimeoutLength]];
    [self startTimeoutCountdownTimer];
}

- (IBAction)resumeGame:(UIButton *)sender {
    switch (_match.state) {
        case MatchStatePeriodFinished:
            _match.state = MatchStateQuarterTime;
            [self updateLayout];
            [self startTimeoutCountdown];
            break;
        case MatchStatePlaying:
            [[[AppDelegate delegate] playGameViewController] pauseCountdownTime];
            break;
        default:
            [[[AppDelegate delegate] playGameViewController] startGame];
            break;
    }
}

- (IBAction)showPlaySoundView:(id)sender {
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [[[AppDelegate delegate] playGameViewController] startGame];
    }
}

@end
