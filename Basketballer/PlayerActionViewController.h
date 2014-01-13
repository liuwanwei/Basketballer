//
//  PlayerActionViewController.h
//  Basketballer
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
