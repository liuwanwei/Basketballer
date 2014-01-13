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

- (id)init{
    if (self = [super init]) {
    }
    
    return self;
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

- (NSMutableDictionary *)statisticsForTeam:(NSNumber *)team inPeriod:(NSInteger)period inActions:(NSArray *)actions{
    NSInteger teamId = [team integerValue];
    NSInteger pts = 0, pf = 0, threePM = 0, ft = 0;
    for (Action * action in actions) {
        NSInteger tempPeriod = [action.period integerValue];
        NSInteger tempTeamId = [action.team integerValue];
        if (tempTeamId == teamId && (MatchPeriodAll == period || tempPeriod == period)) {
            NSInteger actionType = [action.type integerValue];
            switch (actionType) {
                case ActionType1Point:
                    pts ++;
                    ft ++;
                    break;
                case ActionType2Points:
                    pts += 2;
                    break;
                case ActionType3Points:
                    pts += 3;
                    threePM += 3;
                    break;
                case ActionTypeFoul:
                    pf += 1;
                    break;
                default:
                    break;
            }
        }
    }
    
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[NSString stringWithFormat:@"%d", pts] forKey:kPoints];
    [dictionary setObject:[NSString stringWithFormat:@"%d", pf] forKey:kPersonalFouls];
    [dictionary setObject:[NSString stringWithFormat:@"%d", threePM] forKey:k3PointMade];
    [dictionary setObject:[NSString stringWithFormat:@"%d", ft] forKey:kFreeThrow];
    
    return dictionary;
}

// 目前只计算全场技术统计，但暂时保留period参数，因为我还不确定个人单节技术统计是否真的没有必要。
- (NSMutableDictionary *)statisticsForPlayer:(NSNumber *)playerId inActions:(NSArray *)actions{
    NSInteger pts = 0, pf = 0, threePM = 0, ft = 0;
    for(Action * action in actions){
        if (playerId != nil && [action.player isEqualToNumber:playerId]) {
            switch([action.type integerValue]){
                case ActionType1Point:
                    pts ++;
                    ft ++;
                    break;
                case ActionType2Points:
                    pts += 2;
                    break;
                case ActionType3Points:
                    pts += 3;
                    threePM += 3;
                    break;
                case ActionTypeFoul:
                    pf += 1;
                    break;
                default:
                    break;
            }
        }
    }
    
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[NSString stringWithFormat:@"%d", pts] forKey:kPoints];
    [dictionary setObject:[NSString stringWithFormat:@"%d", pf] forKey:kPersonalFouls];
    [dictionary setObject:[NSString stringWithFormat:@"%d", threePM] forKey:k3PointMade];
    [dictionary setObject:[NSString stringWithFormat:@"%d", ft] forKey:kFreeThrow];
    return dictionary;
}

@end
