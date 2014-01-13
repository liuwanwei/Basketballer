//
//  AmateurRule.m
//  Basketballer
//
//  Created by sungeo on 14-1-13.
//
//

#import "AmateurRule.h"
#import "GameSetting.h"

// 半场长度定义，单位：秒。
typedef enum {
    AmateurPeriodLength25 = (25 * 60),
    AmateurPeriodLength20 = (20 * 60),
    AmateurPeriodLength15 = (15 * 60)
}AmateurPeriodLength;

@implementation AmateurRule

- (NSInteger)periodLengthForMode:(NSString *)mode{
    if ([mode isEqualToString:kMatchModeAmateur25]) {
        return (25 * 60);
    }else if([mode isEqualToString:kMatchModeAmateur20]){
        return (20 * 60);
    }else if([mode isEqualToString:kMatchModeAmateur15]){
        return (15 * 60);
    }else if([mode isEqualToString:kMatchModeAmateurSimple15]){
        return (15 * 60);
    }else{
        return 0;
    }
}

- (id)initWithMode:(NSString *)mode{
    if (self = [super init]) {
        self.periodLength = [self periodLengthForMode:mode];
    }
    
    return self;
}

- (NSInteger)regularPeriodNumber{
    return 2;
}

- (NSInteger)timeoutLength{
    return 60;
}

- (NSInteger)foulLimitForTeam{
    return 4;
}

- (NSInteger)foulLimitForPlayer{
    return 4;
}

- (NSInteger)offenceTimeLimit{
    return 24;
}

// 每个周期有多长时间，单位（秒）。
- (NSInteger)timeLengthForPeriod:(MatchPeriod)period{
    if (period >= MatchPeriodFirst && period <= MatchPeriodSecond) {
        return self.periodLength;
    }else if(period >= MatchPeriodOvertime){
        return 5 * 60;
    }else{
        return 0;
    }
}

// 每个周期结束后休息多久。
- (NSInteger)restTimeLengthAfterPeriod:(MatchPeriod)period{
    if (period == MatchPeriodFirst ||
        period == MatchPeriodThird ||
        period == MatchPeriodFourth || /* 如果有加时赛的话才休息，否则比赛结束。*/
        period >= MatchPeriodOvertime) {
        return 2 * 60;
    }else if(period == MatchPeriodSecond){
        return 15 * 60;
    }else{
        return 0;
    }
}

// 每个周期开始前，判断是否要清零暂停数据。
- (BOOL)isTimeoutExpiredBeforePeriod:(MatchPeriod)period{
    if (period == MatchPeriodThird || period >= MatchPeriodOvertime) {
        return YES;
    }
    
    return NO;
}

// 在一个周期结束之前，一共允许多少次暂停。
- (NSInteger)timeoutLimitBeforeEndOfPeriod:(MatchPeriod)period{
    if (period == MatchPeriodFirst || period == MatchPeriodSecond) {
        return 2;
    }else if(period == MatchPeriodThird || period == MatchPeriodFourth){
        return 3;
    }else if(period >= MatchPeriodOvertime){
        return 1;
    }else{
        return 0;
    }
}

@end
