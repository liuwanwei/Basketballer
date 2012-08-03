//
//  TeamStatistics.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TeamStatistics.h"

@implementation TeamStatistics

@synthesize teamId = _teamId;
@synthesize points = _points;
@synthesize fouls = _fouls;
@synthesize timeouts = _timeouts;

- (id)initWithTeamId:(NSNumber *)teamId{
    if (self = [super init]) {
        _teamId = teamId;
    }
    
    return self;
}

- (void)addStatistic:(ActionType)actionType{
    if(actionType == ActionType1Point){
        _points += 1;
    }else if(actionType == ActionType2Points){
        _points += 2;
    }else if(actionType == ActionType3Points){
        _points += 3;
    }else if(actionType == ActionTypeTimeout){
        _timeouts ++;
    }else if (actionType == ActionTypeFoul) {
        _fouls ++;
    }    
}

- (void)subtractStatistic:(ActionType)actionType{
    if(actionType == ActionType1Point){
        _points -= 1;
        if (_points <= 0) {
            _points = 0;
        }
    }else if(actionType == ActionType2Points){
        _points -= 2;
        if (_points <= 0) {
            _points = 0;
        }        
    }else if(actionType == ActionType3Points){
        _points -= 3;
        if (_points <= 0) {
            _points = 0;
        }        
    }else if(actionType == ActionTypeTimeout){
        _timeouts --;
        if (_timeouts <= 0) {
            _timeouts = 0;
        }
    }else if (actionType == ActionTypeFoul) {
        _fouls --;
        if (_fouls <= 0) {
            _fouls = 0;
        }
    }     
}


@end
