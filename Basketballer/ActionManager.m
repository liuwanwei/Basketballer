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
#import "BaseRule.h"
#import "MatchUnderWay.h"

static ActionManager * sActionManager;

@interface ActionManager(){
//    GameSetting * _gameSettings;  
    
    NSURL * _documentURL;
    
    NSArray * _matchPeriodNameFor4Quarter;
    NSArray * _matchPeriodNameFor2Half;
}
@end


@implementation ActionManager

@synthesize actionArray = _actionArray;

+ (ActionManager *)defaultManager{
    if (nil == sActionManager) {
        sActionManager = [[ActionManager alloc] init];
    }
    
    return sActionManager;
}

+ (BOOL)isTimeoutAction:(ActionType)actionType{
    return (actionType == ActionTypeTimeoutShort || 
            actionType == ActionTypeTimeoutRegular || 
            actionType == ActionTypeTimeoutOfficial);
}

+ (BOOL)isPointAction:(ActionType)actionType{
    return (actionType == ActionType1Point ||
            actionType == ActionType2Points ||
            actionType == ActionType3Points);
}

+ (BOOL)isFoulAction:(ActionType)actionType{
    return (actionType == ActionTypeFoul);
}

+ (NSString *)descriptionForActionType:(ActionType)actionType{
    NSString * desc = @"Unknown~";
    switch (actionType) {
        case ActionType1Point:
            desc = @"罚球+1分";
            break;
        case ActionType1PointMissed:
            desc = @"罚球未进";
            break;
        case ActionType2Points:
            desc = @"投篮+2分";
            break;
        case ActionType2PointMissed:
            desc = @"投篮未进";
            break;
        case ActionType3Points:
            desc = @"三分+3分";
            break;
        case ActionType3PointMissed:
            desc = @"三分未进";
            break;
        case ActionTypeAssist:
            desc = @"助攻";
            break;
        case ActionTypeRebound:
            desc = @"篮板";
            break;
        case ActionTypeReboundBackField:
            desc = @"后场篮板";
            break;
        case ActionTypeReboundForeField:
            desc = @"前场篮板";
            break;
        case ActionTypeTurnOver:
            desc = @"失误";
            break;
        case ActionTypeSteal:
            desc = @"抢断";
            break;
        case ActionTypeFoul:
            desc = @"犯规";
            break;
        case ActionTypeOffenciveFoul:
            desc = @"进攻犯规";
            break;
        case ActionTypeDefenciveFoul:
            desc = @"防守犯规";
            break;
        case ActionTypeTimeoutShort:
            desc = @"短暂停";     // NBA
            break;
        case ActionTypeTimeoutOfficial:
            desc = @"官方暂停";   // NBA
            break;
        case ActionTypeTimeoutRegular:
            desc = @"常规暂停";
            break;
        default:
            break;
    }
    
    return desc;
}

+ (NSString *)shortDescriptionForActionType:(ActionType)actionType{
    switch (actionType) {
        case ActionType1Point:
            return @"罚球";
        case ActionType2Points:
            return @"投篮";
        case ActionType3Points:
            return @"三分球";
        case ActionTypeRebound:
            return @"篮板";
        case ActionTypeAssist:
            return @"助攻";
        case ActionTypeTurnOver:
            return @"失误";
        case ActionTypeFoul:
            return @"犯规";
        case ActionTypeSteal:
            return @"抢断";               // 暂未支持
        default:
            break;
    }
    
    return @"Miss";
}

// 取出一场比赛中的所有技术统计
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
            object = [[NSNumber alloc] initWithInteger:addition];
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
                    actionType == ActionTypeTimeoutRegular) {
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

- (Action *)newActionForTeam:(NSNumber *)teamId forPlayer:(NSNumber *)playerId withType:(NSInteger)actionType atTime:(NSInteger)time inPeriod:(MatchPeriod)period{
    
    Action * action = (Action *)[NSEntityDescription insertNewObjectForEntityForName:kActionEntity 
                                                    inManagedObjectContext:self.managedObjectContext];
    action.type = [NSNumber numberWithInteger:actionType];
    action.match = [MatchUnderWay defaultMatch].match.id;
    action.player = playerId;
    action.period = [NSNumber numberWithInteger:period];
    action.time = [NSNumber numberWithInteger:time];
    action.team = teamId;   
    
    if( ![self synchroniseToStore]){
        // TODO should delete action object.
        return nil;
    } 
    
    [_actionArray insertObject:action atIndex:0];
    
    return action;
}


// 删除实时比赛中的活动。
- (BOOL)deleteAction:(Action *)action{
    if (action) {
        // 从当前比赛action表中删除记录。
        [_actionArray removeObject:action];        
        
        // 从数据库删除该条记录。
        [self.managedObjectContext deleteObject:action];
        if(! [self synchroniseToStore]){
            return NO;
        }
        
        // 发送消息
        NSNotification * notification = nil;
        notification = [NSNotification notificationWithName:kDeleteActionMessage object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        return YES;
    }else{
        return NO;
    }
}

- (void)deleteActionsInMatch:(NSInteger)matchId{
    NSArray * actions = [self actionsForMatch:matchId];
    for (Action * action in actions) {
        [self deleteFromStore:action synchronized:NO];
    }
    
    [self synchroniseToStore];
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

- (Statistics *)statisticsForTeam:(NSNumber *)team inPeriod:(NSInteger)period inActions:(NSArray *)actions{
    Statistics * statistics = [[Statistics alloc] init];
    NSInteger teamId = [team integerValue];
    
    for (Action * action in actions) {
        NSInteger tempPeriod = [action.period integerValue];
        NSInteger tempTeamId = [action.team integerValue];
        
        if (tempTeamId == teamId && (MatchPeriodAll == period || tempPeriod == period)) {
            [self addAction:action toStatistics:statistics];
        }
    }
    
    return statistics;
}

- (NSDictionary *)periodPointsForTeam:(NSNumber *)team inActions:(NSArray *)actions{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSInteger teamId = [team integerValue];
    
    for (Action * action in actions) {
        NSInteger tempTeamId = [action.team integerValue];
        ActionType actionType = (ActionType)[action.type integerValue];
        if (tempTeamId != teamId || ![[self class] isPointAction:actionType]) {
            continue;
        }
        
        if ([action.period integerValue] >= MatchPeriodOvertime) {
            // 计算加时赛总得分
            Statistics * overTime = dict[@(MatchPeriodOvertime)];
            if (overTime == nil) {
                overTime = [[Statistics alloc] init];
                dict[@(MatchPeriodOvertime)] = overTime;
            }
            [self addAction:action toStatistics:overTime];
            
        }else{
            // 结算每个小结得分
            id statistics = dict[action.period];
            if (dict[action.period] == nil) {
                statistics = [[Statistics alloc] init];
                dict[action.period] = statistics;
            }
            [self addAction:action toStatistics:statistics];

        }
    }
    
    return dict;
}

// 目前只计算全场技术统计，但暂时保留period参数，因为我还不确定个人单节技术统计是否真的没有必要。
- (Statistics *)statisticsForPlayer:(NSNumber *)playerId inActions:(NSArray *)actions{
    Statistics * statistics = [[Statistics alloc] init];
    statistics.playerId = playerId;
    for(Action * action in actions){
        if (playerId != nil && [action.player isEqualToNumber:playerId]) {
            [self addAction:action toStatistics:statistics];
        }
    }

    return statistics;
}

- (void)addAction:(Action *)action toStatistics:(Statistics *)statistics{
    ActionType actionType = (ActionType)[action.type integerValue];
    
    switch(actionType){
        case ActionType1Point:
            statistics.points ++;
            statistics.onePoint ++;
            break;
        case ActionType2Points:
            statistics.points += 2;
            break;
        case ActionType3Points:
            statistics.points += 3;
            statistics.threePoints += 3;
            break;
        case ActionTypeRebound:
            statistics.rebounds ++;
            break;
        case ActionTypeAssist:
            statistics.assistants ++;
            break;
        case ActionTypeFoul:
            statistics.fouls ++;
            break;
        case ActionTypeTimeoutOfficial:
        case ActionTypeTimeoutRegular:
        case ActionTypeTimeoutShort:
            statistics.timeouts ++;
            break;
        default:
            NSLog(@"未处理的技术统计类型");
            break;
    }
}

@end
