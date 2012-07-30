//
//  RulesViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RulesViewController.h"
#import "GameSettingViewController.h"
#import "GameSetting.h"
#import "Feature.h"

@interface RulesViewController ()

@end

@implementation RulesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [[Feature defaultFeature] weChatTableBgColor];
    self.tableView.rowHeight = 48.0f;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[GameSetting defaultSetting] gameModeNames] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)makeSubTitle:(NSArray *)rulesArray{
    NSString * combinedString = nil;
    for (NSString * ruleName in rulesArray) {
        if (combinedString == nil) {
            combinedString = [NSString stringWithString:ruleName];
        }else{
            combinedString = [combinedString stringByAppendingString:@"、"];
            combinedString = [combinedString stringByAppendingFormat:ruleName];
        }
    }
    
    return combinedString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    GameSetting * gameSetting = [GameSetting defaultSetting];
    cell.textLabel.text = [gameSetting.gameModeNames objectAtIndex:indexPath.section];
    
    NSArray * rulesArray = nil;
    if (indexPath.section == 0) {
        rulesArray = gameSetting.twoHalfSettings;
    }else if(indexPath.section == 1){
        rulesArray = gameSetting.fourQuarterSettings;
    }else if(indexPath.section == 2){
        rulesArray = gameSetting.pointMatchSettings;
    }
    cell.detailTextLabel.text = [self makeSubTitle:rulesArray];
    
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
    GameSettingViewController * viewController = [[GameSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    viewController.gameMode = [[[GameSetting defaultSetting] gameModes] objectAtIndex:indexPath.section];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
