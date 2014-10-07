//
//  PlayerStatisticsViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayerStatisticsViewController.h"
#import "GameStatisticViewController.h"
#import "StatisticSectionHeaderView.h"
#import "AppDelegate.h"

@interface PlayerStatisticsViewController ()

@end

@implementation PlayerStatisticsViewController

@synthesize tvCell = _tvCell;
@synthesize actionsInMatch = _actionsInMatch;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return LocalString(@"PlayerStatisticsViewHeader");
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    StatisticSectionHeaderView * header = [[[NSBundle mainBundle] loadNibNamed:@"StatisticSectionHeaderView" owner:self options:nil] lastObject];
    if ([header isKindOfClass:[StatisticSectionHeaderView class]]) {
        header.nameLabel.text = @"姓名";
        return header;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    static NSString * StatisticsCellIdentifier = @"StatisticsCell";
    cell = [tableView dequeueReusableCellWithIdentifier:StatisticsCellIdentifier];
    if (nil == cell) {
        [[NSBundle mainBundle] loadNibNamed:@"MatchPartStatisticCell" owner:self options:nil];
        cell = _tvCell;
        self.tvCell = nil;
    }
    
    ActionManager * am = [ActionManager defaultManager];
    Player * player = [self.players objectAtIndex:indexPath.row];
    NSMutableDictionary * data = [am statisticsForPlayer:player.id inActions:_actionsInMatch];
//    NSString * stringNumber = [NSString stringWithFormat:@"%02d", [player.number integerValue]];
    [data setObject:player.name forKey:kName];
    [GameStatisticViewController setDataForCell:cell withStatistics:data];
    
    return cell;
}

@end
