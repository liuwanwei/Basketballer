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
        // 暂停时间长度
        AppDelegate * delegate = [AppDelegate delegate];
        _match.timeoutCountdownSeconds = delegate.playGameViewController.selectedStatistics.timeoutLength;
    }else {
        // 节间休息时间长度
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
    [[NSNotificationCenter defaultCenter] postNotificationName:TimeoutPromptViewTimeOver object:nil];
    
    if (prompt) {
        // 提示继续计时
        [self showAlertView];
    }else{
        // 不提示直接开始计时
        [self postMessage:TimeoutPromptViewStartGame];
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
    switch (_match.state) {
        case MatchStatePrepare:
            self.backgroundColor = [UIColor clearColor];
            [self.timeoutTimeLabel setHidden:YES];
            break;
        case MatchStateTimeoutTemp:
            self.backgroundColor = [UIColor clearColor];
            break;
        case MatchStatePlaying:
            self.backgroundColor = [UIColor clearColor];
            break;
        case MatchStatePeriodFinished:
            self.backgroundColor = [UIColor clearColor];
            [self.timeoutTimeLabel setHidden:YES];
            break;
        case MatchStateQuarterRestTime:
        case MatchStateTimeout:
            [self.timeoutTimeLabel setHidden:NO];
            break;
        case MatchStateTimeoutFinished:
        case MatchStateQuarterRestTimeFinished:
            self.backgroundColor = [UIColor clearColor];
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
    _match = [MatchUnderWay defaultMatch];
    
    return self;
}

- (void)startTimeoutCountdown {
    [self updateTimeoutCountdownLabel:[self getTimeoutLength]];
    [self startTimeoutCountdownTimer];
}

- (IBAction)resumeGame:(UIButton *)sender {
    switch (_match.state) {
        case MatchStatePeriodFinished:
            _match.state = MatchStateQuarterRestTime;
            [self updateLayout];
            [self startTimeoutCountdown];
            break;
        case MatchStatePlaying:
            [self postMessage:TimeoutPromptViewPauseGame];
            break;
        default:
            [self postMessage:TimeoutPromptViewStartGame];
            break;
    }
}

- (IBAction)showPlaySoundView:(id)sender {
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self postMessage:TimeoutPromptViewStartGame];
    }
}

- (void)postMessage:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:message object:self];
}

@end
