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
#import "TeamStatistics.h"

static ActionManager * sActionManager;

@interface ActionManager(){
    GameSetting * _gameSettings;  
    
    // 正在进行比赛的两队的技术统计。
    TeamStatistics * _home;
    TeamStatistics * _guest;
    TeamStatistics * __weak _currentTeam;
    
    NSURL * _documentURL;
}
@end


@implementation ActionManager

@synthesize homeTeamPoints = _homeTeamPoints;
@synthesize homeTeamTimeouts = _homeTeamTimeouts;
@synthesize homeTeamFouls = _homeTeamFouls;
@synthesize guestTeamPoints = _guestTeamPoints;
@synthesize guestTeamTimeouts = _guestTeamTimeouts;
@synthesize guestTeamFouls = _guestTeamFouls;
@synthesize period = _period;
@synthesize periodFoulsLimit = _periodFoulsLimit;
@synthesize periodLength = _periodLength;
@synthesize periodTimeoutsLimit = _periodTimeoutsLimit;
@synthesize actionArray = _actionArray;
@synthesize delegate = _delegate;
@synthesize state = _state;
@synthesize matchStateFinishingDate = _matchStateFinishingDate;

+ (ActionManager *)defaultManager{
    if (nil == sActionManager) {
        sActionManager = [[ActionManager alloc] init];
        sActionManager.state = MatchStatePrepare;
    }
    
    return sActionManager;
}

- (id)init{
    if (self = [super init]) {
    }
    
    return self;
}

- (NSInteger)homeTeamPoints{
    return _home.points;
}
- (NSInteger)homeTeamFouls{
    return _home.fouls;
}
- (NSInteger)homeTeamTimeouts{
    return _home.timeouts;
}

- (NSInteger)guestTeamPoints{
    return _guest.points;
}
- (NSInteger)guestTeamFouls{
    return _guest.fouls;
}
- (NSInteger)guestTeamTimeouts{
    return _guest.timeouts;
}

- (void)setPeriod:(NSInteger)period{    
    // 进入下一节时，清零犯规和暂停计数。
    if (period != _period) {
        _home.fouls = 0;
        _home.timeouts = 0;
        _guest.fouls = 0;
        _guest.timeouts = 0;
    }    
    
    _period = period;    
}

- (NSString *)nameForPeriod{
    NSString * periodString = nil;
    switch (_period) {
        case -1:
        case 0:
            periodString = @"1st";
            break;
        case 1: 
            periodString = @"2nd";
            break;
        case 2:
            periodString = @"3rd";
            break;
        case 3:
            periodString = @"4th";
            break;
        default:
            break;
    }  
    
    return periodString;
}

- (NSMutableArray *)actionsForMatch:(NSInteger)matchId{
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kActionEntity];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %d", kMatchField, matchId];
    
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

- (NSArray *)actionsWithType:(ActionType)actionType inPeriod:(NSInteger)period inActions:(NSArray *)actions{
    NSMutableArray * actionArray = [[NSMutableArray alloc] init];
    for (Action * action in actions) {
        if ([action.period integerValue] == period) {
            NSInteger tmpType = [action.type integerValue];
            if (actionType == tmpType){
                if (actionType == ActionTypeFoul || 
                    actionType == ActionTypeTimeout) {
                    [actionArray addObject:action];
                }
            }else if(actionType == ActionTypePoints){
                if (tmpType == ActionType1Point || 
                    tmpType == ActionType2Points || 
                    tmpType == ActionType3Points) {
                    [actionArray addObject:action];
                }
            }
        }        
    }
    
    return actionArray;
}

// TODO 这个接口还是不好，用_currentTeam来做函数间的联系人，不如用参数。
- (Action *)newActionInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time{
    // 暂停有总数限制，要先检查一下。
    if (actionType == ActionTypeTimeout) {
        // period发生改变时，意味着进入下一节，靠后续处理来清零犯规、暂停数据。        
        if (_currentTeam.timeouts  >= _periodTimeoutsLimit) {
            return nil;
        }
    }
    
    Action * action = (Action *)[NSEntityDescription insertNewObjectForEntityForName:kActionEntity 
                                                    inManagedObjectContext:self.managedObjectContext];
    action.type = [NSNumber numberWithInteger:actionType];
    action.match = match.id;
    action.period = [NSNumber numberWithInteger:_period];
    action.time = [NSNumber numberWithInteger:time];
    action.team = _currentTeam.teamId;   
    
    if( ![self synchroniseToStore]){
        // TODO should delete action object.
        return nil;
    } 
    
    [_actionArray insertObject:action atIndex:0];
    
    // 更新本场比赛实时数据。
    
    [_currentTeam addStatistic:actionType];
    
    // 如果超出单节允许犯规次数的话，就会带来一次罚球。
    if (actionType == ActionTypeFoul) {
        if (_currentTeam.fouls > _periodFoulsLimit) {
            if (( _delegate != nil ) && [_delegate respondsToSelector:@selector(FoulsBeyondLimit:)]) {
                [_delegate performSelector:@selector(FoulsBeyondLimit:) withObject:_currentTeam.teamId];
            }
        }
    }
    
    return action;
}

- (BOOL)actionForHomeTeamInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time{
    if (match) {
        _currentTeam = _home;
        if([self newActionInMatch:match withType:actionType atTime:time] != nil){
            return YES;
        } 
    }

    return NO;
}

- (BOOL)actionForGuestTeamInMatch:(Match *)match withType:(NSInteger)actionType atTime:(NSInteger)time{
    if (match) {
        _currentTeam = _guest;
        if ([self newActionInMatch:match withType:actionType atTime:time] != nil) {
            return YES;
        }
    }
    
    return NO;
}

// 删除实时比赛中的活动。
- (BOOL)deleteAction:(Action *)action{
    if (action) {
        NSInteger actionType = [action.type integerValue];
        NSInteger teamId = [action.team integerValue];
        
        // 从数据库删除该条记录。
        [self.managedObjectContext deleteObject:action];
        if(! [self synchroniseToStore]){
            return NO;
        }
        
        // 更新实时技术统计缓存TeamStatistics中的信息。
        TeamStatistics * __weak statistics = nil;
        if (teamId == [_home.teamId integerValue]) {
            statistics = _home;
        }else if(teamId == [_guest.teamId integerValue]){
            statistics = _guest;
        }
        
        [statistics subtractStatistic:actionType];
        
        // 从当前比赛action表中删除记录。
        [_actionArray removeObject:action];
        
        return YES;
    }else{
        return NO;
    }
}

// 删除实时比赛中的活动。
- (BOOL)deleteActionAtIndex:(NSInteger)index{
    if (index >= _actionArray.count) {
        NSLog(@"index beyond actionArray count");
        return NO;
    }
    
    return [self deleteAction:[_actionArray objectAtIndex:index]];
}

- (void)deleteActionsInMatch:(NSInteger)matchId{
    NSArray * actions = [self actionsForMatch:matchId];
    for (Action * action in actions) {
        [self deleteFromStore:action synchronized:NO];
    }
    
    [self synchroniseToStore];
}

- (void)resetRealtimeActions:(Match *)match{
    if (match) {
        _gameSettings = [GameSetting defaultSetting];
        
        _home = [[TeamStatistics alloc] initWithTeamId:match.homeTeam];
        _guest = [[TeamStatistics alloc] initWithTeamId:match.guestTeam];
        
        self.actionArray = [[NSMutableArray alloc] init];
        
        _period = -1;
        
        if ([match.mode isEqualToString:kGameModeFourQuarter]) {
            _periodLength = [_gameSettings.quarterLength integerValue];
            _periodFoulsLimit = [_gameSettings.foulsOverQuarterLimit integerValue];
            _periodTimeoutsLimit = [_gameSettings.timeoutsOverQuarterLimit integerValue];
        }else if([match.mode isEqualToString:kGameModeTwoHalf]){
            _periodLength = [_gameSettings.halfLength integerValue];
            _periodFoulsLimit = [_gameSettings.foulsOverHalfLimit integerValue];
            _periodTimeoutsLimit = [_gameSettings.timeoutsOverHalfLimit integerValue];
        }else if([match.mode isEqualToString:kGameModePoints]){
            _periodFoulsLimit = [_gameSettings.foulsOverWinningPointsLimit integerValue];
        }
    }
}

- (void)finishMatch:(Match *)match{
    if (nil != match) {
        match.homePoints = [NSNumber numberWithInteger: _home.points];
        match.guestPoints = [NSNumber numberWithInteger: _guest.points];
    }
    
    _home = nil;
    _guest = nil;
    _state = MatchStatePrepare;
}

- (NSURL *)documentURL{
    if (nil == _documentURL) {
        NSFileManager * fm = [NSFileManager defaultManager];
        NSArray * paths = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        
        NSURL * path = [paths objectAtIndex:0];
        _documentURL = [path URLByAppendingPathComponent:@"SuspendedMatch.dat" isDirectory:NO];
    }    
    
    return _documentURL;
}


@end
