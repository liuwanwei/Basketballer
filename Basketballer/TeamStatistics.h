//
//  TeamStatistics.h
//  记录跟球队相关的数据统计，包括球队总得分、全队犯规、暂停
//
//  Created by Liu Wanwei on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseRule.h"
#import "ActionManager.h"

typedef enum{
    TimeoutLengthZero = 0,
    TimeoutLengthShort = 20,
    TimeoutLengthRegular = 60,
    TimeoutLengthRegularLong = 100
}TimeoutLengthType;

@interface TeamStatistics : NSObject

// 比赛规则。
@property (nonatomic, weak) BaseRule * rule;

@property (nonatomic, strong) NSNumber * teamId;
@property (nonatomic) NSNumber * points;
@property (nonatomic) NSNumber * fouls;
@property (nonatomic) NSNumber * timeouts;

// “活跃”变量，调用addTimeout成功后，从这里可以获得暂停时间长度。
@property (nonatomic) TimeoutLengthType timeoutLength;

- (id)initWithTeamId:(NSNumber *)teamId;

- (BOOL)addStatistic:(ActionType)actionType inPeriod:(MatchPeriod)period atTime:(NSInteger)time;
- (BOOL)subtractStatistic:(ActionType)actionType;

// 根据比赛模式字符串（NBA、FIBA），返回相应对象。
+ (TeamStatistics *)newStatisticsForTeam:(NSNumber *)teamId withMode:(NSString *)mode withRule:(BaseRule *)rule;

@end
