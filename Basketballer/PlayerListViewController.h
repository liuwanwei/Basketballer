//
//  PlayerListViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionManager.h"
#import "PlayerManager.h"

typedef enum{
    PlayerListViewModeEditPlayer = 0,
    PlayerListViewModeAddAction,
    PlayerListViewModeStatistics
}PlayerListViewMode;

// 动作已经确定，可以添加动作的消息。
#define kActionDetermined         @"NewActionDetermined"

@interface PlayerListViewController : UITableViewController

@property (nonatomic, weak) NSNumber * teamId;
@property (nonatomic, strong) NSArray * players;
//@property (nonatomic) PlayerListViewMode mode;

- (void)initWithTeamId:(NSNumber *)teamId;

@end
