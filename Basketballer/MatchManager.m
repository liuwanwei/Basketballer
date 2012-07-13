//
//  MatchManager.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MatchManager.h"
#import "AppDelegate.h"
#import "GameSetting.h"
#import "Action.h"

static MatchManager * sDefaultManager;

@interface MatchManager(){
    GameSetting * _gameSettings;
    NSInteger _period;    
}
@end

@implementation MatchManager

@synthesize matchesArray = _matchesArray;
@synthesize delegate = _delegate;

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

+ (MatchManager *)defaultManager{
    if (sDefaultManager == nil) {
        sDefaultManager = [[MatchManager alloc] init];
    }
    return sDefaultManager;
}

- (void)initRealtimeInfo:(Match *)match{
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
    
    if (nil == _actionArray) {
        _actionArray = [[NSMutableArray alloc] init];
    }else{
        [_actionArray removeAllObjects];
    }
}

- (void)loadMatches{
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kMatchEntity];

    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.sortDescriptors = sortDescriptors;
    
    NSError * error = nil;
    NSMutableArray * mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (nil == mutableFetchResults) {
        NSLog(@"executeFetchRequest: %@", [error description]);
        return;
    }
    
    self.matchesArray = mutableFetchResults;
}

// 生成一个不会重复的比赛id     
- (NSNumber *)idGenerator{
    NSMutableIndexSet * idSet = [[NSMutableIndexSet alloc] init];
    for (Match * match in _matchesArray) {
        [idSet addIndex:[[match id] integerValue]];
    }
    
    NSInteger id = 0;
    while ([idSet containsIndex:id]) {
        id ++;
    }
    
    return [NSNumber numberWithInteger:id];
}

- (Match *)newMatchWithMode:(NSString *)mode{
    Match * newOne = (Match *)[NSEntityDescription insertNewObjectForEntityForName:kMatchEntity 
                                    inManagedObjectContext:self.managedObjectContext];
    
    newOne.id = [self idGenerator];
    
    // 默认填充当前时间作为比赛时间。
    newOne.date = [NSDate date];
    
    newOne.mode = mode;
    
    if(! [self synchroniseToStore]){
        return nil;
    }
    
    [self.matchesArray insertObject:newOne atIndex:0];
    
    [self initRealtimeInfo:newOne];
    
    return newOne;
}

- (Match *)newMatchWithMode:(NSString *)mode withHomeTeam:(Team *)home withGuestTeam:(Team *)guestTeam{
    Match * newOne = [self newMatchWithMode:mode];
    if (newOne != nil) {
        newOne.homeTeam = home.id;
        newOne.guestTeam = guestTeam.id;
        
        [self synchroniseToStore];
    }
    
    return newOne;
}

- (BOOL)deleteMatch:(Match *)match{
    if (! [self deleteFromStore:match]) {
        return NO;
    }
    
    [self.matchesArray removeObject:match];
    
    return YES;
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
    }
    
    if(actionType == ActionTypeFoul){
        _homeTeamFouls ++;
    }else if(actionType == ActionType1Point){
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
                [_delegate performSelector:@selector(FoulsBeyondLimit:) withObject:[NSNumber numberWithInt:0]];
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
    }
    
    if(actionType == ActionTypeFoul){
        _guestTeamFouls ++;
    }else if(actionType == ActionType1Point){
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
                [_delegate performSelector:@selector(FoulsBeyondLimit:) withObject:[NSNumber numberWithInt:1]];
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

@end
