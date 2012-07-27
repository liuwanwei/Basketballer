//
//  ActionRecordViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionRecordViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UINavigationItem * navItem;

@property (nonatomic, weak) NSArray * actionRecords;

@end
