//
//  MatchSettingViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaseRule;

@interface GameSettingViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableViewCell * switchCell;

@property (nonatomic, strong) BaseRule * ruleInUse;

@end





