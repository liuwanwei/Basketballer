//
//  StartGameViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"
#import "SingleChoiceViewController.h"

@protocol SingleChoiceViewDelegate;

@interface StartGameViewController : UITableViewController <SingleChoiceViewDelegate>

@property (nonatomic, weak) IBOutlet UITableViewCell * modeCell;
@property (nonatomic, weak) UITableViewCell * teamCell;
@property (nonatomic, weak) IBOutlet UIView * startMatchView;

- (void)refreshTableData:(Team *) team;
- (IBAction)startGame:(id)sender;

@end
