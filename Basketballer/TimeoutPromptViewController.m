//
//  TimeoutPromptViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TimeoutPromptViewController.h"
#import "GameSetting.h"
#import "ActionManager.h"
#import "AppDelegate.h"

@interface TimeoutPromptViewController ()

@end

@implementation TimeoutPromptViewController
@synthesize timeoutTargetTime = _timeoutTargetTime;
@synthesize timeoutCountDownTimer = _timeoutCountDownTimer;
@synthesize timeoutTimeLabel = _timeoutTimeLabel;
@synthesize mode = _mode;
@synthesize resumeMathButton = _resumeMathButton;
@synthesize stopTimeOutButton = _stopTimeOutButton;
@synthesize promptLabel = _promptLabel;

#pragma 私有函数
- (void)showAlertView:(NSString *)message withCancel:(BOOL)cancel{
    UIAlertView * alertView;
    if(cancel == YES) {
        alertView = [[UIAlertView alloc] initWithTitle:@"确认" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定" , nil];
    }else {
        alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定" , nil];
    }
    [alertView show];
}

- (NSInteger)getTimeoutLength {
    NSInteger timeoutLength = 0;
    if(_mode == PromptModeTimeout) {
        timeoutLength = [[GameSetting defaultSetting].timeoutLength intValue];
    }else {
        if ([[AppDelegate delegate].playGameViewController.gameMode isEqualToString: kGameModeTwoHalf]) {
            timeoutLength = [[GameSetting defaultSetting].halfTimeLength intValue];
        }else {
            NSInteger currentPeriod = [[ActionManager defaultManager] period];
            if (currentPeriod == 0 || currentPeriod == 2) {
                timeoutLength = [[GameSetting defaultSetting].quarterTimeLength intValue];
            }else {
                timeoutLength = [[GameSetting defaultSetting].halfTimeLength intValue];
            }
        }
    }

    return timeoutLength;
}

- (void)initTimeoutDownLable {
    if (_mode == PromptModeTimeout) {
        self.timeoutTimeLabel.text = [NSString stringWithFormat:@"%.2d",[self getTimeoutLength]];
    }else {
        self.timeoutTimeLabel.text = [NSString stringWithFormat:@"%.2d : %.2d",[self getTimeoutLength],0];
    }
}

/*初始化暂停结束时间*/
- (void)initTimeoutTargetTime {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    if (_mode == PromptModeTimeout) {
        [comps setSecond:comps.second + [self getTimeoutLength] + 1];
    }else {
        [comps setMinute:comps.minute + [self getTimeoutLength]];
        [comps setSecond:comps.second + 1];
    }
  
    self.timeoutTargetTime = [calendar dateFromComponents:comps];//把目标时间装载入date
}

- (void)startTimeoutCountDown {
    self.timeoutCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeoutCountDown) userInfo:nil repeats:YES];
}

- (void)stopTimeoutCountDown {
    [self.timeoutCountDownTimer invalidate];
}

- (void)updateTimeoutCountDown {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //用来得到具体的时差
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date toDate:self.timeoutTargetTime options:0];
    NSInteger minute = [comps minute];
    NSInteger second = [comps second];
    if(minute < 0) {
        minute = 0;
    }
    if(second < 0) {
        second = 0;
    }
    if (_mode == PromptModeTimeout) {
        if(minute > 0) {
            self.timeoutTimeLabel.text = [NSString stringWithFormat:@"%.2d : %.2d",minute,second];
        }else {
            self.timeoutTimeLabel.text = [NSString stringWithFormat:@"%.2d",second]; 
        }
        
    }else {
         self.timeoutTimeLabel.text = [NSString stringWithFormat:@"%.2d : %.2d",minute,second];
    }
   
    if(minute <= 0 && second <= 0) {
        [self.stopTimeOutButton setHidden:YES];
        [self.resumeMathButton setHidden:NO];
        [self.timeoutTimeLabel setHidden:YES];
        [self stopTimeoutCountDown];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTimeoutOverMessage object:nil];
    }
    
}

- (id)initWithFrame:(CGRect)frame {
    NSArray * nib =[[NSBundle mainBundle] loadNibNamed:@"TimeoutPromptViewController" owner:self options:nil];
    self = [nib objectAtIndex:0];
    self.frame = frame;
    [self.resumeMathButton setHidden:YES];
    [self.stopTimeOutButton setHidden:YES];
    return self;
}

- (void)startTimeout {
    [self initTimeoutTargetTime];
    [self initTimeoutDownLable];
    [self startTimeoutCountDown];
}

- (IBAction)resumeGame:(UIButton *)sender {
    if (sender.tag == 1) {
        [self showAlertView:@"您要继续比赛吗？" withCancel:YES];
    }else {
        [self stopTimeoutCountDown];
        //[self.parentController startGame:nil];
        [self removeFromSuperview];
    }
}

#pragma alert delete
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
/*    if (buttonIndex == 1) {
        [self stopTimeoutCountDown];
        [self.parentController startGame:nil];
        [self removeFromSuperview];
    }*/
}

@end
