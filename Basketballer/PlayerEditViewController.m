//
//  PlayerEditViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayerEditViewController.h"
#import "NewPlayerViewController.h"
#import "AppDelegate.h"
#import "Feature.h"

@interface PlayerEditViewController ()

@end

@implementation PlayerEditViewController

- (void)addPlayer{
    NewPlayerViewController * newPlayer = [[NewPlayerViewController alloc] initWithNibName:@"NewPlayerViewController" bundle:nil];
    newPlayer.team = self.teamId;
//    newPlayer.parentWhoPresentedMe = self;
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:newPlayer];

    [self presentModalViewController:nav animated:YES];
}

- (void)playerChangedNotification:(NSNotification *)notification{
    [self initWithTeamId:self.teamId];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlayer)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(playerChangedNotification:) name:kPlayerChangedNotification object:nil];   
    
    self.title = LocalString(@"Roster");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // “球员编辑列表”模式下的消息处理。
    NewPlayerViewController * newPlayer = [[NewPlayerViewController alloc] initWithNibName:@"NewPlayerViewController" bundle:nil];
    newPlayer.model = [self.players objectAtIndex:indexPath.row];
    newPlayer.team = self.teamId;
    [self.navigationController pushViewController:newPlayer animated:YES];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[PlayerManager defaultManager] deletePlayer:[self.players objectAtIndex:indexPath.row]];
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
@end
