//
//  MatchUnderwaySettingViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameSettingViewController.h"

@interface UnderwaySettingViewController : GameSettingViewController

@property (nonatomic, weak) IBOutlet UITableViewCell * playerStatisticsSwitch;

- (IBAction)switchValueChanged:(id)sender;

@end
