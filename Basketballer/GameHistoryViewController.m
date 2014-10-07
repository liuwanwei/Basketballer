//
//  GameHistoriesViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameHistoryViewController.h"
#import "PlayGameViewController.h"
#import "GameDetailsViewController.h"
#import "MatchManager.h"
#import "TeamManager.h"
#import "ImageManager.h"
#import "GameSetting.h"
#import "StartGameViewController.h"
#import "GameHistoryMapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Feature.h"
#import "GameHistoryCell.h"
#import "TeamInfoViewController.h"

@interface GameHistoryViewController (){
    GameDetailsViewController * _gameDetailsViewController;
    UINavigationController * _gameHistoriesMapViewController;
    
    NSDateFormatter * _dateFormatter;
    NSInteger _selectedRow;
}
@end

@implementation GameHistoryViewController
@synthesize matches = _matches;
@synthesize historyType = _historyType;

#pragma 事件函数

- (void)showGameHistoriesMapView {
    if (nil == _gameHistoriesMapViewController) {
        GameHistoryMapViewController * rootViewController = [[GameHistoryMapViewController alloc] initWithNibName:@"GameHistoryMapViewController" bundle:nil];
        _gameHistoriesMapViewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    }
    
    [[AppDelegate delegate] presentModelViewController:_gameHistoriesMapViewController];
}

- (void)historyChangedHandler:(NSNotification *)notification{
    NSLog(@"GameHistory got notification: %@", notification.name);
    
    if ([notification.name isEqualToString:kMatchChanged] ||
        [notification.name isEqualToString:kTeamChanged]) {
        [self.tableView reloadData];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _historyType = HistoryTypeTeams;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_historyType == HistoryTypeTeam) {
         [[Feature defaultFeature] initNavleftBarItemWithController:self];
        self.history = [[MatchManager defaultManager] dateGroupForMatches:self.matches];
        self.title = LocalString(@"Record");
    }else {
        [[Feature defaultFeature] customNavigationBar:self.navigationController.navigationBar];
        self.matches = [[MatchManager defaultManager] matchesArray];
        self.history = [[MatchManager defaultManager] dateGroupForMatches:self.matches];
        self.title = LocalString(@"Histories");
    }
    
    self.tableView.rowHeight = 62.0f;
   
    // 添加、删除比赛刷新表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyChangedHandler:) name:kMatchChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyChangedHandler:) name:kTeamChanged object:nil];
    
    [[Feature defaultFeature] hideExtraCellLineForTableView:self.tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (Match *)matchForIndexPath:(NSIndexPath *)indexPath{
    NSArray * matches = [[self.history allValues] objectAtIndex:indexPath.section];
    Match * match = [matches objectAtIndex:indexPath.row];
    return match;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[self.history allKeys] objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.history allKeys].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * matches = [[self.history allValues] objectAtIndex:section];
    return matches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GameHistoryCell";
    GameHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        NSArray * nibs = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        
        cell = [nibs objectAtIndex:0];
    }
    
    Match * match = [self matchForIndexPath:indexPath];
//    Match * match = [_matches objectAtIndex:indexPath.row];
    
    Team * team;
    UIImage * image;
    TeamManager * tm = [TeamManager defaultManager];
    
    // 主队信息
    team = [tm teamWithId:match.homeTeam];
    image = [[ImageManager defaultInstance] imageForName:team.profileURL];
    cell.hostImageView.image = image;
    cell.hostNameLabel.text = team.name;
    cell.hostPointLabel.text = [[match homePoints] stringValue];
    
    // 比赛时间
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"HH:mm"];
    }
    cell.gameTimeLabel.text = [_dateFormatter stringFromDate:[match date]];;
    
    // 客队信息
    team = [tm teamWithId:match.guestTeam];
    image = [[ImageManager defaultInstance] imageForName:team.profileURL];
    cell.guestImageView.image = image;
    cell.guestNameLabel.text = team.name;
    cell.guestPointLabel.text = [[match guestPoints] stringValue];
    
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


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Match * match = [self matchForIndexPath:indexPath];
        [[MatchManager defaultManager] deleteMatch:match];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_gameDetailsViewController == nil) {
        _gameDetailsViewController = [[GameDetailsViewController alloc] 
                                      initWithNibName:@"GameDetailsViewController" bundle:nil];
    }
    
    Match * match = [self matchForIndexPath:indexPath];
    
    _gameDetailsViewController.match = match;
    [_gameDetailsViewController reloadActionsInMatch];
//    _gameDetailsViewController.hidesBottomBarWhenPushed = YES;    
    [self.navigationController pushViewController:_gameDetailsViewController animated:YES];
    
    // 用于删除比赛后，收到删除消息，刷新当前界面。
    _selectedRow = indexPath.row;
}

@end
