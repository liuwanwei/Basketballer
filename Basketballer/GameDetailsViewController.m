//
//  GameDetailsViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameDetailsViewController.h"
#import "ActionRecordViewController.h"
#import "ActionManager.h"
#import "TeamManager.h"
#import "MatchManager.h"
#import "AppDelegate.h"

#define kName       @"name"
#define kPTS        @"PTS"
#define kPF         @"PF"
#define k3PM        @"3PM"
#define kFT         @"FT"

typedef enum {
    UICellTeamName      = 1,
    UICellPoints        = 2,
    UICellFouls         = 3,
    UICellThreePoints   = 4,
    UICellFreeThrows    = 5
}UIMatchPartSummaryCellTag;

@interface GameDetailsViewController (){
    
    NSString * _homeTeamName;
    NSString * _guestTeamName;
    
    // 比赛若是上下半场，指向_twohalfDescriptions；若是四节，指向_fourQuarterDescriptions.
    NSArray * __weak _periodNameArray;      
    NSArray * _fourQuarterDescriptions;
    NSArray * _twoHalfDescriptions;    
    
    NSMutableArray * _sectionHeaders;
    
    NSMutableArray * _actionsInMatch;
    
    UIActionSheet * _actionSheetShare;
    UIActionSheet * _actionSheetDelete;
}
@end

@implementation GameDetailsViewController
@synthesize tableView = _tableView;
@synthesize tvCell = _tvCell;
@synthesize actionItem = _actionItem;
@synthesize trashItem = _trashItem;
@synthesize match = _match;

#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet == _actionSheetShare) {
        switch (buttonIndex) {
            case 0:
                // 分享到新浪微博。
                break;
            case 1:
                // 分享到“周边比赛”。
            default:
                break;
        }
    }else if(actionSheet == _actionSheetDelete){
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            // 删除比赛。
            [[MatchManager defaultManager] deleteMatch:_match];
            [self back];
        }
    }
}

- (void)back{
    self.hidesBottomBarWhenPushed = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (1 == buttonIndex) {
//        [[MatchManager defaultManager] deleteMatch:_match];
//        [self back];
//    }
//}

- (void)actionSheetForMatch{
    if (_actionSheetShare == nil) {
        _actionSheetShare = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享到新浪微博",@"分享到比赛地图",  nil, nil];
        _actionSheetShare.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    }
    [_actionSheetShare showInView:self.view];
}

- (void)deleteCurrentMatch{    
    if (_actionSheetDelete == nil) {
        _actionSheetDelete = [[UIActionSheet alloc] initWithTitle:@"删除本场比赛所有相关信息？"  delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
    }
    [_actionSheetDelete showInView:self.view];
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
        _fourQuarterDescriptions = [NSArray arrayWithObjects:@"第一节", @"第二节", @"第三节", @"第四节", nil];
        _twoHalfDescriptions = [NSArray arrayWithObjects:@"上半场", @"下半场", nil];
        _periodNameArray = _fourQuarterDescriptions;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = back;
    
    self.tableView.delegate = self;
    
    // 设置title：主队 vs 客队。
    TeamManager * tm = [TeamManager defaultManager];
    _homeTeamName = [tm teamWithId:_match.homeTeam].name;
    _guestTeamName = [tm teamWithId:_match.guestTeam].name;
    
    NSString * title = [NSString stringWithFormat:@"%@ vs %@", _homeTeamName,_guestTeamName];
    
    [self setTitle:title];
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
    _sectionHeaders = [NSMutableArray arrayWithObjects:@"基本信息", @"全场技术统计", nil];
    if ([self.match.mode isEqualToString:kGameModeFourQuarter]) {
        [_sectionHeaders addObjectsFromArray:_fourQuarterDescriptions];
//        _periodNameArray = _fourQuarterDescriptions;
    }else if([self.match.mode isEqualToString:kGameModeTwoHalf]){
        [_sectionHeaders addObjectsFromArray:_twoHalfDescriptions];
//        _periodNameArray = _twoHalfDescriptions;
    }
    
    return _sectionHeaders.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_sectionHeaders objectAtIndex:section];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44;
    }else{
        if (indexPath.row == 0) {
            return 30;
        }else{
            return 44;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else{
        return 3;
    }
}

- (NSMutableDictionary *)statisticsForTeam:(NSNumber *)team inPeriod:(NSInteger)period{
    NSInteger teamId = [team integerValue];
    NSInteger pts = 0, pf = 0, threePM = 0, ft = 0;
    for (Action * action in _actionsInMatch) {
        NSInteger tempPeriod = [action.period integerValue];
        NSInteger tempTeamId = [action.team integerValue];
        if (tempTeamId == teamId && (-1 == period || tempPeriod == period)) {
            NSInteger actionType = [action.type integerValue];
            switch (actionType) {
                case ActionType1Point:
                    pts ++;
                    ft ++;
                    break;
                case ActionType2Points:
                    pts += 2;
                    break;
                case ActionType3Points:
                    pts += 3;
                    threePM += 3;
                    break;
                case ActionTypeFoul:
                    pf += 1;
                    break;
                default:
                    break;
            }
        }
    }
    
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[NSString stringWithFormat:@"%d", pts] forKey:kPTS];
    [dictionary setObject:[NSString stringWithFormat:@"%d", pf] forKey:kPF];
    [dictionary setObject:[NSString stringWithFormat:@"%d", threePM] forKey:k3PM];
    [dictionary setObject:[NSString stringWithFormat:@"%d", ft] forKey:kFT];
    
    return dictionary;
}

- (void)setStatisticsForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
//    UIView * bgView = [cell.subviews objectAtIndex:0];
    if (indexPath.row == 0) {
        // 技术统计section的第一行作为标题栏，不用修改内容。
//        bgView.backgroundColor = [UIColor lightGrayColor];
        return;
    }else {
//        bgView.backgroundColor = [UIColor clearColor];
    }
    
    NSMutableDictionary * statistics;
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            // 主队全场技术统计。
            statistics = [self statisticsForTeam:_match.homeTeam inPeriod:-1];
            [statistics setObject:_homeTeamName forKey:kName];
        }else{
            // 客队全场技术统计。
            statistics = [self statisticsForTeam:_match.guestTeam inPeriod:-1];
            [statistics setObject:_guestTeamName forKey:kName];
        }
    }else{
        NSInteger period = indexPath.section - 2;
        if (indexPath.row == 1) {
            // 主队第period节技术统计。
            statistics = [self statisticsForTeam:_match.homeTeam inPeriod:period];
            [statistics setObject:_homeTeamName forKey:kName];
        }else{
            // 客队第period节技术统计。
            statistics = [self statisticsForTeam:_match.guestTeam inPeriod:period];
            [statistics setObject:_guestTeamName forKey:kName];
        }
    }

    UILabel * label;
    
    label = (UILabel *)[cell viewWithTag:UICellTeamName];
    label.text = [statistics objectForKey:kName];
    
    label = (UILabel *)[cell viewWithTag:UICellPoints];
    label.text = [statistics objectForKey:kPTS];
    
    label = (UILabel *)[cell viewWithTag:UICellFouls];
    label.text = [statistics objectForKey:kPF];
    
    label = (UILabel *)[cell viewWithTag:UICellThreePoints];
    label.text = [statistics objectForKey:k3PM];
    
    label = (UILabel *)[cell viewWithTag:UICellFreeThrows];
    label.text = [statistics objectForKey:kFT];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = nil;
    if (indexPath.section == 0) {
        static NSString * CellIdentifier = @"CellIdentifier0";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yy-MM-dd hh:mm"];
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"时间";
                cell.detailTextLabel.text = [dateFormatter stringFromDate:_match.date];        
                break;
            case 1:
                cell.textLabel.text = @"位置";
                cell.detailTextLabel.text = @"未指定";
                break;
            default:
                break;
        }
    }else{
        // 在xib中设置UITableViewCell的reuseIdentifier。
        static NSString * CellIdentifier = @"MatchPartSummaryCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"MatchPartSummaryCell" owner:self options:nil];
            cell = _tvCell;
            self.tvCell = nil;
        }
        
        [self setStatisticsForCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

 
@end
