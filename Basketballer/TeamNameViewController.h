//
//  EditTeamNameViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TeamInfoViewController;

@interface TeamNameViewController : UIViewController

@property (nonatomic, weak) TeamInfoViewController * parentController;
@property (nonatomic, weak) NSString * teamName;
@property (nonatomic, weak) IBOutlet UITextField * teamNameText;

@end
