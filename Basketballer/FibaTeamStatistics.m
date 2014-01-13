//
//  FibaTeamStatistics.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FibaTeamStatistics.h"

@implementation FibaTeamStatistics

- (BOOL)addStatistic:(ActionType)actionType inPeriod:(MatchPeriod)period atTime:(NSInteger)time{
    if ([ActionManager isTimeoutAction:actionType]) {
        if(! [self addTimeout:actionType inPeriod:period atTime:time]){
            return NO;
        }
    }
    
    return [super addStatistic:actionType inPeriod:period atTime:time];
}

- (BOOL)addTimeout:(ActionType)type inPeriod:(MatchPeriod)period atTime:(NSInteger)time{
    if (type != ActionTypeTimeoutRegular) {
        // FIBA只支持常规暂停。
        return NO;
    }
    
    if ([self.timeouts integerValue] >= [self.rule timeoutLimitBeforeEndOfPeriod:period]) {
        // 暂停次数已到。
        return NO;
    }
    
    // TODO: 缓存暂停时间（线程不安全，切记不能在多线程环境中访问这个数据）。
    self.timeoutLength = TimeoutLengthRegular;
    return YES;   
}

@end
