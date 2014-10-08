//
//  TeamManager.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseManager.h"
#import "Team.h"

#define kTeamEntity     @"Team"
#define kTeamNameField  @"name"
#define kTeamIdField    @"id"
#define kTeamDeleted    @"deleted"

#define kTeamChanged    @"TeamChangedNotification"

#define TeamDeleted     1

@interface TeamManager : BaseManager

@property (nonatomic, strong) NSMutableArray * teams;

+ (TeamManager *)defaultManager;

- (void)loadTeams;

// 查询球队。
- (Team *)queryTeamWithName:(NSString *)name;   // Deprecated, use "teamWithName:" instead.
- (Team *)teamWithName:(NSString *)name;
- (Team *)teamWithId:(NSNumber *)id;
- (NSString *)teamNameWithDeletedStatus:(Team *)team;

// 新增一支球队。
// name必须非空。
// image为空时，会自动把球队图片设置成默认图片。
- (Team *)newTeam:(NSString *)name withImage:(UIImage *)image;

- (BOOL)deleteTeam:(Team *)team;

// 修改球队属性时，请使用这两个接口。
- (BOOL)modifyTeam:(Team *)team withNewName:(NSString *)name;
- (BOOL)modifyTeam:(Team *)team withNewImage:(UIImage *)image;

@end
