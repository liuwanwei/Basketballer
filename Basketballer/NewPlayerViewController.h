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

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) ImageCell * imageCell;

@property (nonatomic, weak) Player * model;

@property (nonatomic, weak) NSNumber * team;
@property (nonatomic, copy) NSNumber * playerNumber;
@property (nonatomic, copy) NSString * playerName;
@property (nonatomic, strong) UIImage * playerImage;

//@property (nonatomic, weak) UIViewController * parentWhoPresentedMe;

@end
