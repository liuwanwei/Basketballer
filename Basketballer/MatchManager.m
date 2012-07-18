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

- (void)finishMatch:(Match *)match{
    // 计算并更新比赛信息中的得分记录字段。
    [[ActionManager defaultManager] finishMatch:match];
    [self synchroniseToStore];
    
    // 发送比赛结束消息。
    NSNotification * notification = [NSNotification notificationWithName:kMatchChanged object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (BOOL)deleteMatch:(Match *)match{
    NSInteger matchId = [match.id integerValue];
    
    if (! [self deleteFromStore:match synchronized:NO]) {
        return NO;
    }
    
    [self.matchesArray removeObject:match];
    
    [[ActionManager defaultManager] deleteActionsInMatch:matchId];
    
    return YES;
}

@end
