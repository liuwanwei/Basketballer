//
//  AmateurRule.m
//  Basketballer
//
//  Created by sungeo on 14-1-13.
//
//

#import "AmateurRule.h"
#import "GameSetting.h"

@implementation AmateurRule

- (id)initWithMode:(NSString *)mode{
    if (self = [super init]) {
        self.foulLimitForTeam = 4;
        self.foulLimitForPlayer = 4;
        self.offenceTimeLimit = 24;
        
        // 半场长度定义，单位：秒。
        if ([mode isEqualToString:kMatchModeAmateur25]) {
            self.periodLength = (25 * 60);
            self.regularPeriodNumber = 2;
        }else if([mode isEqualToString:kMatchModeAmateur20]){
            self.periodLength = (20 * 60);
            self.regularPeriodNumber = 2;
        }else if([mode isEqualToString:kMatchModeAmateur15]){
            self.periodLength = (15 * 60);
            self.regularPeriodNumber = 2;
        }else if([mode isEqualToString:kMatchModeAmateurSimple15]){
            self.periodLength = (15 * 60);
            self.regularPeriodNumber = 1;
        }
    }
    
    return self;
}

// 移动到initWithMode中赋值该变量。
//- (NSInteger)regularPeriodNumber{
//    return 2;
//}

// 这个变量移动到TeamStatistics中去了。
//- (NSInteger)timeoutLength{
//    return 60;
//}

//- (NSInteger)foulLimitForTeam{
//    return 4;
//}
//
//- (NSInteger)foulLimitForPlayer{
//    return 4;
//}

//- (NSInteger)offenceTimeLimit{
//    return 24;
//}

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
    if(period == MatchPeriodFirst){
        // 中场休息时间。
        return 15 * 60;
    }else if (period == MatchPeriodSecond || period >= MatchPeriodOvertime) {
        /* 如果有加时赛的话才休息，否则比赛结束。*/
        return 2 * 60;
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
