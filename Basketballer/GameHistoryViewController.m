//
//  GameHistoriesViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameHistoryViewController.h"
#import "PlayGameViewController.h"
#import "GameStatisticViewController.h"
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
    GameStatisticViewController * _gameDetailsViewController;
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
    
    if ([notification.name isEqualToString:kTeamChanged]) {
        [self.tableView reloadData];
    }else if([notification.name isEqualToString:kMatchChanged]){
        [self loadMatchHistory];
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

- (void)loadMatchHistory{
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
    
    // 生成按日期从大到小排序的数组
    NSArray * keys = [self.history allKeys];
    NSArray * sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = [(NSString *)obj1 compare:(NSString *)obj2];
        
        // 需要降序排列的日期，所以将结果逆转一下
        if (result == NSOrderedAscending) {
            return NSOrderedDescending;
        }else if(result == NSOrderedAscending){
            return NSOrderedDescending;
        }else{
            return NSOrderedSame;
        }
    }];
    
    self.historyGroupKeys = sortedKeys;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadMatchHistory];
    
    self.tableView.rowHeight = 100.0f;
   
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
    NSArray * matches = [self.history objectForKey:[self.historyGroupKeys objectAtIndex:indexPath.section]];
    Match * match = [matches objectAtIndex:indexPath.row];
    return match;
}

// 日期展示在分组头部
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.historyGroupKeys objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.historyGroupKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * matches = [self.history objectForKey:[self.historyGroupKeys objectAtIndex:section]];
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
    GameStatisticViewController * vc = [[GameStatisticViewController alloc]
                                  initWithNibName:@"GameStatisticViewController" bundle:nil];

    
    Match * match = [self matchForIndexPath:indexPath];
    
    vc.match = match;
    [vc reloadActionsInMatch];
    [self.navigationController pushViewController:vc animated:YES];
    
    // 用于删除比赛后，收到删除消息，刷新当前界面。
    _selectedRow = indexPath.row;
}

@end
