//
//  SettingViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "GameSetting.h"
#import "TeamManager.h"
#import "GameSettingViewController.h"

@interface SettingViewController (){
    NSArray * _groupHeaders;
    
    GameSettingViewController * _gameSettingViewController;
}
@end

@implementation SettingViewController


- (void)dismissMyself{
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _groupHeaders = [NSArray arrayWithObjects:@"球队", @"规则", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * item;
    item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered
                                    target:self action:@selector(dismissMyself)];
    self.navigationItem.leftBarButtonItem = item;    
    
    [self setTitle:@"游戏设置"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _groupHeaders.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return ([[[TeamManager defaultManager] teams] count] + 1);
    }else{
        return [[[GameSetting defaultSetting] gameModeNames] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_groupHeaders objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSArray * teams = [[TeamManager defaultManager] teams];
    
    // Configure the cell...
    if (0 == indexPath.section) {
        if (indexPath.row < teams.count) {
            Team * team = [teams objectAtIndex:indexPath.row];
            cell.textLabel.text = team.name;
        }else{
            cell.textLabel.text = @"添加球队...";
        }
    }else{
        cell.textLabel.text = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:indexPath.row];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // TODO waiting for maoyu to add.
    }else if(indexPath.section == 1){
        if (_gameSettingViewController == nil) {
            _gameSettingViewController = [[GameSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
        }

        _gameSettingViewController.gameMode = (indexPath.row == 0 ? kGameModeTwoHalf : kGameModeFourQuarter);
        [_gameSettingViewController setTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        [self.navigationController pushViewController:_gameSettingViewController animated:YES];
    }
}

@end
