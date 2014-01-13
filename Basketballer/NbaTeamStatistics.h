//
//  NbaTeamStatistics.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TeamStatistics.h"

@interface NbaTeamStatistics : TeamStatistics

// 检查是否需要官方或强制暂停。
+ (void)initCheck;
+ (TimeoutType)checkAutoTimeout:(MatchPeriod)period atTime:(NSInteger)time;

@end
