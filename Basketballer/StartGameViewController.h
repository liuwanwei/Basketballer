//
//  StartGameViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"
#import "SingleChoiceViewController.h"
#import "FXLabel.h"

@interface StartGameViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIView * inspirationView;
@property (nonatomic ,weak) IBOutlet FXLabel * label1;
@property (nonatomic ,weak) IBOutlet FXLabel * label2;

@end
