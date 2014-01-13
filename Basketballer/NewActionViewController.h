//
//  NewActionViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Team;
@class TeamStatistics;

@interface NewActionViewController : UITableViewController

@property (nonatomic, weak) Team * team;
@property (nonatomic, weak) TeamStatistics * statistics;

@end
