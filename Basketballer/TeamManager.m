//
//  TeamManager.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TeamManager.h"
#import "MatchManager.h"
#import "AppDelegate.h"
#import "PlayerManager.h"
#import "ImageManager.h"

static TeamManager * sDefaultManager;

@interface TeamManager (){
    NSMutableArray * _allTeams;
    NSMutableArray * _availableTeams;
    
    NSString * _teamProfilePrefix;
    NSString * _teamProfileExtension;
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

- (id)init{
    if (self = [super init]) {
//        _teamProfilePrefix = @"TeamProfile_";
//        _teamProfileExtension = @".png";
        
//        _imageCache = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)createDefaultTeams{
    NSString * defaultHomeTeamName = LocalString(@"DefaultTeam1");
    NSString * defaultGuestTeamName = LocalString(@"DefaultTeam2");

    UIImage * image;
    Team * team;    
    PlayerManager * pm = [PlayerManager defaultManager];

    image = [UIImage imageNamed:@"DefaultHomeTeam"];
    team = [self newTeam:defaultHomeTeamName withImage:image];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:23] withName:@"Michael Jordan"];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:33] withName:@"Scottie Pippen"];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:91] withName:@"Dennis Rodman"];
    
    image = [UIImage imageNamed:@"DefaultGuestTeam"];
    team = [self newTeam:defaultGuestTeamName withImage:image];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:12] withName:@"John Stockton"];    
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:14] withName:@"Jeff Hornacek"];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:32] withName:@"Karl Malone"];
}

- (void)loadTeams{
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kTeamEntity];
    
    NSSortDescriptor * sortDescripter = [[NSSortDescriptor alloc] initWithKey:kTeamIdField ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescripter];
    
//    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == 0", kTeamDeleted];
//    request.predicate = predicate;
    
    NSError * error = nil;
    NSMutableArray * result = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (nil == result) {
        NSLog(@"team executeFetchRequest error");
        _allTeams = [[NSMutableArray alloc] init];
        return;
    }
    
    if (result.count == 0) {
        _allTeams = [[NSMutableArray alloc] init];
        // 由于从不删除球队（只是修改enable标志）所以此处只会被执行一次
        [self createDefaultTeams];
    }else {
        _allTeams = result;        
    }
}

// 读取球队时，滤掉已删除球队信息。
- (NSMutableArray *)teams{
    if (_availableTeams != nil) {
        return _availableTeams;
    }else{
        NSMutableArray * availableTeams = nil;
        for (Team * team in _allTeams) {
            if ([team.deleted integerValue] != TeamDeleted) {
                if (nil == availableTeams) {
                    availableTeams = [[NSMutableArray alloc] init];
                }
                
                [availableTeams addObject:team];
            }
        }
        
        _availableTeams = availableTeams;
        return _availableTeams;        
    }
}

// 根据球队名称查询球队记录。
- (Team *)queryTeamWithName:(NSString *)name{
    for (Team * team in _allTeams) {
        if ([team.name isEqualToString:name]) {
            return team;
        }
    }
    return nil;
}

- (Team *)teamWithName:(NSString *)name{
    return [self queryTeamWithName:name];
}

- (Team *)teamWithId:(NSNumber *)id{
    for (Team * team in _allTeams){
        if ([team.id integerValue] == [id integerValue]){
            return team;
        }
    }
    return nil;
}

- (NSString *)teamNameWithDeletedStatus:(Team *)team{
    if ([team.deleted integerValue] == TeamDeleted) {
        static NSString * deletedAffix = @"(已删除)";
        NSString * name = [NSString stringWithFormat:@"%@%@", team.name, deletedAffix];
        return name;
    }else{
        return team.name;
    }
}

// 发送球队修改通知。
- (void)sendTeamChangedNotification{
    NSLog(@"before send %@", kTeamChanged);    
    NSNotification * notification = [NSNotification notificationWithName:kTeamChanged object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (BOOL)synchroniseToStore{
    BOOL ret = [super synchroniseToStore];
    if (ret) {
        [self sendTeamChangedNotification];
    }
    
    return ret;
}

- (Team *)newTeam:(NSString *)name withImage:(UIImage *)image{
    if (name == nil || name.length == 0) {
        return nil;
    }
    
    UIImage * teamProfile = image;
    
    if ([self queryTeamWithName:name] != nil) {
        return nil;
    }    
    
    Team * team = (Team *)[NSEntityDescription insertNewObjectForEntityForName:kTeamEntity 
                                                inManagedObjectContext:self.managedObjectContext];
    team.id = [BaseManager generateIdForKey:kTeamEntity];
    
    // 球队名字。
    team.name = name;

    // 球队标识图片。
    if (nil == teamProfile) {
        teamProfile = [UIImage imageNamed:@"DefaultTeamProfile"];
    }


    NSString * path = [[ImageManager defaultInstance] saveImage:teamProfile withProfileType:kProfileTypeTeam withObjectId:team.id];
    team.profileURL = path;

    
    [_allTeams insertObject:team atIndex:_allTeams.count];
    [self resetAvailableTeams];    
    
    if (! [self synchroniseToStore]) {
        [_allTeams removeObject:team];
        return nil;
    }
    
    return team;
}

- (void)resetAvailableTeams{
    // 强制- (NSMutableArray*)teams重新生成可用球队数组。
    _availableTeams = nil;
}

- (BOOL)deleteTeam:(Team *)team{
    NSArray * matches = [[MatchManager defaultManager] matchesWithTeamId:[team.id integerValue]];
    if (nil == matches || matches.count == 0) {
        // 该球队名下无比赛，可以直接删除。
        NSLog(@"actually delete team: %@", team.name);       
        [self deleteFromStore:team synchronized:NO];
        [_allTeams removeObject:team];
    }else{
        // 并不真的删除球队，而是修改删除标记。
        NSLog(@"mark team as deleted: %@", team.name);
        team.deleted = [NSNumber numberWithInteger:1];    
    }
    
    [self resetAvailableTeams];
    
    return [self synchroniseToStore];
}

- (BOOL)modifyTeam:(Team *)team withNewName:(NSString *)name{
    team.name = name;
    
    return [self synchroniseToStore];
}

- (BOOL)modifyTeam:(Team *)team withNewImage:(UIImage *)image{
    if (nil == image || team.profileURL == nil) {
        return  NO;
    }
    
    // 不改变图片路径，直接保存图片数据（覆盖到原路径中）。
    [[ImageManager defaultInstance] saveProfileImage:image toURL:[NSURL URLWithString:team.profileURL]];
    
    return [self synchroniseToStore];
}


@end
