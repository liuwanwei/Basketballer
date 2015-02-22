//
//  ActionManager.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseManager.h"
#import "BaseRule.h"
#import "Action.h"
#import "Match.h"
#import "Player.h"

#define kActionEntity       @"Action"
#define kMatchField         @"match"
#define kTeamField          @"team"
#define kPeriodField        @"period"
#define kTimeField          @"time"
#define kTypeField          @"type"

#define kHome               @"home"
#define kGuest              @"guest"

#define kTimeoutMessage     @"kTimeout"
#define kAddScoreMessage    @"AddScore"
#define kAddFoulMessage     @"AddFoul"
#define kAddTimeoutMessage  @"AddTimeout"
#define kAddAssistMessage   @"AddAssist"
#define kAddReboundMessage  @"AddRebound"
#define kDeleteActionMessage @"DeleteAction"

// 计算技术统计时使用。
#define kName               @"name"
#define kPoints             @"Points"
#define kPersonalFouls      @"PersonalFouls"
#define k3PointMade         @"3PointMade"
#define kFreeThrow          @"FreeThrow"

typedef enum {
    ActionTypeNone      = -1,
    ActionTypePoints    = 0,        // 用于搜索所有得分类型事件，并非用于添加、删除事件。
    ActionType1Point    = 1,        // 罚球得分。
    ActionType2Points   = 2,        // 两分球。
    ActionType3Points   = 3,        // 三分球。
    ActionTypeFoul      = 4,        // 犯规。
    ActionTypeTimeoutRegular = 5,   // 常规暂停。
    ActionTypeTimeoutShort = 6,     // 短暂停。
    ActionTypeTimeoutOfficial = 7,  // 官方暂停。
    ActionTypeRebound   = 8,        // 篮板
    ActionTypeAssist    = 9,        // 助攻
    ActionTypeBlock     = 10,       // 盖帽
}ActionType;

@class TeamStatistics;
@class BaseRule;

@interface ActionManager : BaseManager

@property (nonatomic, strong) NSMutableArray * actionArray; // 当前正进行比赛的action组。TODO 主客队分开提高查询效率。

+ (ActionManager *)defaultManager;
+ (BOOL)isTimeoutAction:(ActionType)actionType;
+ (BOOL)isPointAction:(ActionType)actionType;
+ (BOOL)isFoulAction:(ActionType)actionType;

+ (NSString *)descriptionForActionType:(ActionType)actionType;

// 一场比赛中的所有动作。
- (NSMutableArray *)actionsForMatch:(NSInteger)matchId;

- (Action *)newActionForTeam:(NSNumber *)teamId forPlayer:(NSNumber *)playerId withType:(NSInteger)actionType atTime:(NSInteger)time inPeriod:(MatchPeriod)period;

// 从一组动作中筛选出某个时间段内的特定动作。
- (NSArray *)actionsWithType:(ActionType)actionType inPeriod:(NSInteger)period inActions:(NSArray *)actions;

// 返回每节比赛某个球队、某项技术统计的累计值数组。
- (NSMutableArray *)summaryForFilter:(NSInteger)filter withTeam:(NSInteger)team inActions:(NSArray *)actions;

// 获取球队在某个阶段的技术统计汇总信息。
- (NSMutableDictionary *)statisticsForTeam:(NSNumber *)team inPeriod:(NSInteger)period inActions:(NSArray *)actions;

// 获取球员全场的技术统计信息。
- (NSMutableDictionary *)statisticsForPlayer:(NSNumber *)playerId inActions:(NSArray *)actions;

- (BOOL)deleteAction:(Action *)action;
- (void)deleteActionsInMatch:(NSInteger)matchId;

@end
