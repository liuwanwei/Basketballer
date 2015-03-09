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


typedef enum {
    MatchStatePrepare = 0,          // 比赛未开始。
    MatchStatePlaying,              // 比赛计时进行中。
    MatchStateTimeout,              // 比赛暂停中。
    MatchStateTimeoutFinished,      // 比赛暂停结束。
    MatchStateTimeoutTemp,          // 比赛临时暂停（临时停表）。
    MatchStatePeriodFinished,       // 比赛单节结束。
    MatchStateQuarterRestTime,          // 比赛节间休息中。
    MatchStateQuarterRestTimeFinished,  // 比赛节间休息结束。
    MatchStateStopped,              // 比赛非正常结束。
    MatchStateFinished,             // 比赛正常结束。
}MatchState;

@protocol FoulActionDelegate;

@interface MatchManager : BaseManager

@property (nonatomic, strong) NSMutableArray * matchesArray;  // 所有已完成的比赛。

+ (MatchManager *)defaultManager;

- (void)loadMatches;

// 将比赛数组转换成为根据日期分组的数据对象
- (NSDictionary *)dateGroupForMatches:(NSArray *)matches;

// 注意：返回的Match对象指针不能copy给其他变量，往后的删除、添加动作等接口必须使用这个返回的Match对象指针。
- (Match *)newMatchWithMode:(NSString *)mode andHomeTeam:(NSNumber *)homeTeamId andGuestTeam:(NSNumber *)guestTeamId;

- (NSArray *)matchesWithTeamId:(NSInteger) teamId;

//- (NSDictionary *)statisticsForTeam:(NSInteger) teamId onDate:(NSDate *)date;

// 声明比赛结束。
- (void)stopMatch:(Match *)match;

// 删除比赛。
- (BOOL)deleteMatch:(Match *)match;

@end


