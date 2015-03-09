//
//  FirstViewController.m
//  bascaptain
//
//  Created by sungeo on 15/3/6.
//
//

#import "BCGameHistoryViewController.h"
#import "BCPrepareGameViewController.h"
#import "GameStatisticViewController.h"
#import "MatchManager.h"
#import "TeamManager.h"
#import "Feature.h"
#import "GameHistoryCell.h"
#import "ImageManager.h"

@interface BCGameHistoryViewController (){

    NSDateFormatter * _dateFormatter;
    NSInteger _selectedRow;
}
@end

@implementation BCGameHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadMatchHistory];
    
    self.tableView.rowHeight = 100.0f;
    
    // 添加、删除比赛刷新表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyChangedHandler:) name:kMatchChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyChangedHandler:) name:kTeamChanged object:nil];
    
    [[Feature defaultFeature] hideExtraCellLineForTableView:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newGameClicked:(id)sender{
    BCPrepareGameViewController * vc = [[BCPrepareGameViewController alloc] init];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: vc];
    [self presentViewController:nav animated:YES completion:nil];
    
//    UISearchController * search = [[UISearchController alloc] initWithSearchResultsController:vc];
//    [self presentViewController:search animated:YES completion:nil];
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

- (void)loadMatchHistory{
    self.matches = [[MatchManager defaultManager] matchesArray];
    self.history = [[MatchManager defaultManager] dateGroupForMatches:self.matches];
    
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
    //    [vc reloadActionsInMatch];
    [self.navigationController pushViewController:vc animated:YES];
    
    // 用于删除比赛后，收到删除消息，刷新当前界面。
    _selectedRow = indexPath.row;
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if ([segue.identifier isEqualToString:@"ToPlayGameView"]) {
//        UINavigationController * nav = (UINavigationController *)segue.destinationViewController;
//        nav.hide
//    }
//}


@end
