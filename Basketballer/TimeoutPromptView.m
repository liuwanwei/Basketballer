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

- (NSInteger)getTimeoutLength {
    if(_mode == PromptModeTimeout) {
        AppDelegate * delegate = [AppDelegate delegate];
        _match.timeoutCountdownSeconds = delegate.playGameViewController.selectedStatistics.timeoutLength;
    }else {
        _match.timeoutCountdownSeconds = [_match.rule restTimeLengthAfterPeriod:_match.period];        
    }
    
    if ([AppDelegate delegate].playGameViewController.testSwitch == YES) {  
        _match.timeoutCountdownSeconds = 5;
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

- (void)stopTimeoutCountdown {
    [_timeoutCountDownTimer invalidate];
}

- (void)updateTimeoutCountDown {
    [self updateTimeoutCountdownLabel:_match.timeoutCountdownSeconds];
    if(_match.timeoutCountdownSeconds  <= 0) {
        [self stopTimeoutCountdown];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTimeoutOverMessage object:nil];
        [self showAlertView];
    }
    
    _match.timeoutCountdownSeconds --;
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
    self.frame = frame;
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
    //[[[AppDelegate delegate] playGameViewController] showPlaySoundController];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [[[AppDelegate delegate] playGameViewController] startGame];
    }
}

@end
