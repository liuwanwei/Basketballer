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

static TeamManager * sDefaultManager;

@interface TeamManager (){
    NSMutableArray * _allTeams;
    NSMutableArray * _availableTeams;
    
    NSString * _teamProfilePrefix;
    NSString * _teamProfileExtension;
    
    NSMutableDictionary * _imageCache;
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
        _teamProfilePrefix = @"TeamProfile_";
        _teamProfileExtension = @".png";
        
        _imageCache = [[NSMutableDictionary alloc] init];
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

// 根据球队id，生成形如“file://xxx//xxx//id.png”形式的球队Logo保存路径。
- (NSURL *)profileImageURLGenerator:(NSString *)name{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    NSArray * paths = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    
    NSURL * documentDirectory = [paths objectAtIndex:0];
    
    NSString * filename = [NSString stringWithFormat:@"%@%@%@", _teamProfilePrefix, name, _teamProfileExtension];
    
    NSURL * profilePath = [documentDirectory URLByAppendingPathComponent:filename isDirectory:NO];
    
//    profilePath = [profilePath URLByAppendingPathComponent:filename isDirectory:NO];
    
    return profilePath;
}

// 发送球队修改通知。
- (void)sendTeamChangedNotification{
    NSLog(@"before send %@", kTeamChanged);    
    NSNotification * notification = [NSNotification notificationWithName:kTeamChanged object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)saveProfileImage:(UIImage *)image toURL:(NSURL *) url{
   // TODO 暂时制作本地存储，调通后再往iCloud里加。 
    NSData * data = UIImagePNGRepresentation(image);
    [data writeToURL:url atomically:YES];
}

- (void)setProfileImage:(UIImage *)image forTeam:(Team *)team{
    // 根据Team.id生成图片保存路径。    
    NSURL * imageURL = [self profileImageURLGenerator:[team.id stringValue]];
    
    // 保存图片路径到球队信息记录.
    NSString * profileURL = [imageURL absoluteString];
    NSRange range = [profileURL rangeOfString:@"/" options:NSBackwardsSearch];
    NSString * imageName = [profileURL substringFromIndex:range.location + 1];
    team.profileURL = imageName;
    
    // 保存图片到文件系统。
    [self saveProfileImage:image toURL:imageURL];
    
    // 更新图片缓存。
    [_imageCache setObject:image forKey:team.profileURL];
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

    [self setProfileImage:teamProfile forTeam:team];
    
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
    [self saveProfileImage:image toURL:[NSURL URLWithString:team.profileURL]];
    [_imageCache setObject:image forKey:team.profileURL];
    
    return [self synchroniseToStore];
}

- (UIImage *)imageForTeam:(Team *)team{
    UIImage * image = nil;
    if (nil == team || nil == team.profileURL) {
        return nil;
    }
    
    image = [_imageCache objectForKey:team.profileURL];
    if (image) {
        return image;
    }else{
        NSFileManager * fm = [NSFileManager defaultManager];
        NSArray * paths = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL * documentDirectory = [paths objectAtIndex:0];
        
        NSURL * url;
        NSString * imageName = team.profileURL;
        if ([team.profileURL hasPrefix:@"file://"]) {
            NSRange range = [team.profileURL rangeOfString:@"/" options:NSBackwardsSearch];
            imageName = [team.profileURL substringFromIndex:range.location + 1];
        }
        
        url = [documentDirectory URLByAppendingPathComponent:imageName];
        NSData * data = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:data]; 
        [_imageCache setObject:image forKey:team.profileURL];
    }
    
    return image;
}

@end
