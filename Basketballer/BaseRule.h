//
//  BaiscRule.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TimeoutLimitNone        -1

typedef enum{
    MatchPeriodAll = -2,
    MatchPeriodUnplayed = -1,
    MatchPeriodFirst = 0,
    MatchPeriodSecond,
    MatchPeriodThird,
    MatchPeriodFourth,
    
    // 加时赛1。加时赛2用“MatchPeriodOvertime+1”标示，以此类推。
    MatchPeriodOvertime = 50
}MatchPeriod;

#define UnlimitNumber       9999

@interface BaseRule : NSObject

// 规则名称
@property (nonatomic, copy) NSString * name;

// 常规比赛打几个周期。
@property (nonatomic) NSInteger regularPeriodNumber;

// 达到罚球标准(bonus)之前允许的球队犯规次数。
@property (nonatomic) NSInteger foulLimitForTeam;

// 达到罚下标准之前允许球员犯规次数。
@property (nonatomic) NSInteger foulLimitForPlayer;

// 进攻时间违例。
@property (nonatomic) NSInteger offenceTimeLimit;

// 夺取胜利需要达到的分数。（三人篮球模式有效）
@property (nonatomic) NSInteger winningPoints;

/****************** methods ******************/

+ (BaseRule *)ruleWithMode:(NSString *)mode;

- (id)initWithName:(NSString *)name;

// 每个周期有多长时间，单位（秒）。
- (NSInteger)timeLengthForPeriod:(MatchPeriod)period;

// 每个周期结束后休息多久。
- (NSInteger)restTimeLengthAfterPeriod:(MatchPeriod)period;

// 每个周期开始前，判断是否要清零暂停数据。
- (BOOL)isTimeoutExpiredBeforePeriod:(MatchPeriod)period;

// 在一个周期结束之前，一共允许多少次暂停。
- (NSInteger)timeoutLimitBeforeEndOfPeriod:(MatchPeriod)period;

// 判断是否需要马上结束比赛。
- (BOOL)isGameOver;


@end
