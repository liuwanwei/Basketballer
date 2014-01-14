//
//  GameDetailsViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameDetailsViewController.h"
//#import "ActionRecordViewController.h"
#import "PlayerStatisticsViewController.h"
#import "ActionManager.h"
#import "TeamManager.h"
#import "MatchManager.h"
#import "AppDelegate.h"
#import "Feature.h"
#import <QuartzCore/QuartzCore.h>

#define useAppkey @"503f331d527015516a000055"

@interface GameDetailsViewController (){
    
    NSString * _homeTeamName;
    NSString * _guestTeamName;
    NSString * _homePoints;
    NSString * _guestPoints;
    
    // 比赛若是上下半场，指向_twohalfDescriptions；若是四节，指向_fourQuarterDescriptions.
    NSArray * _periodNameArray;       
    
    NSMutableArray * _sectionHeaders;
    
    NSMutableArray * _actionsInMatch;
    
    UIActionSheet * _actionSheetShare;
}
@end

@implementation GameDetailsViewController
@synthesize tableView = _tableView;
@synthesize tvCell = _tvCell;
@synthesize actionItem = _actionItem;
@synthesize trashItem = _trashItem;
@synthesize match = _match;

+ (void)setDataForCell:(UITableViewCell *)cell withStatistics:(NSDictionary *)statistics{
    UILabel * label;
    
    label = (UILabel *)[cell viewWithTag:UICellName];
    label.text = [statistics objectForKey:kName];
    
    label = (UILabel *)[cell viewWithTag:UICellPoints];
    label.text = [statistics objectForKey:kPoints];
    
    label = (UILabel *)[cell viewWithTag:UICellFouls];
    label.text = [statistics objectForKey:kPersonalFouls];
    
    label = (UILabel *)[cell viewWithTag:UICellThreePoints];
    label.text = [statistics objectForKey:k3PointMade];
    
    label = (UILabel *)[cell viewWithTag:UICellFreeThrows];
    label.text = [statistics objectForKey:kFreeThrow];
}

- (NSString *)thoroughfareWithAdress:(NSString *)address {
    NSString * thoroughfare = nil;
    NSArray * addressArray = [address componentsSeparatedByString:@" "];
    NSInteger addressSize = addressArray.count;
    if (addressSize != 0) {
        thoroughfare = [addressArray objectAtIndex:addressSize - 1];
    }
    return thoroughfare;
}

- (NSString *)snsString {
    NSString * result = nil;
    ActionManager * am = [ActionManager defaultManager];
    NSMutableDictionary * homeStatistics;
    NSMutableDictionary * guestStatistics;
    homeStatistics = [am statisticsForTeam:_match.homeTeam inPeriod:MatchPeriodAll inActions:_actionsInMatch];
    guestStatistics = [am statisticsForTeam:_match.guestTeam inPeriod:MatchPeriodAll inActions:_actionsInMatch];
    
    result = LocalString(@"SNSShareMatchResult");
    result = [result stringByAppendingString:@" "];
    result = [result stringByAppendingString:_homeTeamName];
    result = [result stringByAppendingString:@" vs "];
    result = [result stringByAppendingString:_guestTeamName];
    result = [result stringByAppendingString:@" "];
    
    result = [result stringByAppendingString:[homeStatistics objectForKey:kPoints]];
    result = [result stringByAppendingString:@" : "];
    result = [result stringByAppendingString:[guestStatistics objectForKey:kPoints]];
    return result;
}

- (void)showUMSnsController {
    [UMSNSService setViewDisplayDelegate:self];
    [UMSNSService setDataSendDelegate:self];
    
    UIGraphicsBeginImageContext(CGSizeMake(320.0, 300.0));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [UMSNSService presentSNSInController:self 
                                  appkey:useAppkey
                                  status:[self snsString]
                                   image:viewImage
                               platform:UMShareToTypeSina];
}

#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet == _actionSheetShare) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self deleteMatch];
        }else if(buttonIndex == actionSheet.firstOtherButtonIndex){
            // 分享到新浪微博。
            [self showUMSnsController];
        }else if(buttonIndex == actionSheet.firstOtherButtonIndex + 1){
            // 分享到“周边比赛”。
        }
    }
}

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [[MatchManager defaultManager] deleteMatch:_match];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showActionMenu{
    if (_actionSheetShare == nil) {
        _actionSheetShare = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:LocalString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:LocalString(@"SnsShareToSina"), nil];
        _actionSheetShare.actionSheetStyle = UIActionSheetStyleDefault;
    }
    [_actionSheetShare showInView:self.view];
}

- (void)deleteMatch{    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"删除比赛？" message:@"删除后信息不能恢复" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)reloadActionsInMatch{
    _actionsInMatch = [[ActionManager defaultManager] actionsForMatch:[_match.id integerValue]];
    
    [self.tableView reloadData];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _periodNameArray = [NSArray arrayWithObjects:@"第一节", @"第二节", @"第三节", @"第四节", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[Feature defaultFeature] initNavleftBarItemWithController:self];
    
    //UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStyleBordered target:self action:@selector(showActionMenu)];
    UIBarButtonItem  * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionMenu)];
    self.navigationItem.rightBarButtonItem = item;
    
    self.tableView.delegate = self;
    
    // 设置title：主队 vs 客队。
    TeamManager * tm = [TeamManager defaultManager];
    _homeTeamName = [tm teamWithId:_match.homeTeam].name;
    _guestTeamName = [tm teamWithId:_match.guestTeam].name;
    
//    NSString * title = [NSString stringWithFormat:@"%@ vs %@", _homeTeamName,_guestTeamName];
    
    [self setTitle:LocalString(@"MatchDetail")];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    _sectionHeaders = [NSMutableArray arrayWithObjects:
                       LocalString(@"BasicInfo"),
                       LocalString(@"MatchDetailViewHeader"),
                       LocalString(@"PlayerStatisticHeader"), nil];
    
    return _sectionHeaders.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_sectionHeaders objectAtIndex:section];
}

//- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == 0 && indexPath.section == 1) {
//        return 30;
//    }else{
//        return 44;
//    }
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    
    return 2;
}

- (void)setStatisticsForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{    
    ActionManager * am = [ActionManager defaultManager];
    NSMutableDictionary * statistics;
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            // 主队全场技术统计。
            statistics = [am statisticsForTeam:_match.homeTeam inPeriod:MatchPeriodAll inActions:_actionsInMatch];
            [statistics setObject:_homeTeamName forKey:kName];
        }else{
            // 客队全场技术统计。
            statistics = [am statisticsForTeam:_match.guestTeam inPeriod:MatchPeriodAll inActions:_actionsInMatch];
            [statistics setObject:_guestTeamName forKey:kName];
        }
    }else{
        NSInteger period = indexPath.section - 2;
        if (indexPath.row == 1) {
            // 主队第period节技术统计。
            statistics = [am statisticsForTeam:_match.homeTeam inPeriod:period inActions:_actionsInMatch];
            [statistics setObject:_homeTeamName forKey:kName];
        }else{
            // 客队第period节技术统计。
            statistics = [am statisticsForTeam:_match.guestTeam inPeriod:period inActions:_actionsInMatch];
            [statistics setObject:_guestTeamName forKey:kName];
        }
    }

    [GameDetailsViewController setDataForCell:cell withStatistics:statistics];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = nil;
    if(indexPath.section == 1){
        // 球队技术统计。
        // 在xib中设置UITableViewCell的reuseIdentifier。
        static NSString * CellIdentifier = @"StatisticsCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"MatchPartSummaryCell" owner:self options:nil];
            cell = _tvCell;
            self.tvCell = nil;
        }
        
        [self setStatisticsForCell:cell atIndexPath:indexPath];
    }else{
        static NSString * CellIdentifier = @"CellIdentifier0";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        if (indexPath.section == 0) {
            // 基本信息。
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yy-MM-dd hh:mm"];
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = LocalString(@"MatchDate");
                    cell.detailTextLabel.text = [dateFormatter stringFromDate:_match.date];  
                    break;
                case 1:
                    cell.detailTextLabel.text = [self thoroughfareWithAdress:_match.court];
                    cell.textLabel.text = LocalString(@"MatchLocation");
                    break;
                default:
                    break;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else if(indexPath.section == 3){
            cell.textLabel.text = [_periodNameArray objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }else if(indexPath.section == 2){
            // 队员技术统计。
            cell.textLabel.text = indexPath.row == 0 ? _homeTeamName : _guestTeamName;
            cell.detailTextLabel.text = nil;            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;            
        }
    }
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        NSNumber * team = indexPath.row == 0 ? _match.homeTeam : _match.guestTeam;
        PlayerStatisticsViewController * viewController = [[PlayerStatisticsViewController alloc] initWithStyle:UITableViewStylePlain];
        [viewController initWithTeamId:team];
        viewController.actionsInMatch = _actionsInMatch;
        viewController.title = [[TeamManager defaultManager] teamWithId:team].name;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
 
@end
