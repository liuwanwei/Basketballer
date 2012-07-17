//
//  EditTeamInfoViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Team;

typedef enum {
    Insert = 1,
    Update = 2
} OperateMode;

@interface EditTeamInfoViewController : UITableViewController <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) NSArray * rowsTitle;
@property (nonatomic) NSInteger operateMode;
@property (nonatomic, weak) Team * team;
@property (nonatomic, weak) IBOutlet UIButton * delTeamBtn;

- (void) refreshViewWithTeamName:(NSString *) teamName;
- (IBAction)delTeam:(id)sender;
@end
