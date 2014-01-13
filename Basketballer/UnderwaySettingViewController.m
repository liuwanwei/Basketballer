//
//  MatchUnderwaySettingViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UnderwaySettingViewController.h"
#import "GameSetting.h"

@interface UnderwaySettingViewController ()

@end

@implementation UnderwaySettingViewController
@synthesize playerStatisticsSwitch = _playerStatisticsSwitch;

- (IBAction)switchValueChanged:(id)sender{
    UISwitch * object = (UISwitch *)sender;
    [[GameSetting defaultSetting] setEnablePlayerStatistics:object.on];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
       
        return self.settingsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section) {
        [[NSBundle mainBundle] loadNibNamed:@"PlayerStatisticsSwitchCell" owner:self options:nil];
        UITableViewCell * cell = _playerStatisticsSwitch;
        self.playerStatisticsSwitch = nil;
        
        UISwitch * object = (UISwitch *)[cell.contentView viewWithTag:1];
        [object setOn:[GameSetting defaultSetting].enablePlayerStatistics];        
        
        return cell;
        
    }else{
       return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

@end
