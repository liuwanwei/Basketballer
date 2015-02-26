//
//  BaiscRule.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseRule.h"
#import "FibaRule.h"
#import "Fiba3pbRule.h"
#import "FibaCustomRule.h"
#import "CustomRuleManager.h"
#import "Rule.h"
#import "GameSetting.h"
#import "TeamStatistics.h"
#import "MatchUnderWay.h"
#import "OnlyPointRule.h"
#import "AmateurRule.h"

@implementation BaseRule

@synthesize regularPeriodNumber = _periodNumber;
@synthesize foulLimitForTeam = _foulLimitForTeam;
@synthesize foulLimitForPlayer = _foulLimitForPlayer;
@synthesize offenceTimeLimit = _offenceTimeLimit;
@synthesize winningPoints = _winningPoints;

// 工厂接口，通过规则名字生成规则
+ (instancetype)ruleWithName:(NSString *)name{
    if (name == nil) {
        return nil;
    }
        
    BaseRule * rule = nil;
    
    if ([name isEqualToString:kMatchModeFiba]){
        rule = [[FibaRule alloc] initWithName:name];
    }else if([name isEqualToString:kMatchModeTpb]){
        rule = [[Fiba3pbRule alloc] initWithName:name];
    }else if([name isEqualToString:kMatchModePoints]) {
        rule = [[OnlyPointRule alloc] initWithName:name];
    }else if([name hasPrefix:kMatchModeAmateur]){
        rule = [[AmateurRule alloc] initWithName:name];
    }else {
        CustomRuleManager * manager = [CustomRuleManager defaultInstance];
        rule = [manager customRuleWithName:name];
    }
    
    if (rule == nil) {
        NSLog(@"找不到自定义比赛规则: %@", name);
    }
    
    return rule;
}


- (id)initWithName:(NSString *)name{
    if (self = [super init]) {
        self.name = name;
    }
    
    return self;
}

// 每个周期有多长时间，单位（秒）。
- (NSInteger)timeLengthForPeriod:(MatchPeriod)period{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return 0;
}

// 每个周期结束后休息多久。
- (NSInteger)restTimeLengthAfterPeriod:(MatchPeriod)period{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return 0;
}

// 每个周期开始前，判断是否要清零暂停数据。
- (BOOL)isTimeoutExpiredBeforePeriod:(MatchPeriod)period{
    return NO;
}

// 在一个周期结束之前，一共允许多少次暂停。
- (NSInteger)timeoutLimitBeforeEndOfPeriod:(MatchPeriod)period{
    return UnlimitNumber;
}

- (BOOL)isGameOver{
    MatchUnderWay * match = [MatchUnderWay defaultMatch];
    
    // 一般的比赛，常规赛结束时，比分只要不同，就可以认为比赛结束。    
    if (match.period >= (match.rule.regularPeriodNumber - 1)) {
        if (match.countdownSeconds <= 0) {
            return (! [match.home.points isEqualToNumber:match.guest.points]);
        }
    }
    
    return NO;
}

@end
