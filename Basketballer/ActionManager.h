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
    ActionTypePoints    = 0,        // 用于搜索所有得分类型事件，并非用于添加、删除事件。
    ActionType1Point    = 1,        // 罚球得分。
    ActionType2Points   = 2,        // 两分球。
    ActionType3Points   = 3,        // 三分球。
    ActionTypeFoul      = 4,        // 犯规。
    ActionTypeTimeout   = 5         // 暂停。
}ActionType;

@protocol FoulActionDelegate <NSObject>
- (void)FoulsBeyondLimit:(NSNumber *)teamId; // 0 for home team, 1 for guest team.
@end

@interface ActionManager : BaseManager

// 当前比赛的实时汇总信息。
@property (nonatomic) NSInteger homeTeamPoints;
@property (nonatomic) NSInteger homeTeamFouls;
@property (nonatomic) NSInteger homeTeamTimeouts;

@property (nonatomic) NSInteger guestTeamPoints;
@property (nonatomic) NSInteger guestTeamFouls;
@property (nonatomic) NSInteger guestTeamTimeouts;

@property (nonatomic) NSInteger periodLength;
@property (nonatomic) NSInteger periodTimeoutsLimit;
@property (nonatomic) NSInteger periodFoulsLimit;

@property (nonatomic, strong) NSMutableArray * actionArray; // 当前正进行比赛的action组。

@property (nonatomic, weak) id<FoulActionDelegate> delegate;

+ (ActionManager *)defaultManager;

- (NSMutableArray *)actionsForMatch:(Match *)match;

- (NSMutableArray *)summaryForFilter:(NSInteger)filter withTeam:(NSInteger)team inActions:(NSArray *)actions;

- (BOOL)actionForHomeTeamInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time inPeriod:(NSInteger)period;

- (BOOL)actionForGuestTeamInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time inPeriod:(NSInteger)period;

- (BOOL)deleteAction:(Action *)action;
- (BOOL)deleteActionAtIndex:(NSInteger)index;

- (void)resetRealtimeActions:(Match *)match;

- (void)calculateTeamPointsForMatch:(Match *)match;

@end
