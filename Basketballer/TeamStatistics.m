//
//  TeamStatistics.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TeamStatistics.h"
#import "NbaRule.h"
#import "FibaTeamStatistics.h"
#import "FibaRule.h"
#import "GameSetting.h"

@implementation TeamStatistics

@synthesize teamId = _teamId;
@synthesize points = _points;
@synthesize fouls = _fouls;
@synthesize timeouts = _timeouts;
@synthesize timeoutLength = _timeoutLength;
@synthesize rule = _rule;

+ (TeamStatistics *)newStatisticsForTeam:(NSNumber *)teamId withMode:(NSString *)mode withRule:(BaseRule *)rule{
    TeamStatistics * statistics = nil;
    if ([mode isEqualToString:kMatchModeFiba] ||
        (![mode isEqualToString:kMatchModeTpb]
         && ![mode isEqualToString:kMatchModePoints])){
        statistics = [[FibaTeamStatistics alloc] initWithTeamId:teamId];
        statistics.rule = rule;
    }else{
        statistics = [[TeamStatistics alloc] initWithTeamId:teamId];
        statistics.rule = rule;
    }
    
    return statistics;    
}

- (id)initWithTeamId:(NSNumber *)teamId{
    if (self = [super init]) {
        _teamId = teamId;
        _points = [NSNumber numberWithInteger:0];
        _fouls = [NSNumber numberWithInteger:0];
        _timeouts = [NSNumber numberWithInteger:0];
    }
    
    return self;
}

- (NSNumber *)increase:(NSNumber *)target withValue:(NSInteger)value{
    return [NSNumber numberWithInteger:[target integerValue] + value];
}

- (NSNumber *)decrease:(NSNumber *)target withValue:(NSInteger)value{
    NSInteger origin = [target integerValue];
    origin -= value;
    if (origin < 0) {
        return nil;
    }
    
    return [NSNumber numberWithInteger:origin];
}

- (BOOL)addStatistic:(ActionType)actionType inPeriod:(MatchPeriod)period atTime:(NSInteger)time{
    if(actionType == ActionType1Point){
        self.points = [self increase:_points withValue:1];
    }else if(actionType == ActionType2Points){
        self.points = [self increase:_points withValue:2];
    }else if(actionType == ActionType3Points){
        self.points = [self increase:_points withValue:3];
    }else if (actionType == ActionTypeFoul) {
        self.fouls = [self increase:_fouls withValue:1];
    }else if([ActionManager isTimeoutAction:actionType]){
        self.timeouts = [self increase:_timeouts withValue:1];
    }
    
    return YES;
}

- (BOOL)subtractStatistic:(ActionType)actionType{
    NSNumber * result;
    if(actionType == ActionType1Point){
        result = [self decrease:_points withValue:1];
        if (nil == result) {
            return NO;
        }
        self.points = result;
    }else if(actionType == ActionType2Points){
        result = [self decrease:_points withValue:2];
        if (nil == result) {
            return NO;
        }
        self.points = result;
    }else if(actionType == ActionType3Points){
        result = [self decrease:_points withValue:3];
        if (nil == result) {
            return NO;
        }
        self.points = result;
    }else if(actionType == ActionTypeTimeoutRegular){
        result = [self decrease:_timeouts withValue:1];
        if (nil == result) {
            return NO;
        }
        self.timeouts = result;
    }else if (actionType == ActionTypeFoul) {
        result = [self decrease:_fouls withValue:1];
        if (nil == result) {
            return NO;
        }
        self.fouls = result;
    }else{
        return NO;
    }
    
    return YES;
}

@end
