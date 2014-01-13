//
//  NbaTeamStatistics.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NbaTeamStatistics.h"

static BOOL sCheckFirstMandatoryTimeout;
static BOOL sCheckSecondMandatoryTimeout;

@interface NbaTeamStatistics(){
    MatchPeriod _periodForRegularTimeout;
}

@end

@implementation NbaTeamStatistics

// TODO 这个名字好恶心。
+ (void)initCheck{
    sCheckFirstMandatoryTimeout = NO;
    sCheckSecondMandatoryTimeout = NO;
}

// TODO 加到基类是最好的，这样可以自动清零过期犯规、球队犯规。
// 检查是否需要自动暂停（官方、强制）每一秒钟都要检查一次，需要暂停时，返回暂停类型。记分员要给教练（或裁判）示意。
+ (TimeoutType)checkAutoTimeout:(MatchPeriod)period atTime:(NSInteger)time{    
    // 每个周期开始前，初始化标志位。    
    if(time == 9 * 60){
        // 8分59秒到5分59秒是个时间段，从8分59秒开始检查第一次强制暂停。
        sCheckFirstMandatoryTimeout = YES;
    }else if(time == 6 * 60){
        // 5分59秒到2分59秒是个时间段，从5分59秒开始检查第二次强制暂停。
        sCheckSecondMandatoryTimeout = YES;
    }
    
    if (time == 9 * 60 && (period == MatchPeriodSecond || period == MatchPeriodFourth)) {
        ActionManager * am = [ActionManager defaultManager];
        if (0 == [am.home timeoutCountInPeriod:period] &&
            0 == [am.guest timeoutCountInPeriod:period]) {
            // 9分时没有一个队叫过暂停，自动在下一次死球时叫“官方暂停”。
            return ActionTypeTimeoutOfficial;
        }
    }else if(time == 6 * 60 && sCheckFirstMandatoryTimeout) {
        return ActionTypeTimeoutRegular; // TODO 主队客队轮着来，先主后客。
        // TODO 调用者下来要主动调用addRegularTimeoutInPeriod。
    }else if(time == 3 * 60 && sCheckSecondMandatoryTimeout){
        return ActionTypeTimeoutRegular;
    }
    
    return ActionTypeNone;
}


- (BOOL)addStatistic:(ActionType)actionType inPeriod:(MatchPeriod)period atTime:(NSInteger)time{
    if ([super isTimeoutAction:actionType]) {
        return [self addTimeout:actionType inPeriod:period atTime:time];
    }else{
        return [super addStatistic:actionType inPeriod:period atTime:time];
    }
}

// 判断一个时间是否属于“决胜期”。
- (BOOL)isEndingPeriod:(MatchPeriod)period atTime:(NSInteger)time{
    if (period == MatchPeriodFourth || 
        period >= MatchPeriodOvertime) {
        if (time < 60 * 2) {
            return YES;
        }
    }
    
    return NO;
}

// 某个周期允许暂停次数。
- (NSInteger)timeoutLimitInPeriod:(MatchPeriod)period{
    if (period == MatchPeriodFourth) {
        return 3;
    }else{
        return TimeoutLimitNone;
    }
}

// 决胜期内允许暂停最大次数。
- (NSInteger)timeoutLimitInPeriodEndingTime:(MatchPeriod)period{
    if (period == MatchPeriodFourth ||
        period >= MatchPeriodOvertime) {
        return 2;
    }else{
        return TimeoutLimitNone;
    }
}

- (NSInteger)timeoutCountInEndingPeriod:(MatchPeriod)period{
    // TODO 计算该决胜期内的所有暂停次数。
    return 0;
}

- (NSInteger)timeoutCountInPeriod:(MatchPeriod)period{
    // 计算在该周期内的所有暂停次数。
    NSInteger count = 0;
    for (Action * action in self.timeoutActionArray) {
        if ([self isTimeoutAction:[action.type integerValue]]) {
            count ++;
        }
    }
    return count;
}

// 判断暂停总次数是否达到允许的最大值。
- (BOOL)isBeyondTimeoutLimitInPeriod:(MatchPeriod)period atTime:(NSInteger)time{
    NSInteger timeoutCount;
    if ([self isEndingPeriod:period atTime:time]) {
        timeoutCount = [self timeoutCountInEndingPeriod:period];
        if (timeoutCount >= [self timeoutLimitInPeriodEndingTime:period]) {
            return YES;  // TODO 跟下面的YES应该能区分开。
        }
    }
    
    timeoutCount = [self timeoutCountInPeriod:period];
    if (timeoutCount >= [self timeoutLimitInPeriod:period]) {
        return YES;
    }
    
    return NO;
}

// 添加一个短暂停。以上都是为这个短暂停准备的代码。
- (BOOL)addShortTimeoutInPeriod:(MatchPeriod)period atTime:(NSInteger)time{
    if (self.shortTimeout >= [self.rule limitForTimeoutType:ActionTypeTimeoutShort beforeEndOfPeriod:period]) {
        return NO;
    }
    
    if ([self isBeyondTimeoutLimitInPeriod:period atTime:time]) {// TODO 超出后变量指示NO，不用每次计算。
        return NO;
    }
    
    self.shortTimeout ++;
    return YES;
}

// TODO 如果一个队某节一直不叫暂停，只要不被强制叫暂停（另一队叫了），暂停次数仍然可以带入下一节。

- (BOOL)addRegularTimeoutInPeriod:(MatchPeriod)period atTime:(NSInteger)time{
    if (self.regularTimeout >= [self.rule limitForTimeoutType:ActionTypeTimeoutRegular beforeEndOfPeriod:period]) {
        return NO;
    }
    
    if([self isBeyondTimeoutLimitInPeriod:period atTime:time]){
        return NO;
    }
    
    self.regularTimeout ++;

    // 常规周期内的第一次暂停是100秒，其余和加时暂停都是60秒。
    if (_periodForRegularTimeout != period) {
        _periodForRegularTimeout = period;
        self.timeoutLength = TimeoutLengthRegularLong;
    }else{
        self.timeoutLength = TimeoutLengthShort;
    }
    
    if (period >= MatchPeriodFirst && period <= MatchPeriodFourth) {
        if (time < 9 * 60 && time >= 6 * 60) {
            // 从8分59秒到2分59秒，任意一次常规暂停都会抹去“强制暂停”。
            sCheckFirstMandatoryTimeout = NO;
        }else if(time < 6 * 60 && time >= 3 * 60){
            sCheckSecondMandatoryTimeout = NO;
        }
    }
    
    return YES;
}

- (BOOL)addTimeout:(TimeoutType)type inPeriod:(MatchPeriod)period atTime:(NSInteger)time{
    if (type == ActionTypeTimeoutShort) {
        return [self addShortTimeoutInPeriod:period atTime:time];
    }else if(type == ActionTypeTimeoutRegular){
        return [self addRegularTimeoutInPeriod:period atTime:time];
    }else{
        // TODO 官方暂停也该处理。
        return NO;
    }
}

@end
