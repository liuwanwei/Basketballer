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

@interface TeamManager (){
    NSString * _teamProfilePrefix;
    NSString * _teamProfileExtension;
    
    NSString * _defaultHomeTeamName;
    NSString * _defaultGuestTeamName;
    NSString * _defaultProfileImageName;
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
        _defaultHomeTeamName  = @"主队";
        _defaultGuestTeamName = @"客队";
        
        // Equal to default image in resource.
        _defaultProfileImageName = @"DefaultTeamProfile";
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
    
    NSError * error = nil;
    NSMutableArray * result = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (nil == result) {
        NSLog(@"team executeFetchRequest error");
        return;
    }
    
    if (result.count == 0) {
        self.teams = [[NSMutableArray alloc] init];
        [self createDefaultTeams];
    }else {
        self.teams = result;
    }
}

// 根据球队名称查询球队记录。
- (Team *)queryTeamWithName:(NSString *)name{
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kTeamEntity];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@", kTeamNameField, name];
    
    request.predicate = predicate;
    
    NSError * error = nil;
    NSMutableArray * result = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (nil == result) {
        NSLog(@"query team executeFetchRequest error");
        return nil;
    }else if(result.count == 0){
        return nil;
    }else {
        return [result objectAtIndex:0];
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

- (void)saveProfileImage:(UIImage *)image toURL:(NSURL *) url{
   // TODO 暂时制作本地存储，调通后再往iCloud里加。 
    NSData * data = UIImagePNGRepresentation(image);
    [data writeToURL:url atomically:YES];
}

- (void)setProfileImage:(UIImage *)image forTeam:(Team *)team{
    // 根据Team.id生成图片保存路径。    
    NSURL * imageURL = [self profileImageURLGenerator:[team.id stringValue]];
    
    // 保存图片到文件系统。
    [self saveProfileImage:image toURL:imageURL];
    
    // 保存图片路径到球队信息记录。    
    team.profileURL = [imageURL absoluteString];
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
    
    if (! [self synchroniseToStore]) {
        return nil;
    }
    
    [self.teams insertObject:team atIndex:self.teams.count];
    
    return team;
}

- (BOOL)deleteTeam:(Team *)team{
    if (! [self deleteFromStore:team]) {
        return NO;
    } 
    
    [self.teams removeObject:team];
    
    return YES;
}

- (BOOL)modifyTeam:(Team *)team withNewName:(NSString *)name{
    team.name = name;
    
    return [self synchroniseToStore];
}

- (BOOL)modifyTeam:(Team *)team withNewImage:(UIImage *)image{
    if (nil == image) {
        return  NO;
    }
    
    if (nil == team.profileURL || _defaultProfileImageName == team.profileURL) {
        // 用新设置的图片代替默认图片。
        [self setProfileImage:image forTeam:team];
    }else{
        // 覆盖保存过的文件。
        [self saveProfileImage:image toURL:[NSURL URLWithString:team.profileURL]];
    }
    
    return [self synchroniseToStore];
}

- (UIImage *)imageForTeam:(Team *)team{
    UIImage * image = nil;
    if(nil == team || nil == team.profileURL || [_defaultProfileImageName isEqualToString:team.profileURL]){
        image = [UIImage imageNamed:_defaultProfileImageName];
        return image;
    }else{
        NSURL * url = [NSURL URLWithString:team.profileURL];
        NSData * data = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:data]; 
    }
    
    return image;
}

@end
