//
//  NewPlayerViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Player.h"

@class ImageCell;

@interface NewPlayerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel * numberLabel;
@property (nonatomic, weak) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) IBOutlet UITextField * number;
@property (nonatomic, weak) IBOutlet UITextField * name;
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) ImageCell * imageCell;

@property (nonatomic, weak) Player * player;
@property (nonatomic, weak) NSNumber * team;

@property (nonatomic, weak) UIViewController * parentWhoPresentedMe;

@end
