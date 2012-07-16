//
//  ActionManager.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ActionManager.h"
#import "AppDelegate.h"
#import "Action.h"
#import "GameSetting.h"

static ActionManager * sActionManager;

@interface ActionManager(){
    GameSetting * _gameSettings;
    NSInteger _period;    
}
@end


@implementation ActionManager

@synthesize homeTeamPoints = _homeTeamPoints;
@synthesize homeTeamTimeouts = _homeTeamTimeouts;
@synthesize homeTeamFouls = _homeTeamFouls;
@synthesize guestTeamPoints = _guestTeamPoints;
@synthesize guestTeamTimeouts = _guestTeamTimeouts;
@synthesize guestTeamFouls = _guestTeamFouls;
@synthesize periodFoulsLimit = _periodFoulsLimit;
@synthesize periodLength = _periodLength;
@synthesize periodTimeoutsLimit = _periodTimeoutsLimit;
@synthesize actionArray = _actionArray;
@synthesize delegate = _delegate;

+ (ActionManager *)defaultManager{
    if (nil == sActionManager) {
        sActionManager = [[ActionManager alloc] init];
    }
    
    return sActionManager;
}

- (id)init{
    if (self = [super init]) {
        _actionArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSMutableArray *)actionsForMatch:(Match *)match{
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kActionEntity];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %d", kMatchField, [match.id integerValue]];
    
    request.predicate = predicate;
    
    NSError * error = nil;
    NSMutableArray * mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (nil == mutableFetchResults) {
        NSLog(@"executeFetchRequest: %@", [error description]);
        return nil;
    }    
    
    return mutableFetchResults;
}

// 根据过滤器的值，计算每节或每个半场、某个队在某个单项上的技术统计。
- (NSMutableArray *)summaryForFilter:(NSInteger)filter withTeam:(NSInteger)team inActions:(NSArray *)actions{
    // 最多4节，囊括了上下半场（可算所2节）的情况，所以数组长度设置成4.
    const NSInteger max = 4;
    NSMutableArray * summaryArray = [[NSMutableArray alloc] initWithCapacity:max];
    // 每节数据默认值为0.
    NSNumber * initialNumber = [NSNumber numberWithInteger:0];
    for (int i = 0; i < max; i++) {
        [summaryArray insertObject:[initialNumber copy] atIndex:i];
    }
    
    for (Action * action in actions) {
        NSInteger aPeriod = [action.period integerValue];
        NSInteger aFilter = [action.type integerValue];
        NSInteger aTeam = [action.team integerValue];

        NSInteger addition = 0;
        if (aTeam == team) {
            if (filter == ActionTypePoints){
                // 根据得分类型的不同，增量值也有不同。
                if (aFilter == ActionType1Point) {
                    addition = 1;
                }else if(aFilter == ActionType2Points){
                    addition = 2;
                }else if(aFilter == ActionType3Points){
                    addition = 3;
                }
            }else if(filter == aFilter){
                // 犯规和暂停次数的增量值都是1.
                addition = 1;
            }
        }
        
        NSNumber * object = [summaryArray objectAtIndex:aPeriod];
        if (nil == object) {
            object = [[NSNumber alloc] initWithInt:addition];
        }else{
            NSInteger oldValue = [object integerValue];
            object = [NSNumber numberWithInteger:oldValue + addition];
        }
        
        [summaryArray replaceObjectAtIndex:aPeriod withObject:object];
    }
    
    return summaryArray;
}

- (Action *)newActionInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time inPeriod:(NSInteger)period{
    Action * action = (Action *)[NSEntityDescription insertNewObjectForEntityForName:kActionEntity 
                                                              inManagedObjectContext:self.managedObjectContext];
    action.type = [NSNumber numberWithInteger:actionType];
    action.match = match.id;
    action.period = [NSNumber numberWithInteger:period];
    action.time = [NSNumber numberWithInteger:time];
    
    return action;
}

- (BOOL)actionForHomeTeamInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time inPeriod:(NSInteger)period{
    // 暂停有总数限制，要先检查一下。
    if ((actionType == ActionTypeTimeout) && (period == _period)) {
        // period发生改变时，意味着进入下一节，靠后续处理来清零犯规、暂停数据。        
        if (_homeTeamTimeouts >= _periodTimeoutsLimit) {
            return NO;
        }
    }
    
    Action * action = [self newActionInMatch:match withType:actionType atTime:time inPeriod:period];
    action.team = match.homeTeam;
    
    if( ![self synchroniseToStore]){
        return NO;
    }
    
    [_actionArray insertObject:action atIndex:0];
    
    // 更新本场比赛实时数据。
    
    // 进入下一节时，清零犯规和暂停计数。
    if (period != _period) {
        _homeTeamFouls = 0;
        _homeTeamTimeouts = 0;
        _period = period;
    }
    
    if(actionType == ActionType1Point){
        _homeTeamPoints += 1;
    }else if(actionType == ActionType2Points){
        _homeTeamPoints += 2;
    }else if(actionType == ActionType3Points){
        _homeTeamPoints += 3;
    }else if(actionType == ActionTypeTimeout){
        _homeTeamTimeouts ++;
    }else if (actionType == ActionTypeFoul) {
        // 犯规伴随着罚球，如果超出单节允许犯规次数的话。
        _homeTeamFouls ++;
        if (_homeTeamFouls > _periodFoulsLimit) {
            if (( _delegate != nil ) && [_delegate respondsToSelector:@selector(FoulsBeyondLimit:)]) {
                [_delegate performSelector:@selector(FoulsBeyondLimit:) withObject:match.homeTeam];
            }
        }
    }
    
    return YES;
}

- (BOOL)actionForGuestTeamInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time inPeriod:(NSInteger)period{
    // 暂停有总数限制，要先检查一下。
    if ((actionType == ActionTypeTimeout) && (period == _period)) {
        // period发生改变时，意味着进入下一节，靠后续处理来清零犯规、暂停数据。        
        if (_guestTeamTimeouts >= _periodTimeoutsLimit) {
            return NO;
        }
    }
    
    Action * action = [self newActionInMatch:match withType:actionType atTime:time inPeriod:period];
    action.team = match.guestTeam;
    
    if( ![self synchroniseToStore]){
        return NO;
    }
    
    [_actionArray insertObject:action atIndex:0];
    
    // 更新本场比赛实时数据。
    
    // 进入下一节时，清零犯规和暂停计数。
    if (period != _period) {
        _guestTeamFouls = 0;
        _guestTeamTimeouts = 0;
        _period = period;
    }
    
    if(actionType == ActionType1Point){
        _guestTeamPoints += 1;
    }else if(actionType == ActionType2Points){
        _guestTeamPoints += 2;
    }else if(actionType == ActionType3Points){
        _guestTeamPoints += 3;
    }else if(actionType == ActionTypeTimeout){
        _guestTeamTimeouts ++;
    }else if (actionType == ActionTypeFoul) {
        // 犯规伴随着罚球，如果超出单节允许犯规次数的话。
        _guestTeamFouls ++;
        if (_guestTeamFouls > _periodFoulsLimit) {
            if (( _delegate != nil ) && [_delegate respondsToSelector:@selector(FoulsBeyondLimit:)]) {
                [_delegate performSelector:@selector(FoulsBeyondLimit:) withObject:match.guestTeam];
            }
        }
    }
    
    return YES;
}

- (BOOL)deleteAction:(Action *)action{
    [self.managedObjectContext deleteObject:action];
    if(! [self synchroniseToStore]){
        return NO;
    }
    
    [_actionArray removeObject:action];
    
    return YES;
}

- (BOOL)deleteActionAtIndex:(NSInteger)index{
    if (index >= _actionArray.count) {
        NSLog(@"index beyond actionArray count");
        return NO;
    }
    
    return [self deleteAction:[_actionArray objectAtIndex:index]];
}



- (void)resetRealtimeActions:(Match *)match{
    _gameSettings = [GameSetting defaultSetting];
    
    _homeTeamPoints = 0;
    _homeTeamFouls = 0;
    _homeTeamTimeouts = 0;
    _guestTeamPoints = 0;
    _guestTeamFouls = 0;
    _guestTeamTimeouts = 0;
    
    _period = -1;
    
    if ([match.mode isEqualToString:kGameModeFourQuarter]) {
        _periodLength = [_gameSettings.quarterLength integerValue];
        _periodFoulsLimit = [_gameSettings.foulsOverQuarterLimit integerValue];
        _periodTimeoutsLimit = [_gameSettings.timeoutsOverQuarterLimit integerValue];
    }else{
        _periodLength = [_gameSettings.halfLength integerValue];
        _periodFoulsLimit = [_gameSettings.foulsOverHalfLimit integerValue];
        _periodTimeoutsLimit = [_gameSettings.timeoutsOverHalfLimit integerValue];
    }
    
    [_actionArray removeAllObjects];
}

- (void)calculateTeamPointsForMatch:(Match *)match{
    if (nil != match) {
        match.homePoints = [NSNumber numberWithInteger: _homeTeamPoints];
        match.guestPoints = [NSNumber numberWithInteger: _guestTeamPoints];
    }
    return;
    NSInteger points = 0;
    NSInteger homePoints = 0;
    NSInteger guestPoints = 0;
    NSInteger homeTeamId = [match.homeTeam integerValue];
    NSInteger guestTeamId = [match.guestTeam integerValue];
    
    for (Action * action in self.actionArray) {
        NSInteger actionType = [action.type integerValue];
        
        points = 0;
        if (actionType == ActionType1Point) {
            points ++;
        }else if(actionType == ActionType2Points){
            points += 2;
        }else if(actionType == ActionType3Points){
            points += 3;
        }else{
            continue;
        }
        
        NSInteger teamId = [action.team integerValue];        
        if (teamId == homeTeamId) {
            homePoints += points;
        }else if(teamId == guestTeamId){
            guestPoints += points;
        }
    }
    
    match.homePoints = [NSNumber numberWithInteger:homePoints];
    match.guestPoints = [NSNumber numberWithInteger:guestPoints];
    
    [_actionArray removeAllObjects];
}

@end
