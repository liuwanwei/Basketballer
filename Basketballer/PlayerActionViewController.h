//
//  PlayerActionViewController.h
//  比赛中选择球员界面
//
//  Created by Liu Wanwei on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayerEditViewController.h"

@interface PlayerActionViewController : PlayerListViewController

@property (nonatomic, strong) NSArray * actionsInMatch;
@property (nonatomic) NSInteger actionType;

@property (nonatomic, weak) IBOutlet UITableViewCell * playerActionCell;
@end
