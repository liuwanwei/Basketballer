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
#import "EditTeamInfoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingViewController (){
    NSArray * _groupHeaders;
    
    GameSettingViewController * _gameSettingViewController;
}
@end

@implementation SettingViewController

@synthesize teamCell = _teamCell;

- (void)dismissMyself{
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _groupHeaders = [NSArray arrayWithObjects:@"比赛球队", @"比赛规则", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * item;
    item = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    static BOOL firstTimeShow = YES;
    if (firstTimeShow == YES) {
        firstTimeShow = NO;
    }else{
        [self.tableView reloadData];
    }
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

//- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 48.0f;
//    if (indexPath.section == 0) {
//        return 48.0f;
//    }else{
//        return 44.0f;
//    }
//}

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
    UITableViewCell * cell;
    if (indexPath.section == 0) {
        static NSString * CellIdentifier0 = @"Cell0";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier0];        
        if (nil == cell) {
            [[NSBundle mainBundle] loadNibNamed:@"TeamRecordCell" owner:self options:nil];
            cell = _teamCell;
            self.teamCell = nil;
            
            // 图片圆角化。
            UIImageView * profileImageView = (UIImageView *)[cell viewWithTag:1];
            profileImageView.layer.masksToBounds = YES;
            profileImageView.layer.cornerRadius = 5.0f;
//            profileImageView.layer.borderWidth = 1.0f;
//            profileImageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        }
        
        NSArray * teams = [[TeamManager defaultManager] teams];
        
        UIImageView * imageView = (UIImageView *)[cell viewWithTag:1];        
        UILabel * label = (UILabel *)[cell viewWithTag:2];        
        if (indexPath.row < teams.count) {
            Team * team = [teams objectAtIndex:indexPath.row];
            
            
            imageView.image = [[TeamManager defaultManager] imageForTeam:team];
            label.text = team.name;
            //            cell.imageView.image = [[TeamManager defaultManager] imageForTeam:team];
            //            cell.textLabel.text = team.name;
        }else{
            UIImage * image = [UIImage imageNamed:@"Add"];
            imageView.image = image;
            label.text = @"添加球队...";
        }
    }else{
        static NSString * CellIdentifier1 = @"Cell1";  
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
        cell.textLabel.text = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:indexPath.row];
    }

//    if (nil == cell) {
//        if (indexPath.section == 0) {
//            [[NSBundle mainBundle] loadNibNamed:@"TeamRecordCell" owner:self options:nil];
//            cell = _teamCell;
//            self.teamCell = nil;
//        }else{
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;            
//        }
//    }
//    
//    NSArray * teams = [[TeamManager defaultManager] teams];
//    
//    // Configure the cell...
//    if (0 == indexPath.section) {
//        UIImageView * imageView = (UIImageView *)[cell viewWithTag:1];        
//        UILabel * label = (UILabel *)[cell viewWithTag:2];        
//        if (indexPath.row < teams.count) {
//            Team * team = [teams objectAtIndex:indexPath.row];
//            
//
//            imageView.image = [[TeamManager defaultManager] imageForTeam:team];
//            label.text = team.name;
////            cell.imageView.image = [[TeamManager defaultManager] imageForTeam:team];
////            cell.textLabel.text = team.name;
//        }else{
//            label.text = @"添加球队...";
////            cell.textLabel.text = @"添加球队...";
//        }
//    }else{
//        cell.textLabel.text = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:indexPath.row];
//    }
    
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
        EditTeamInfoViewController *  editTeamInfoViewController = [[EditTeamInfoViewController alloc] initWithNibName:@"EditTeamInfoViewController" bundle:nil];
        
        NSArray * teams = [[TeamManager defaultManager] teams];
        if (indexPath.row < teams.count) {
            editTeamInfoViewController.operateMode = Update;
            editTeamInfoViewController.team = [teams objectAtIndex:indexPath.row];
        }else {
            editTeamInfoViewController.operateMode = Insert;
            editTeamInfoViewController.team = nil;
        }
      
        [self.navigationController pushViewController:editTeamInfoViewController animated:YES];
        
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
