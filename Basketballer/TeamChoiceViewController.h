//
//  TeamChoiceViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    UITeamChoiceViewControllerModeSet = 0,
    UITeamChoiceViewControllerModeChoose = 1,
}UITeamChoiceViewControllerMode;

@class StartGameViewController; 

@interface TeamChoiceViewController : UITableViewController

@property (nonatomic, weak) StartGameViewController * parentController;
@property (nonatomic, weak) UITableViewCell * teamCell;
@property (nonatomic) UITeamChoiceViewControllerMode viewControllerMode;

@property (nonatomic, weak)  NSNumber * choosedTeamId;

@end
