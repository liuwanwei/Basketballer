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

@interface GameDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

//@property (nonatomic, weak) IBOutlet UILabel * teams;
//@property (nonatomic, weak) IBOutlet UILabel * dateTime;
//@property (nonatomic, weak) IBOutlet UISegmentedControl * actionFilter;

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UITableViewCell * tvCell;
//@property (nonatomic, weak) IBOutlet UITableViewCell * actionFilterCell;
//@property (nonatomic, weak) IBOutlet UIView * tableHeaderView;

@property (nonatomic, weak) IBOutlet UIBarButtonItem * actionItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem * trashItem;

@property (nonatomic, weak) Match * match;

- (void)reloadActionsInMatch;

- (IBAction)actionSheetForMatch;
- (IBAction)deleteCurrentMatch;

@end
