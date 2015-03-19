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
#import <TMCache.h>

static NSString * kAutoCreatedMyTeamId = @"AutoCreatedMyTeamId";

@interface TeamManager (){
    NSMutableArray * _allTeams;
    NSMutableArray * _availableTeams;
    
    NSString * _teamProfilePrefix;
    NSString * _teamProfileExtension;
}

@end

@implementation TeamManager

@synthesize teams = _teams;

+ (instancetype)defaultManager{
    static TeamManager * sDefaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sDefaultManager == nil) {
            sDefaultManager = [[TeamManager alloc] init];
        }
    });
    
    return sDefaultManager;
}

- (void)createDefaultTeams{
    NSString * defaultHomeTeamName = LocalString(@"DefaultTeam1");
    NSString * defaultGuestTeamName = LocalString(@"DefaultTeam2");

    UIImage * image;
    Team * team;    
    PlayerManager * pm = [PlayerManager defaultManager];

    image = [UIImage imageNamed:@"DefaultHomeTeam"];
    team = [self newTeam:defaultHomeTeamName withImage:image];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:23] withName:@"乔丹"];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:33] withName:@"皮蓬"];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:91] withName:@"罗德曼"];
    
    image = [UIImage imageNamed:@"DefaultGuestTeam"];
    team = [self newTeam:defaultGuestTeamName withImage:image];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:12] withName:@"斯托克顿"];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:14] withName:@"霍纳塞克"];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:32] withName:@"马龙"];
}

// 查询所有球队
- (void)loadTeams:(BOOL)needMyTeam{
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kTeamEntity];
    
    NSSortDescriptor * sortDescripter = [[NSSortDescriptor alloc] initWithKey:kTeamIdField ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescripter];
    
    NSError * error = nil;
    NSMutableArray * result = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (nil == result) {
        NSLog(@"team executeFetchRequest error");
        _allTeams = [[NSMutableArray alloc] init];
        return;
    }
    
    if (result.count == 0) {
        // 首次运行创建默认数据
        
        _allTeams = [[NSMutableArray alloc] init];
        // 放心！！！由于从不删除球队（只是修改enable标志）所以此处只会被执行一次
        [self createDefaultTeams];

        // 自动创建“我的球队”
        if (needMyTeam) {
            [self createMyTeam];
        }
        
    }else {
        _allTeams = result;
    }
    
    if (needMyTeam) {
        [self initMyTeam];
    }
}

// 自动创建自己球队（队长版使用），只会调用一次
- (void)createMyTeam{
    Team * team = [self newTeam:@"我的球队" withImage:[UIImage imageNamed:@"DefaultHomeTeam"]];
    [[TMDiskCache sharedCache] setObject:team.id forKey:kAutoCreatedMyTeamId];
    
    PlayerManager * pm = [PlayerManager defaultManager];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:23] withName:@"李雷"];
    [pm addPlayerForTeam:team.id withNumber:[NSNumber numberWithInt:33] withName:@"韩梅梅"];
}

- (void)initMyTeam{
    // 提取“我的球队”
    NSNumber * myTeamId = (NSNumber *)[[TMDiskCache sharedCache] objectForKey:kAutoCreatedMyTeamId];
    if (myTeamId != nil) {
        NSEnumerator * enurator = [_allTeams objectEnumerator];
        Team * object;
        while ((object = [enurator nextObject]) != nil) {
            if ([object.id isEqualToNumber:myTeamId]) {
                self.myTeam = object;
                break;
            }
        }
    }
}

// 读取球队时，滤掉已删除球队信息。
- (NSMutableArray *)teams{
    if (_availableTeams != nil) {
        return _availableTeams;
    }else{
        NSMutableArray * availableTeams = nil;
        for (Team * team in _allTeams) {
            if ([team.userDeleted integerValue] != TeamDeleted) {
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
- (Team *)teamWithName:(NSString *)name{
    for (Team * team in _allTeams) {
        if ([team.name isEqualToString:name]) {
            return team;
        }
    }
    return nil;
}

- (Team *)teamWithId:(NSNumber *)id{
    for (Team * team in _allTeams){
        if ([team.id compare:id] == NSOrderedSame){
            return team;
        }
    }
    return nil;
}

//- (NSString *)teamNameWithDeletedStatus:(Team *)team{
//    if ([team.userDeleted integerValue] == TeamDeleted) {
//        static NSString * deletedAffix = @"(已删除)";
//        NSString * name = [NSString stringWithFormat:@"%@%@", team.name, deletedAffix];
//        return name;
//    }else{
//        return team.name;
//    }
//}

- (BOOL)synchroniseToStoreWithTeam:(Team *)team{
    if ([super synchroniseToStore]) {
        
        // 发送球队修改通知。
        NSLog(@"before send %@", kTeamChanged);
        NSNotification * note;
        if (! team) {
            note = [NSNotification notificationWithName:kTeamChanged object:nil];
        }else{
            note = [NSNotification notificationWithName:kTeamChanged object:nil userInfo:@{ChangedTeamObject:team}];
        }
        
        [[NSNotificationCenter defaultCenter] postNotification:note];
        
        return YES;
    }
    
    return NO;
}

- (Team *)newTeam:(NSString *)name withImage:(UIImage *)image{
    if (name == nil || name.length == 0) {
        return nil;
    }
    
    UIImage * teamProfile = image;
    
    // 有同名球队时，直接返回该球队
    Team * existedTeam = [self teamWithName:name];
    if (existedTeam != nil) {
        return existedTeam;
    }    
    
    Team * team = (Team *)[NSEntityDescription insertNewObjectForEntityForName:kTeamEntity 
                                                inManagedObjectContext:self.managedObjectContext];
    team.id = [BaseManager generateIdForKey:kTeamEntity];
    
    // 球队名字。
    team.name = name;

    // 球队标识图片。
    if (nil == teamProfile) {
        teamProfile = [UIImage imageNamed:@"DefaultHomeTeam"];
    }

    NSString * path = [[ImageManager defaultInstance] saveImage:teamProfile withProfileType:kProfileTypeTeam withObjectId:team.id];
    team.profileURL = path;

    
    [_allTeams insertObject:team atIndex:_allTeams.count];
    [self resetAvailableTeams];    
    
    if (! [self synchroniseToStoreWithTeam:team]) {
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
        team.userDeleted = [NSNumber numberWithInteger:1];
    }
    
    [self resetAvailableTeams];
    
    return [self synchroniseToStoreWithTeam:nil];
}

- (BOOL)modifyTeam:(Team *)team withNewName:(NSString *)name{
    team.name = name;
    
    return [self synchroniseToStoreWithTeam:team];
}

- (BOOL)modifyTeam:(Team *)team withNewImage:(UIImage *)image{
    if (nil == image || team.profileURL == nil) {
        return  NO;
    }
    
    // 不改变图片路径，直接保存图片数据（覆盖到原路径中）。
    [[ImageManager defaultInstance] saveProfileImage:image toURL:[NSURL URLWithString:team.profileURL]];
    
    return [self synchroniseToStoreWithTeam:team];
}


@end
