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

static TeamManager * sDefaultManager;

@interface TeamManager (){
    NSMutableArray * _allTeams;
    NSMutableArray * _availableTeams;
    
    NSString * _teamProfilePrefix;
    NSString * _teamProfileExtension;
    
    NSString * _defaultHomeTeamName;
    NSString * _defaultGuestTeamName;
    NSString * _defaultProfileImageName;
    
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
        
        // TODO loading from i18n file.
        _defaultHomeTeamName  = @"主场球队";
        _defaultGuestTeamName = @"客场球队";
        
        // Equal to default image in resource.
        _defaultProfileImageName = @"DefaultTeamProfile";  
        
        _imageCache = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)createDefaultTeams{
    [self newTeam:_defaultHomeTeamName withImage:nil];
    [self newTeam:_defaultGuestTeamName withImage:nil];
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

// 生成一个不会重复的比赛id     
- (NSNumber *)idGenerator{
    NSMutableIndexSet * idSet = [[NSMutableIndexSet alloc] init];
    for (Team * object in _allTeams) {
        [idSet addIndex:[[object id] integerValue]];
    }
    
    NSInteger id = 0;
    while ([idSet containsIndex:id]) {
        id ++;
    }
    
    return [NSNumber numberWithInteger:id];
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

- (id)test{
    // NSURL and NSString object "KeNiXing" testing.
    NSURL * url = [self profileImageURLGenerator:@"ImageFile"];
    
    // NSURL 和 NSString 的可逆过程实例。
//    NSString * urlString = [url absoluteString];
//    NSURL * convertedUrl = [NSURL URLWithString:urlString];
//    return convertedUrl;

    UIImage * image2 = nil;
    UIImage * image = [UIImage imageNamed:_defaultProfileImageName];
    NSData * data = UIImagePNGRepresentation(image);
    if ([data writeToURL:url atomically:YES]) {
        NSData * data2 = [NSData dataWithContentsOfURL:url];
        if (nil != data2) {
            image2 = [UIImage imageWithData:data2];
        }
    }
    
    return image2;
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
    
    // 保存图片路径到球队信息记录。    
    team.profileURL = [imageURL absoluteString];    
    
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
    
    if ([self queryTeamWithName:name] != nil) {
        return nil;
    }    
    
    Team * team = (Team *)[NSEntityDescription insertNewObjectForEntityForName:kTeamEntity 
                                                inManagedObjectContext:self.managedObjectContext];
    
    // 生成一个“不会重复”的id
    team.id = [self idGenerator];
    
    // 球队名字。
    team.name = name;

    // 球队标识图片。
    if (image) {
        [self setProfileImage:image forTeam:team];
    }else{
        // 使用默认图片“DefaultTeamProfile.png”。
        team.profileURL = _defaultProfileImageName;
    }
    
    [_allTeams insertObject:team atIndex:_allTeams.count];
    [self resetAvailableTeams];    
    
    if (! [self synchroniseToStore]) {
        return nil;
    }else{
        // TODO 删除添加失败的Team对象。
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
    if (nil == image) {
        return  NO;
    }
    
    if (nil == team.profileURL || [_defaultProfileImageName isEqualToString:team.profileURL]) {
        // 用新设置的图片代替默认图片。
        [self setProfileImage:image forTeam:team];
    }else{
        // 覆盖保存过的文件。
        [self saveProfileImage:image toURL:[NSURL URLWithString:team.profileURL]];
        
        [_imageCache setObject:image forKey:team.profileURL];
    }
    
    return [self synchroniseToStore];
}

- (UIImage *)imageForTeam:(Team *)team{
    UIImage * image = nil;
    if(nil == team || nil == team.profileURL || [_defaultProfileImageName isEqualToString:team.profileURL]){
        image = [UIImage imageNamed:_defaultProfileImageName];
        return image;
    }else{
        image = [_imageCache objectForKey:team.profileURL];
        if (image) {
            return image;
        }else{
            NSURL * url = [NSURL URLWithString:team.profileURL];
            NSData * data = [NSData dataWithContentsOfURL:url];
            image = [UIImage imageWithData:data]; 
            [_imageCache setObject:image forKey:team.profileURL];
        }
    }
    
    return image;
}

@end
