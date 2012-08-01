//
//  ActionManager.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseManager.h"
#import "Action.h"
#import "Match.h"

#define kActionEntity       @"Action"
#define kMatchField         @"match"
#define kTeamField          @"team"
#define kPeriodField        @"period"
#define kTimeField          @"time"
#define kTypeField          @"type"

#define kHome               @"home"
#define kGuest              @"guest"

typedef enum {
    MatchStatePrepare = 0,          // 比赛未开始。
    MatchStatePlaying,              // 比赛计时进行中。
    MatchStateTimeout,              // 比赛暂停中。
    MatchStatePeriodFinished,       // 比赛节间休息中。
    MatchStateStopped,              // 比赛非正常结束。
    MatchStateFinished,             // 比赛正常结束。
}MatchState;

typedef enum {
    ActionTypePoints    = 0,        // 用于搜索所有得分类型事件，并非用于添加、删除事件。
    ActionType1Point    = 1,        // 罚球得分。
    ActionType2Points   = 2,        // 两分球。
    ActionType3Points   = 3,        // 三分球。
    ActionTypeFoul      = 4,        // 犯规。
    ActionTypeTimeout   = 5         // 暂停。
}ActionType;

@protocol FoulActionDelegate <NSObject>
- (void)FoulsBeyondLimit:(NSNumber *)teamId;
@end

@interface ActionManager : BaseManager

// 当前比赛的实时汇总信息。
@property (nonatomic, readonly) NSInteger homeTeamPoints;
@property (nonatomic, readonly) NSInteger homeTeamFouls;
@property (nonatomic, readonly) NSInteger homeTeamTimeouts;

@property (nonatomic, readonly) NSInteger guestTeamPoints;
@property (nonatomic, readonly) NSInteger guestTeamFouls;
@property (nonatomic, readonly) NSInteger guestTeamTimeouts;

@property (nonatomic) NSInteger periodLength;
@property (nonatomic) NSInteger periodTimeoutsLimit;
@property (nonatomic) NSInteger periodFoulsLimit;

// 当前所处节数。请调用者废弃自己定义的变量
@property (nonatomic) NSInteger period; 

// 当前比赛状态。
@property (nonatomic) MatchState state;

// 当前比赛状态的结束日期。
@property (nonatomic, strong) NSDate * matchStateFinishingDate;

@property (nonatomic, strong) NSMutableArray * actionArray; // 当前正进行比赛的action组。

@property (nonatomic, weak) id<FoulActionDelegate> delegate;

- (NSString *)nameForPeriod;

+ (ActionManager *)defaultManager;

// 一场比赛中的所有动作。
- (NSMutableArray *)actionsForMatch:(NSInteger)matchId;

// 从一组动作中筛选出某个时间段内的特定动作。
- (NSArray *)actionsWithType:(ActionType)actionType inPeriod:(NSInteger)period inActions:(NSArray *)actions;

// 返回每节比赛某个球队、某项技术统计的累计值数组。
- (NSMutableArray *)summaryForFilter:(NSInteger)filter withTeam:(NSInteger)team inActions:(NSArray *)actions;

- (BOOL)actionForHomeTeamInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time;

- (BOOL)actionForGuestTeamInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time;

- (BOOL)deleteAction:(Action *)action;
- (BOOL)deleteActionAtIndex:(NSInteger)index;
- (void)deleteActionsInMatch:(NSInteger)matchId;

- (void)resetRealtimeActions:(Match *)match;

- (void)finishMatch:(Match *)match;

- (void)storeUnfinishedMatch:(NSInteger)matchId;
- (NSInteger)restoreUnfinishedMatch;// -1代表没有进行中比赛。加载后清空缓存。

@end
