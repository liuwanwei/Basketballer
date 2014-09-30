//
//  NbaRule.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NbaRule.h"
#import "ActionManager.h"

@interface NbaRule(){
}

@end

@implementation NbaRule

- (NSInteger)regularPeriodNumber{
    return 4;
}

- (NSInteger)foulLimitForTeam{
    return 4;
}

- (NSInteger)foulLimitForPlayer{
    return 5;
}

- (NSInteger)offenceTimeLimit{
    return 24;
}

// 每个周期有多长时间，单位（秒）。
- (NSInteger)timeLengthForPeriod:(MatchPeriod)period{
    if (period >= MatchPeriodFirst && period <= MatchPeriodFourth) {
        return 12 * 60;
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
        return 130;
    }else if(period == MatchPeriodSecond){
        return 15 * 60;
    }else{
        return 0;
    }
}

// 每个周期开始前，判断是否要清零暂停数据。
- (BOOL)isTimeoutExpiredBeforePeriod:(MatchPeriod)period{
//    if (type == ActionTypeTimeoutShort) {
//        return [self shouldClearShortTimeoutBeforePeriod:period];
//    }else if(type == ActionTypeTimeoutRegular){
//        return [self shouldClearRegularTimeoutBeforePeriod:period];
//    }else{
//        return NO;
//    }
    return NO;
}

- (BOOL)shouldClearShortTimeoutBeforePeriod:(MatchPeriod)period{
    if (period == MatchPeriodThird) {
        // 下半场开始时，上半场的短暂停作废。
        return YES;
    }else{
        return NO;
    }
}
- (BOOL)shouldClearRegularTimeoutBeforePeriod:(MatchPeriod)period{
    if (period >= MatchPeriodOvertime) {
        // 加时赛开始时，常规时间内的暂停作废。
        return YES;
    }else{
        return NO;
    }
}

// 在一个周期结束之前，一共允许多少次暂停。
- (NSInteger)timeoutLimitForType:(ActionType)type beforeEndOfPeriod:(MatchPeriod)period{
    if (type == ActionTypeTimeoutRegular) {
        if (period == MatchPeriodFirst || period == MatchPeriodSecond) {
            return 6;
        }else if(period == MatchPeriodThird || period == MatchPeriodFourth){
            return 6;
        }else if(period >= MatchPeriodOvertime){
            return 3;
        }
    }else if(type == ActionTypeTimeoutShort){
        return 1;
    }
    
    return UnlimitNumber;
}


@end
