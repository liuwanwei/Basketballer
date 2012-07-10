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
#import "ActionManager.h"
#import "BaseManager.h"

#define kMatchEntity            @"Match"
#define kActionEntity           @"Action"

@protocol FoulActionDelegate;

@interface MatchManager : BaseManager

@property (nonatomic, strong) NSMutableArray * matchesArray;  // 所有已完成的比赛。
@property (nonatomic, weak) id<FoulActionDelegate> delegate;

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

@property (nonatomic) NSMutableArray * actionArray;

+ (MatchManager *)defaultManager;

- (void)loadMatches;

// 注意：返回的Match对象指针不能copy给其他变量，往后的删除、添加动作等接口必须使用这个返回的Match对象指针。
- (Match *)newMatchWithMode:(NSString *)mode;

- (BOOL)deleteMatch:(Match *)match;

- (BOOL)actionForHomeTeamInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time inPeriod:(NSInteger)period;
- (BOOL)actionForGuestTeamInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time inPeriod:(NSInteger)period;
- (BOOL)deleteAction:(Action *)action;
- (BOOL)deleteActionAtIndex:(NSInteger)index;

@end

@protocol FoulActionDelegate <NSObject>
- (void)FoulsBeyondLimit:(NSNumber *)teamId; // 0 for home team, 1 for guest team.
@end
