//
//  EditTeamNameViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditTeamInfoViewController;

@interface EditTeamNameViewController : UIViewController

@property (nonatomic, weak) EditTeamInfoViewController * parentController;
@property (nonatomic, weak) NSString * teamName;
@property (nonatomic, weak) IBOutlet UITextField * teamNameText;

@end
