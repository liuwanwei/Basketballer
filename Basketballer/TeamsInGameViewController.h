//
//  TeamsInGameViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamsInGameViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UITableViewCell * teamCell;
@property (nonatomic, weak) IBOutlet UIImageView * homeImageView;
@property (nonatomic, weak) IBOutlet UIImageView * guestImageView;
@property (nonatomic ,weak) IBOutlet UIButton * startMatchButton;

- (IBAction)homeImageTouched:(id)sender;
- (IBAction)guestImageTouched:(id)sender;
- (IBAction)startMatchTouched:(id)sender;

@end
