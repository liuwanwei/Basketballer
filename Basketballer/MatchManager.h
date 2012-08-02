//
//  MatchManager.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Match.h"
#import "Action.h"
#import "Team.h"
#import "ActionManager.h"
#import "BaseManager.h"

#define kMatchEntity            @"Match"
#define kActionEntity           @"Action"
#define kMatchChanged           @"MatchChangedNotification"

#define kWinning                @"Winning"
#define kLosing                 @"Losing"

@protocol FoulActionDelegate;

@interface MatchManager : BaseManager

@property (nonatomic, strong) NSMutableArray * matchesArray;  // 所有已完成的比赛。

+ (MatchManager *)defaultManager;

- (void)loadMatches;

// 注意：返回的Match对象指针不能copy给其他变量，往后的删除、添加动作等接口必须使用这个返回的Match对象指针。
- (Match *)newMatchWithMode:(NSString *)mode withHomeTeam:(Team *)home withGuestTeam:(Team *)guestTeam;

- (NSArray *)matchesWithTeamId:(NSInteger) teamId;

- (NSDictionary *)statisticsForTeam:(NSInteger) teamId onDate:(NSDate *)date;

// 声明比赛开始。调用该接口后，记录比赛的真实开始时间。（暂时不支持）
- (void)startMatch:(Match *)match;

// 声明比赛结束。
- (void)finishMatch:(Match *)match; // Deprecated
- (void)stopMatch:(Match *)match withState:(MatchState) state;

// 删除比赛。
- (BOOL)deleteMatch:(Match *)match;

@end


