//
//  EditTeamInfoViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTeamInfoViewController : UITableViewController <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic) NSInteger teamType;
@property (nonatomic, strong) NSArray * rowsTitle;

@end
