//
//  GameDetailsViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameStatisticViewController.h"
#import "PlayerStatisticsViewController.h"
#import "ActionManager.h"
#import "TeamManager.h"
#import "MatchManager.h"
#import "AppDelegate.h"
#import "Feature.h"
#import "ImageManager.h"
#import <QuartzCore/QuartzCore.h>
#import "StatisticSectionHeaderView.h"
#import "StatisticCell.h"

typedef enum{
    SectionPeriodPoints     = 0,
    SectionTeamStatistics   = 1,
    SectionHomeTeamPlayers  = 2,
    SectionGuestTeamPlayers = 3,
}SectionIndex;

@interface GameStatisticViewController (){
    Team * _homeTeam;
    Team * _guestTeam;
    
    NSArray * _homeTeamPlayers;
    NSArray * _guestTeamPlayers;
    
    NSMutableArray * _sectionHeaders;
    
    NSMutableArray * _actionsInMatch;
    
    UIActionSheet * _actionSheetShare;
}
@end

@implementation GameStatisticViewController
@synthesize tableView = _tableView;
@synthesize tvCell = _tvCell;
@synthesize actionItem = _actionItem;
@synthesize trashItem = _trashItem;
@synthesize match = _match;

- (NSString *)pageName {
    NSString * pageName = @"GameStatistic";
    return pageName;
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
    Statistics * homeStatistics;
    Statistics * guestStatistics;
    homeStatistics = [am statisticsForTeam:_match.homeTeam inPeriod:MatchPeriodAll inActions:_actionsInMatch];
    guestStatistics = [am statisticsForTeam:_match.guestTeam inPeriod:MatchPeriodAll inActions:_actionsInMatch];
    
    result = LocalString(@"SNSShareMatchResult");
    result = [result stringByAppendingString:@" "];
    result = [result stringByAppendingString:_homeTeam.name];
    result = [result stringByAppendingString:@" vs "];
    result = [result stringByAppendingString:_guestTeam.name];
    result = [result stringByAppendingString:@" "];
    
    result = [result stringByAppendingString:[NSString stringWithFormat:@"%d", (int)homeStatistics.points]];
    result = [result stringByAppendingString:@" : "];
    result = [result stringByAppendingString:[NSString stringWithFormat:@"%d", (int)guestStatistics.points]];
    return result;
}

// TODO: 分享到微博和朋友圈同时开发完善，先屏蔽掉分享到微博
//- (void)showUMSnsController {    
//    UIImage * viewImage = [[UMSocialScreenShoterDefault screenShoter] getScreenShot];
//    
//    // TODO: 等待微信开发平台账号审核通过后，集成分享到朋友圈和讨论组功能
//    [UMSocialSnsService presentSnsIconSheetView:self
//                                         appKey:useAppkey
//                                      shareText:[self snsString]
//                                     shareImage:viewImage
//                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession, UMShareToWechatTimeline,nil]
//                                       delegate:nil];
//}

#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet == _actionSheetShare) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self deleteMatch];
        }else if(buttonIndex == actionSheet.firstOtherButtonIndex){
            // 分享到新浪微博。
//            [self showUMSnsController];
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
    }
    return self;
}

- (void)radiusForImageView:(UIImageView *)imageView withRadius:(float)radius{
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = radius;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    UIBarButtonItem  * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showUMSnsController)];
//    self.navigationItem.rightBarButtonItem = item;
    
    self.tableView.delegate = self;
    
    TeamManager * tm = [TeamManager defaultManager];
    _homeTeam = [tm teamWithId:_match.homeTeam];
    _guestTeam = [tm teamWithId:_match.guestTeam];
    
    _homeTeamPlayers = [[PlayerManager defaultManager] playersForTeam:_homeTeam.id];
    _guestTeamPlayers = [[PlayerManager defaultManager] playersForTeam:_guestTeam.id];

    // 设置title：主队 vs 客队。
    self.title = [NSString stringWithFormat:@"%@ vs %@", _homeTeam.name, _guestTeam.name];
    
    self.homeImageView.image = [[ImageManager defaultInstance] imageForName:_homeTeam.profileURL];
    float radius = 19.0f;
    [self radiusForImageView:self.homeImageView withRadius:radius];
    self.guestImageView.image = [[ImageManager defaultInstance] imageForName:_guestTeam.profileURL];
    [self radiusForImageView:self.guestImageView withRadius:radius];
    self.homeLabel.text = [_match.homePoints stringValue];
    self.guestLabel.text = [_match.guestPoints stringValue];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    self.dateLabel.text = [dateFormatter stringFromDate:self.match.date];
    
    if (IOS_7) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[self pageName]];
//    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[self pageName]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    _sectionHeaders = [NSMutableArray arrayWithObjects:
                       @"每节得分",
                       LocalString(@"MatchDetailViewHeader"),
                       LocalString(@"HomeStatisticHeader"),
                       LocalString(@"GuestStatisticHeader"), nil];
    
    return _sectionHeaders.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return [_sectionHeaders objectAtIndex:section];
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    StatisticSectionHeaderView * header = [[[NSBundle mainBundle] loadNibNamed:@"StatisticSectionHeaderView" owner:self options:nil] lastObject];
    if ([header isKindOfClass:[StatisticSectionHeaderView class]]) {
        switch (section) {
            case SectionPeriodPoints:
                [header changeToPeriodStatistics];
                break;
            case SectionTeamStatistics:
                break;
            case SectionHomeTeamPlayers:
                header.nameLabel.text = @"主队队员";//_homeTeam.name;
                break;
            case SectionGuestTeamPlayers:
                header.nameLabel.text = @"客队队员";//_guestTeam.name;
                break;
            default:
                break;
        }
        
        return header;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    switch (section) {
        case SectionPeriodPoints:
            rows = 2;
            break;
        case SectionTeamStatistics:
            rows = 2;
            break;
        case SectionHomeTeamPlayers:
            rows = _homeTeamPlayers.count;
            break;
        case SectionGuestTeamPlayers:
            rows = _guestTeamPlayers.count;
            break;
        default:
            break;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    StatisticCell * cell = nil;
    static NSString * CellIdentifier = @"StatisticCell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] lastObject];
    }

    ActionManager * am = [ActionManager defaultManager];
    
    if (indexPath.section == SectionPeriodPoints) {
        Team * teamInfo = (indexPath.row == 0 ? _homeTeam : _guestTeam);
        
        // 设置每一节的得分信息
        NSDictionary * dict = [am periodPointsForTeam:teamInfo.id inActions:_actionsInMatch];
        [cell setPeriodPoints:dict withTeamName:teamInfo.name];
        
        // 设置总分信息
        NSNumber * points = (indexPath.row == 0 ? _match.homePoints : _match.guestPoints);
        [cell setTotalPoints:points];
        
    }else if(indexPath.section == SectionTeamStatistics){
        // 球队技术统计：在xib中设置UITableViewCell的reuseIdentifier。
        
        Statistics * statistics = nil;
        Team * teamInfo = (indexPath.row == 0 ? _homeTeam : _guestTeam);
        statistics = [am statisticsForTeam:teamInfo.id inPeriod:MatchPeriodAll inActions:_actionsInMatch];
        statistics.name = teamInfo.name;
        
        [cell setStatistic:statistics];
        
    }else if(indexPath.section == SectionHomeTeamPlayers ||
             indexPath.section == SectionGuestTeamPlayers){
        ActionManager * am = [ActionManager defaultManager];
        NSArray * players = (indexPath.section == SectionHomeTeamPlayers ? _homeTeamPlayers : _guestTeamPlayers);
        Player * player = [players objectAtIndex:indexPath.row];
        Statistics * data = [am statisticsForPlayer:player.id inActions:_actionsInMatch];
        data.name = player.name;
        
        [cell setStatistic:data];
    }
    
    return cell;
}

@end
