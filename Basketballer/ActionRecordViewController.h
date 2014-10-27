//
//  ActionRecordViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionRecordViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIImageView * hostImageView;
@property (nonatomic, weak) IBOutlet UIImageView * guestImageView;
@property (nonatomic, weak) IBOutlet UILabel * hostLabel;
@property (nonatomic, weak) IBOutlet UILabel * guestLabel;
@property (nonatomic, weak) IBOutlet UILabel * actionRecordLabel;
@property (nonatomic, weak) IBOutlet UITableView * tableView;

@end
