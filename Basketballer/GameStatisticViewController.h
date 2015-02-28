//
//  GameDetailsViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameSetting.h"
#import "Match.h"
//#import "UMSNSService.h"

@interface GameStatisticViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView * homeImageView;
@property (nonatomic, weak) IBOutlet UIImageView * guestImageView;
@property (nonatomic, weak) IBOutlet UILabel * homeLabel;
@property (nonatomic, weak) IBOutlet UILabel * guestLabel;
@property (nonatomic, weak) IBOutlet UILabel * dateLabel;

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UITableViewCell * tvCell;

@property (nonatomic, weak) IBOutlet UIBarButtonItem * actionItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem * trashItem;

@property (nonatomic, weak) Match * match;

//- (void)reloadActionsInMatch;

- (IBAction)showActionMenu;
- (IBAction)deleteMatch;

@end
