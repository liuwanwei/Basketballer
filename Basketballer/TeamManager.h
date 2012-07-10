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

@interface TeamManager : BaseManager

@property (nonatomic, strong) NSMutableArray * teams;

+ (TeamManager *)defaultManager;

- (void)loadTeams;

- (Team *)newTeam:(NSString *)name withImage:(UIImage *)image;

- (BOOL)deleteTeam:(Team *)team;

- (BOOL)modifyTeam:(Team *)team withNewName:(NSString *)name;
- (BOOL)modifyTeam:(Team *)team withNewImage:(UIImage *)image;

@end
