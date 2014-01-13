//
//  PlayerStatisticsViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayerListViewController.h"

@interface PlayerStatisticsViewController : PlayerListViewController

@property (nonatomic, weak) IBOutlet UITableViewCell * tvCell;

@property (nonatomic, weak) NSArray * actionsInMatch;

@end
