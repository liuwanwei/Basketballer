//
//  GameHistoriesViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameHistoriesViewController.h"
#import "PlayGameViewController.h"
#import "SettingViewController.h"
#import "GameDetailsViewController.h"
#import "AppDelegate.h"
#import "MatchManager.h"
#import "TeamManager.h"
#import "GameSetting.h"
#import "StartGameViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GameHistoriesViewController (){
    UINavigationController * _settingsViewController;
    GameDetailsViewController * _gameDetailsViewController;
    UINavigationController * _startGameViewController;
    
    NSDateFormatter * _dateFormatter;
//    NSDateFormatter * _timeFormatter;
}
@end

@implementation GameHistoriesViewController
@synthesize tvCell = _tvCell;

#pragma 私有函数
- (void)initNavigationItem {
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(startGame)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma 事件函数
- (void)startGame {
    StartGameViewController * rootViewController = [[StartGameViewController alloc] initWithNibName:@"StartGameViewController" bundle:nil];
    _startGameViewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    [self.navigationController presentViewController:_startGameViewController animated:YES completion:nil];
}

- (void)showSettingView{
    if (nil == _settingsViewController) {
        SettingViewController * rootViewController = [[SettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
        _settingsViewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    }
    
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate presentModelViewController:_settingsViewController];
}

- (void)historyChangedHandler:(NSNotification *)notification{
    NSLog(@"got notification: %@", notification.name);
    [self.tableView reloadData];
}

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
    [self initNavigationItem];

//    UIImage * image = [UIImage imageNamed:@"TeamEntry"];
//    UIBarButtonItem * settingItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(showSettingView)];
//    self.navigationItem.leftBarButtonItem = settingItem;
        
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(historyChangedHandler:) name:kTeamChanged object:nil];
    [nc addObserver:self selector:@selector(historyChangedHandler:) name:kMatchChanged object:nil];  
    
    self.tableView.rowHeight = 48.0f;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[MatchManager defaultManager] matchesArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        [[NSBundle mainBundle] loadNibNamed:@"MatchRecordCell" owner:self options:nil];
        cell = _tvCell;
        self.tvCell = nil;
    }
    
    Match * match = [[[MatchManager defaultManager] matchesArray] objectAtIndex:indexPath.row];
    
//    UIImage * defaultTeamProfile = [UIImage imageNamed:@"DefaultTeamProfile"];
    UIImage * image;
    Team * team;
    TeamManager * tm = [TeamManager defaultManager];
    
    // 主队图像。
    team = [tm teamWithId:match.homeTeam];
    image = [tm imageForTeam:team];
    UIImageView * homeImageProfile = (UIImageView *)[cell viewWithTag:UIHomeTeamProfileTag];
    homeImageProfile.image = image;
    homeImageProfile.layer.masksToBounds = YES;
    homeImageProfile.layer.cornerRadius = 5.0f;    
    
    // 主队名字。    
    UILabel * homeTeamNameLabel = (UILabel *)[cell viewWithTag:UIHomeTeamNameTag];
    homeTeamNameLabel.text = team.name;
    
    // 主队得分。
    UILabel * homeTeamPointsLabel = (UILabel *)[cell viewWithTag:UIHomeTeamPointsTag];
    homeTeamPointsLabel.text = [[match homePoints] stringValue];
    
    // 比赛日期。
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yy-MM-dd"];
    }
    UILabel * dateLabel = (UILabel *)[cell viewWithTag:UIMatchDateTag];
    dateLabel.text = [_dateFormatter stringFromDate:[match date]];
    
    // 比赛时间。
//    if (_timeFormatter == nil) {
//        _timeFormatter = [[NSDateFormatter alloc] init];
//        [_timeFormatter setDateFormat:@"hh:mm"];
//    }
//    UILabel * timeLabel = (UILabel *)[cell viewWithTag:UIMatchTimeTag];
//    timeLabel.text = [_timeFormatter stringFromDate:[match date]];
    
    // 客队图像。
    team = [tm teamWithId:match.guestTeam];
    image = [tm imageForTeam:team];
    UIImageView * guestTeamProfile = (UIImageView *)[cell viewWithTag:UIGuestTeamProfileTag];
    guestTeamProfile.image = image;
    guestTeamProfile.layer.masksToBounds = YES;
    guestTeamProfile.layer.cornerRadius = 5.0f;
    
    // 客队名字。
    UILabel * guestTeamNameLabel = (UILabel *)[cell viewWithTag:UIGuestTeamNameTag];
    guestTeamNameLabel.text = team.name;
    
    // 客队得分。
    UILabel * guestTeamPointsLabel = (UILabel *)[cell viewWithTag:UIGuestTeamPointsTag];
    guestTeamPointsLabel.text = [[match guestPoints] stringValue];
    
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
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        MatchManager * mm = [MatchManager defaultManager];
//        Match * match = [[mm matchesArray] objectAtIndex:indexPath.row];
//        [mm deleteMatch:match];
//        
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_gameDetailsViewController == nil) {
        _gameDetailsViewController = [[GameDetailsViewController alloc] 
                                      initWithNibName:@"GameDetailsViewController" bundle:nil];
    }
    
    Match * match = [[[MatchManager defaultManager] matchesArray] objectAtIndex:indexPath.row];
    _gameDetailsViewController.match = match;
    [_gameDetailsViewController reloadActionsInMatch];
    [self.navigationController pushViewController:_gameDetailsViewController animated:YES];
}

@end
