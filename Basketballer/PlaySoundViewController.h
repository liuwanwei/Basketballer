//
//  PlaySoundViewController.h
//  Basketballer
//
//  Created by maoyu on 12-9-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaySoundViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UIButton * cancelButton;

//- (IBAction)back:(id)sender;

@end
