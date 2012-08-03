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
#import "ActionManager.h"
#import "TeamManager.h"

static MatchManager * sDefaultManager;

@implementation MatchManager

@synthesize matchesArray = _matchesArray;

+ (MatchManager *)defaultManager{
    if (sDefaultManager == nil) {
        sDefaultManager = [[MatchManager alloc] init];
    }
    return sDefaultManager;
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
    
    return newOne;
}

- (Match *)newMatchWithMode:(NSString *)mode withHomeTeam:(Team *)home withGuestTeam:(Team *)guestTeam{
    Match * newOne = [self newMatchWithMode:mode];
    if (newOne != nil) {
        newOne.homeTeam = home.id;
        newOne.guestTeam = guestTeam.id;
        
        [self synchroniseToStore];
        
        [[ActionManager defaultManager] resetRealtimeActions:newOne];        
    }
    
    return newOne;
}

- (void)startMatch:(Match *)match{
    
}

// TODO 放到重载的synchronizedToStore中去。
- (void)postNotification{
    // 发送比赛结束消息。
    NSNotification * notification = [NSNotification notificationWithName:kMatchChanged object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)finishMatch:(Match *)match{
    // 计算并更新比赛信息中的得分记录字段。
    [[ActionManager defaultManager] finishMatch:match];
    [self synchroniseToStore];
    
    [self postNotification];
}

- (void)stopMatch:(Match *)match withState:(MatchState)state{
    [[ActionManager defaultManager] finishMatch:match];
    match.state = [NSNumber numberWithInteger:state];
    [self synchroniseToStore];
    
    [self postNotification];
}

- (BOOL)deleteMatch:(Match *)match{
    NSInteger homeTeamId = [match.homeTeam integerValue];
    NSInteger guestTeamId = [match.guestTeam integerValue];
    NSInteger matchId = [match.id integerValue];
    
    if (! [self deleteFromStore:match synchronized:YES]) {
        return NO;
    }
    
    [self.matchesArray removeObject:match];
    
    [[ActionManager defaultManager] deleteActionsInMatch:matchId];
    
    // 删除比赛时，如球队已经被删除并且再无比赛记录，此时可以彻底删除球队。
    TeamManager * tm = [TeamManager defaultManager];
    Team * team = [tm teamWithId:[NSNumber numberWithInteger:homeTeamId]];
    if ([team.deleted integerValue] == TeamDeleted) {
        [tm deleteTeam:team];
    }
    
    team = [tm teamWithId:[NSNumber numberWithInteger:guestTeamId]];
    if ([team.deleted integerValue] == TeamDeleted) {
        [tm deleteTeam:team];
    }

    [self postNotification];
    
    return YES;
}

// 查询一个球队参与的所有比赛信息。
- (NSArray *)matchesWithTeamId:(NSInteger)teamId{
    NSMutableArray * teamMatches = nil;
    for (Match * match in _matchesArray) {
        if ([match.homeTeam integerValue] == teamId ||
            [match.guestTeam integerValue] == teamId) {
            if (nil == teamMatches) {
                teamMatches = [NSMutableArray arrayWithObject:match];
            }else{
                [teamMatches addObject:match];
            }
        }
    }
    
    return teamMatches;
}

// 判断两个日期的年月日是否相等。将日期转换成字符串，再比较字符串是否相等。
- (BOOL)date:(NSDate *)date equalToDate:(NSDate *)otherDate{
    static NSDateFormatter * dateFormatter = nil;
    if (nil == dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    NSString * dateString = [dateFormatter stringFromDate:date];
    NSString * otherString = [dateFormatter stringFromDate:otherDate];
    return [dateString isEqualToString:otherString];    
}

// TODO 最好使用category方式，将这个函数加到Match类的扩展中去。
- (NSInteger)winnerForMatch:(Match *)match{
    NSNumber * winner;
    NSComparisonResult result = [match.homePoints compare:match.guestPoints];
    winner = (result == NSOrderedDescending ? match.homeTeam : match.guestTeam);
    return [winner integerValue];
}

// date == nil : 获取球队历史总战绩。
// date == 某天 : 获取某天球队的总战绩。
- (NSDictionary *)statisticsForTeam:(NSInteger)teamId onDate:(NSDate *)date{    
    NSInteger winnings = 0, losings = 0;
    NSArray * matches = [self matchesWithTeamId:teamId];
    for (Match * match in matches) {
        if (date == nil || [self date:match.date equalToDate:date]) {
            if ([self winnerForMatch:match] == teamId) {
                winnings ++;
            }else{
                losings ++;
            }
        }
    }
    
    NSNumber * winningCount = [NSNumber numberWithInteger:winnings];
    NSNumber * losingCount = [NSNumber numberWithInteger:losings];
    
    NSDictionary * result = [NSDictionary dictionaryWithObjectsAndKeys:winningCount, kWinning, losingCount, kLosing, nil];

    return result;
}


@end
