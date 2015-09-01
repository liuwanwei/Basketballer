//
//  MatchUnderWay.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseRule.h"
#import "ActionManager.h"
#import "MatchManager.h"
#import "TeamStatistics.h"

@protocol FoulActionDelegate <NSObject>
@optional
- (void)FoulsBeyondLimitForTeam:(NSNumber *)teamId;
- (void)FoulsBeyondLimitForPlayer:(NSNumber *)playerId;
- (void)attainWinningPointsForTeam:(NSNumber *)teamId;
@end

@interface MatchUnderWay : NSObject

+ (MatchUnderWay *)defaultMatch;

//+ (void)storeUnfinishedMatch:(NSInteger)matchId withStateFinishingDate:(NSDate *)date;
//+ (NSInteger)restoreUnfinishedMatch;// -1代表没有进行中比赛。加载后清空缓存。

@property (nonatomic, weak) id<FoulActionDelegate> delegate;

// 正在进行的比赛对象。
@property (nonatomic, strong) Match * match;

// 比赛模式。选择模式后，比赛还未开始，match属性还未被赋值时使用。
@property (nonatomic, weak) NSString * matchMode;

// 当前比赛状态。
@property (nonatomic) MatchState state;

// 当前所处节数。请调用者废弃自己定义的变量
@property (nonatomic) MatchPeriod period;

// 当前比赛状态的开始日期
@property (nonatomic ,strong) NSDate * matchStateStartDate;

// 当前比赛状态的结束日期。
@property (nonatomic, strong) NSDate * matchStateFinishingDate;

@property (nonatomic, strong) TeamStatistics * home;
@property (nonatomic, strong) TeamStatistics * guest;
@property (nonatomic, strong) BaseRule * rule; 

@property (nonatomic) NSInteger countdownSeconds;
@property (nonatomic) NSInteger timeoutCountdownSeconds;

- (NSInteger)computeTimeDifference;
- (BOOL)addActionForTeam:(NSNumber *)teamId forPlayer:(NSNumber *)player withAction:(ActionType)action;
- (BOOL)deleteWrongAction:(Action *)action;

- (NSString *)nameForPeriod:(MatchPeriod)period;
- (NSString *)nameForCurrentPeriod;

- (void)initMatchDataWithHomeTeam:(NSNumber *)homeTeamId andGuestTeam:(NSNumber *)guestTeamId;

- (BOOL)startNewMatch;
- (void)stopMatchWithState:(NSInteger)state;
- (BOOL)isMatchStart;
- (void)finishMatch;
- (void)deleteMatch;

- (NSDate *)periodFinishingDate;
- (NSDate *)timeoutFinishingDate;

@end
