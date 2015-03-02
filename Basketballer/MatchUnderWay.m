//
//  MatchUnderWay.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MatchUnderWay.h"
#import "ActionManager.h"
#import "MatchManager.h"
#import "TeamStatistics.h"
#import "AppDelegate.h"
#import <MBProgressHUD.h>

//#define kMatchId                @"MatchId"
//#define kHomeTeamPoints         @"HomeTeamPoints"
//#define kHomeTeamFouls          @"HomeTeamFouls"
//#define kHomeTeamTimeouts       @"HomeTeamTimeouts"
//#define kGuestTeamPoints        @"GuestTeamPoints"
//#define KGuestTeamFouls         @"GuestTeamFouls"
//#define kGuestTeamTimeouts      @"GuestTeamTimeouts"
//#define kMatchPeriod            @"MatchPeriod"
//#define kMatchState             @"MatchState"
//#define kMatchStateFinishingDate @"MatchStateFinishingDate"

static MatchUnderWay * sDefaultMatch = nil;

@implementation MatchUnderWay

@synthesize delegate = _delegate;
@synthesize home = _home;
@synthesize guest = _guest;
@synthesize rule = _rule;
@synthesize countdownSeconds = _countdownSeconds;
@synthesize timeoutCountdownSeconds = _timeoutCountdownSeconds;

@synthesize match = _match;
@synthesize matchMode = _matchMode;
@synthesize state = _state;
@synthesize period = _period;
@synthesize matchStateFinishingDate = _matchStateFinishingDate;
@synthesize matchStateStartDate = _matchStateStartDate;

+ (MatchUnderWay *)defaultMatch{
    if (sDefaultMatch == nil) {
        sDefaultMatch = [[MatchUnderWay alloc] init];
        sDefaultMatch.state = MatchStatePrepare;        
    }
    
    return sDefaultMatch;
}

- (NSInteger)computeTimeDifference {
    NSDate * nowDate = [NSDate date];
    NSTimeInterval timeDifference = [nowDate timeIntervalSinceDate:_matchStateStartDate]; 
    return timeDifference;
}

- (TeamStatistics *)statisticsForTeam:(NSNumber *)teamId{
    if ([teamId isEqualToNumber:_home.teamId]) {
        return _home;
    }else if([teamId isEqualToNumber:_guest.teamId]){
        return _guest;
    }else{
        return nil;
    }
}

- (BOOL)addActionForTeam:(NSNumber *)teamId forPlayer:(NSNumber *)player withAction:(ActionType)action{
    TeamStatistics * statistics = [self statisticsForTeam:teamId];
    
    // 先尝试添加技术统计，因为暂停有次数限制，此处要先判断一下允不允许添加。
    if(! [statistics addStatistic:action inPeriod:_period atTime:_countdownSeconds]){
        return NO;
    }    
    
    ActionManager * am = [ActionManager defaultManager];
    [am newActionForTeam:teamId forPlayer:player withType:action atTime:_countdownSeconds inPeriod:_period];
    
    NSNotification * notification = nil;
    if ([ActionManager isPointAction:action]){
        notification = [NSNotification notificationWithName:kAddScoreMessage object:teamId];
        
        NSInteger winningPoints = self.rule.winningPoints;
        if (winningPoints != 0) {
            // 遇到先得够一定分就能获胜的比赛，要自动做出裁决。
            if ([statistics.points integerValue] >= winningPoints) {
                if (_delegate != nil){      
                    if([_delegate respondsToSelector:@selector(attainWinningPointsForTeam:)]) {
                        [_delegate performSelector:@selector(attainWinningPointsForTeam:) withObject:statistics.teamId];
                    }    
                }
            }
        }
    }else if([ActionManager isFoulAction:action]){
        // 超过个人最大犯规次数后，需要罚下该球员。
        Statistics * playerStatistics = [am statisticsForPlayer:player inActions:am.actionArray];
        NSInteger personalFouls = playerStatistics.fouls;
        if(personalFouls > self.rule.foulLimitForPlayer){
            if (_delegate != nil){   
                if([_delegate respondsToSelector:@selector(FoulsBeyondLimitForPlayer:)]) {
                    [_delegate performSelector:@selector(FoulsBeyondLimitForPlayer:) withObject:player];
                }   
            }
        }
        
        // 超过球队最大犯规次数后需要执行罚球。
        if ([statistics.fouls integerValue] > statistics.rule.foulLimitForTeam) {
            if (_delegate != nil){
                if([_delegate respondsToSelector:@selector(FoulsBeyondLimitForTeam:)]) {
                    [_delegate performSelector:@selector(FoulsBeyondLimitForTeam:) withObject:statistics.teamId];
                }   
            }
        }
        
        notification = [NSNotification notificationWithName:kAddFoulMessage object:teamId];
    }else if([ActionManager isTimeoutAction:action]){
        notification = [NSNotification notificationWithName:kAddTimeoutMessage object:teamId];
    }else if(ActionTypeRebound == action){
        notification = [NSNotification notificationWithName:kAddReboundMessage object:teamId];
    }else if(ActionTypeAssist == action){
        notification = [NSNotification notificationWithName:kAddAssistMessage object:teamId];
    }
    
    if (notification) {
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    return YES;
}

- (BOOL)deleteWrongAction:(Action *)action{
    // 更新实时技术统计缓存TeamStatistics中的信息。
    TeamStatistics * statistics = [self statisticsForTeam:action.team];
    if([statistics subtractStatistic:(ActionType)[action.type integerValue]]){
        ActionManager * am = [ActionManager defaultManager];
        return [am deleteAction:action];
    }else{
        return NO;
    }
}

- (void)setPeriod:(MatchPeriod)period{
    // 进入下一节时，清零犯规和暂停计数。
    if (period != _period || MatchPeriodUnplayed == period) {        
        if ([self.rule isTimeoutExpiredBeforePeriod:period]) {
            _home.timeouts = [NSNumber numberWithInt:0];
            _guest.timeouts = [NSNumber numberWithInt:0];
        }
        
        // 球队犯规在一个周期结束后总是清零。
        _home.fouls = [NSNumber numberWithInteger:0];
        _guest.fouls = [NSNumber numberWithInteger:0];
    }    
    
    _period = period;    
}

- (NSString *)nameForPeriod:(MatchPeriod)period{
    NSArray * _matchPeriodNameFor4Quarter = [NSArray arrayWithObjects:LocalString(@"Period1"), LocalString(@"Period2"), LocalString(@"Period3"), LocalString(@"Period4"), nil];
    if (period >= MatchPeriodOvertime) {
        return LocalString(@"Overtime");// TODO
    }
    NSInteger temp = (period <= MatchPeriodUnplayed ? MatchPeriodFirst : period);
    return [_matchPeriodNameFor4Quarter objectAtIndex:temp];
}

- (NSString *)nameForCurrentPeriod{
    return [self nameForPeriod:_period];
}

// 开始比赛前，初始化比赛实时数据。
- (void)initMatchDataWithHomeTeam:(NSNumber *)homeTeamId andGuestTeam:(NSNumber *)guestTeamId{
    if (homeTeamId && guestTeamId) {
        ActionManager * am = [ActionManager defaultManager];
        am.actionArray = [[NSMutableArray alloc] init];
        
        self.rule = [BaseRule ruleWithName:self.matchMode];
        _home = [TeamStatistics newStatisticsForTeam:homeTeamId withMode:_matchMode withRule:self.rule];
        _guest = [TeamStatistics newStatisticsForTeam:guestTeamId withMode:_matchMode withRule:self.rule];
        
        self.state = MatchStatePrepare;        
        self.period = MatchPeriodUnplayed;
    }
}

- (BOOL)startNewMatch{
    _match = [[MatchManager defaultManager] newMatchWithMode:_matchMode
                                                 andHomeTeam:_home.teamId
                                                andGuestTeam:_guest.teamId];
    _match.state = [NSNumber numberWithInteger:MatchStatePlaying];
    self.state = MatchStatePlaying;
    
    return YES;
}

- (BOOL)matchStarted{
    return self.state == MatchStatePlaying;
}

- (void)stopMatchWithState:(NSInteger)state{
    [self finishMatch];
    
    _match.state = [NSNumber numberWithInteger:state];
    self.state = MatchStatePrepare;
    
    [[MatchManager defaultManager] stopMatch:_match];
}

- (void)finishMatch{
    if (_match) {
        _match.homePoints = [_home.points copy];
        _match.guestPoints = [_guest.points copy];
    }
    
    _home = nil;
    _guest = nil;
}

- (void)deleteMatch{
    [[MatchManager defaultManager] deleteMatch:_match];
    self.match = nil;
}

- (NSDate *)periodFinishingDate {
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:_countdownSeconds];
    return date;
}

- (NSDate *)timeoutFinishingDate {
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:_timeoutCountdownSeconds];
    return date;
}

- (void)setCountdownSeconds:(NSInteger)countdownSeconds {
    if (countdownSeconds < 0) {
        _countdownSeconds = 0;
    }else {
        _countdownSeconds = countdownSeconds;
    }
}

- (void)setTimeoutCountdownSeconds:(NSInteger)timeoutCountdownSeconds {
    if (timeoutCountdownSeconds < 0) {
        _timeoutCountdownSeconds = 0;
    }else {
        _timeoutCountdownSeconds = timeoutCountdownSeconds;
    }
}

@end
