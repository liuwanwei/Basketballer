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
#import "TeamSettingViewController.h"
#import "GameSettingViewController.h"

@interface SettingViewController (){
    NSArray * _tableStrings;
    NSArray * _groupHeaders;
    
    GameSettingViewController * _gameSettingViewController;
    TeamSettingViewController * _teamSettingViewController;
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
        _tableStrings = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"前三至球队名称排列。。。", nil], 
                                               [NSArray arrayWithObjects: @"上下半场模式", @"四节模式", nil], 
                                               nil];
        
        _groupHeaders = [NSArray arrayWithObjects:@"修改、添加球队", @"设置不同比赛模式下的规则", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                 target:self action:@selector(dismissMyself)];
    self.navigationItem.leftBarButtonItem = cancelItem;    
    
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
    return _tableStrings.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * object = [_tableStrings objectAtIndex:section];
    return object.count;
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
    
    // Configure the cell...
    NSArray * object = [_tableStrings objectAtIndex:indexPath.section];
    cell.textLabel.text = [object objectAtIndex:indexPath.row];
    
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
        if (_teamSettingViewController == nil) {
            _teamSettingViewController = [[TeamSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
        }
        
        [_teamSettingViewController setTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];        
        [self.navigationController pushViewController:_teamSettingViewController animated:YES];
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
