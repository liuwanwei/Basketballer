//
//  Fiba3pbRule.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Fiba3pbRule.h"
#import "MatchUnderWay.h"

@implementation Fiba3pbRule

- (NSInteger)regularPeriodNumber{
    return 2;
}

- (NSInteger)foulLimitForTeam{
    return 4;
}

- (NSInteger)foulLimitForPlayer{
    return 4;
}

- (NSInteger)offenceTimeLimit{
    return 10;  // 14秒内必须完成一次投篮并砸框。
}

- (NSInteger)winningPoints{
    return 33;  // 任意时间内谁先得到33分获胜。
}

- (NSInteger)timeLengthForPeriod:(MatchPeriod)period{
    if (period >= MatchPeriodFirst && period <= MatchPeriodThird) {
        return 5 * 60;
    }else if(period >= MatchPeriodOvertime){
        return 2 * 60;
    }else{
        return 0;
    }
}

// 每个周期结束后休息多久。
- (NSInteger)restTimeLengthAfterPeriod:(MatchPeriod)period{
    return 1 * 60;
}

// 每个周期开始前，判断是否要清零暂停数据。
- (BOOL)isTimeoutExpiredBeforePeriod:(MatchPeriod)period{
    return NO;
}

// 在一个周期结束之前，一共允许多少次暂停。
- (NSInteger)timeoutLimitBeforeEndOfPeriod:(MatchPeriod)period{
    return 0;   
}

@end
