//
//  PlayerFoulStatisticViewController.m
//  Basketballer
//
//  Created by maoyu on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayerFoulStatisticViewController.h"
#import "MatchUnderWay.h"

@implementation PlayerFoulStatisticViewController
@synthesize actionsInMatch = _actionsInMatch;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"犯规统计";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.players.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    ActionManager * am = [ActionManager defaultManager];
    Player * player = [self.players objectAtIndex:indexPath.row];
    NSMutableDictionary * data = [am statisticsForPlayer:player.id inActions:_actionsInMatch];
    NSInteger fouls = [[data objectForKey:kPersonalFouls] intValue];
    
    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingFormat:@" (%d)", fouls];
    
    if ([MatchUnderWay defaultMatch].rule.foulLimitForPlayer < fouls) {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}


@end
