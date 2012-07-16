//
//  TimeoutPromptViewController.m
//  Basketballer
//
//  Created by lixiaoyu on 12-7-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TimeoutPromptViewController.h"
#import "GameSetting.h"

@interface TimeoutPromptViewController ()

@end

@implementation TimeoutPromptViewController
@synthesize timeoutTargetTime = _timeoutTargetTime;
@synthesize timeoutCountDownTimer = _timeoutCountDownTimer;
@synthesize timeoutTimeLabel = _timeoutTimeLabel;
@synthesize parentController = _parentController;
@synthesize mode = _mode;

#pragma 私有函数
- (NSInteger)getTimeoutLength {
    NSInteger timeoutLength = 0;
    if(_mode == timeoutMode) {
        timeoutLength = [[GameSetting defaultSetting].timeoutLength intValue];
    }else {
        if (self.parentController.gameMode == kGameModeTwoHalf) {
            timeoutLength = 1;
            //timeoutLength = [[GameSetting defaultSetting].halfTimeLength intValue];
        }else {
            if (self.parentController.curPeroid == 0 || self.parentController.curPeroid == 2) {
                timeoutLength = [[GameSetting defaultSetting].quarterTimeLength intValue];
            }else {
                timeoutLength = [[GameSetting defaultSetting].halfTimeLength intValue];
            }
        }
    }

    return timeoutLength;
}

- (void)initTimeoutDownLable {
    self.timeoutTimeLabel.font = [UIFont fontWithName:@"DB LCD Temp" size:70.0f];
    if (_mode == timeoutMode) {
        self.timeoutTimeLabel.text = [NSString stringWithFormat:@"%.2d : %.2d",0,[self getTimeoutLength]];
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
    if (_mode == timeoutMode) {
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
    self.timeoutTimeLabel.text = [NSString stringWithFormat:@"%.2d : %.2d",minute,second];
    if(minute <= 0 && second <= 0) {
        [self stopTimeoutCountDown];
    }
    
}

- (id)initWithFrame:(CGRect)frame {
    NSArray * nib =[[NSBundle mainBundle] loadNibNamed:@"TimeoutPromptViewController" owner:self options:nil];
    self = [nib objectAtIndex:0];
    self.frame = frame;
    
    return self;
}

- (void)startTimeout {
    [self initTimeoutTargetTime];
    [self initTimeoutDownLable];
    [self startTimeoutCountDown];
}

- (IBAction)resumeGame:(id)sender {
    [self stopTimeoutCountDown];
    [self.parentController startGame:nil];
    [self removeFromSuperview];
   }

@end
