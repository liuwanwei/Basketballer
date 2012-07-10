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
    NSString * _teamProfileDirectory;
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
        _teamProfileDirectory = @"TeamProfiles";
        _teamProfileExtension = @".png";
    }
    
    return self;
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

// 根据球队id，生成形如“file://xxx//xxx//id.png”形式的球队Logo保存路径。
- (NSURL *)profileImageURLGenerator:(NSNumber *)teamId{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    NSArray * paths = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    
    NSURL * documentDirectory = [paths objectAtIndex:0];
    
    NSURL * profilePath = [documentDirectory URLByAppendingPathComponent:_teamProfileDirectory isDirectory:YES];
    
    NSString * filename = [NSString stringWithFormat:@"%d%@", [teamId integerValue], _teamProfileExtension];
    
    profilePath = [profilePath URLByAppendingPathComponent:filename isDirectory:NO];
    
    return profilePath;
}

- (void)saveProfileImage:(UIImage *)image toURL:(NSURL *) url{
   // TODO 暂时制作本地存储，调通后再往iCloud里加。 
    NSData * data = UIImagePNGRepresentation(image);
    [data writeToURL:url atomically:YES];
}

- (Team *)newTeam:(NSString *)name withImage:(UIImage *)image{
    // TODO check if name is already exist.
    
    if (name == nil || name.length == 0) {
        return nil;
    }
    
    Team * team = (Team *)[NSEntityDescription insertNewObjectForEntityForName:kTeamEntity inManagedObjectContext:self.managedObjectContext];
    
    team.id = [self idGenerator];
    team.name = name;

    if (image != nil) {
        // 生成图片保存路径。
        NSURL * imageURL = [self profileImageURLGenerator:team.id];
        
        // 保存图片到文件系统。
        [self saveProfileImage:image toURL:imageURL];    
        
        // 保存图片路径到球队信息记录。
        team.profileURL = [imageURL absoluteString];
    }
    
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

- (BOOL)modifyTeam:(Team *)team withNewName:(NSString *)name{
    team.name = name;
    
    return [self synchroniseToStore];
}

- (BOOL)modifyTeam:(Team *)team withNewImage:(UIImage *)image{
    if (nil == image) {
        return  NO;
    }
    
    if (nil == team.profileURL) {
        // 创建文件保存路径，并保存文件。
        
        // 生成图片保存路径。
        NSURL * imageURL = [self profileImageURLGenerator:team.id];
        
        // 保存图片到文件系统。
        [self saveProfileImage:image toURL:imageURL];    
        
        // 保存图片路径到球队信息记录。
        team.profileURL = [imageURL absoluteString];
    }else{
        // 仅修改保存过的文件。
        
        // TODO test if equal to NSURL saved
        NSURL * imageURL = [NSURL URLWithString:team.profileURL];   
        
        [self saveProfileImage:image toURL:imageURL];
    }
    
    return [self synchroniseToStore];
}


@end
