//
//  TeamManager.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TeamManager.h"
#import "AppDelegate.h"

static TeamManager * sDefaultManager;

@interface TeamManager (){  // TODO this means constructor ?
    
}
@end

@implementation TeamManager

@synthesize teams = _teams;

+ (TeamManager *)defaultManager{
    if (sDefaultManager == nil) {
        sDefaultManager = [[TeamManager alloc] init];
    }
    
    return sDefaultManager;
}

- (void)createDefaultTeams{
    // TODO configure team images form local resource.
    [self newTeam:@"主队" withImage:nil];
    [self newTeam:@"客队" withImage:nil];
}

- (void)loadTeams{
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kTeamEntity];
    
    NSSortDescriptor * sortDescripter = [[NSSortDescriptor alloc] initWithKey:kTeamNameField ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescripter];
    
    NSError * error = nil;
    NSMutableArray * result = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (nil == result) {
        NSLog(@"team executeFetchRequest error");
        return;
    }
    
    // TODO if result equals to 0, add two default teams for home and guest.
    if (result.count == 0) {
        self.teams = [[NSMutableArray alloc] init];
        [self createDefaultTeams];
    }else {
        self.teams = result;
    }
}

// 生成一个不会重复的比赛id     
- (NSNumber *)idGenerator{
    NSMutableIndexSet * idSet = [[NSMutableIndexSet alloc] init];
    for (Team * object in _teams) {
        [idSet addIndex:[[object id] integerValue]];
    }
    
    NSInteger id = 0;
    while ([idSet containsIndex:id]) {
        id ++;
    }
    
    return [NSNumber numberWithInteger:id];
}

- (Team *)newTeam:(NSString *)name withImage:(NSURL *)imageURL{
    if (name == nil || name.length == 0) {
        return nil;
    }
    
    Team * team = (Team *)[NSEntityDescription insertNewObjectForEntityForName:kTeamEntity inManagedObjectContext:self.managedObjectContext];

    team.id = [self idGenerator];
    team.name = name;
    
    // TODO save UIImage object content to local file, and 
    // write to iCloud, save the iCloud URL for the file.
    team.profileURL = [imageURL absoluteString];
    
    if (! [self synchroniseToStore]) {
        return nil;
    }
    
    [self.teams insertObject:team atIndex:0];

    return team;
}

- (BOOL)deleteTeam:(Team *)team{
    if (! [self deleteFromStore:team]) {
        return NO;
    } 
    
    [self.teams removeObject:team];
    
    return YES;
}

- (BOOL)modifyTeam:(Team *)team{
    return [self synchroniseToStore];
}

@end
