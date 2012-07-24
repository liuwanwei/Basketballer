//
//  GameDetailsViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameDetailsViewController.h"
#import "ActionRecordViewController.h"
#import "PointDetailsViewController.h"
#import "ActionManager.h"
#import "TeamManager.h"
#import "MatchManager.h"

typedef enum {
    UICellItemTitle = 1,
    UICellFirstHome = 2,
    UICellFirstGuest = 3,
    UICellSecondHome = 4,
    UICellSecondGuest = 5,
}UIMatchPartSummaryCellTag;

@interface GameDetailsViewController (){
    
    // 比赛若是上下半场，指向_twohalfDescriptions；若是四节，指向_fourQuarterDescriptions.
    NSArray * __weak _periodNameArray;      
    NSArray * _fourQuarterDescriptions;
    NSArray * _twoHalfDescriptions;    
    NSArray * _filterNames;
    
    NSMutableArray * _actionsInMatch;
    
//    NSInteger _actionFilterValue;
    NSMutableArray * _homeTeamPointsSummary;
    NSMutableArray * _guestTeamPointsSummary;
    NSMutableArray * _homeTeamFoulsSummary;
    NSMutableArray * _guestTeamFoulsSummary;
    
    NSInteger _actionFilterSelectedIndex;
    
//    NSArray * _filteredActions;
//    ActionRecordViewController * _actionsViewController;
    
    PointDetailsViewController * _pointDetailsViewController;
}
@end

@implementation GameDetailsViewController
@synthesize actionFilter = _actionFilter;
@synthesize teams = _teams;
@synthesize dateTime = _dateTime;
@synthesize tableView = _tableView;
@synthesize tvCell = _tvCell;
@synthesize actionFilterCell = _actionFilterCell;
@synthesize tableHeaderView = _tableHeaderView;
@synthesize match = _match;

- (void)back{
    self.hidesBottomBarWhenPushed = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (1 == buttonIndex) {
        [[MatchManager defaultManager] deleteMatch:_match];
        [self back];
    }
}

- (void)deleteCurrentMatch{    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"删除本场比赛所有相关信息？" message:@"删除后不可恢复。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)actionFilterChanged:(id)sender{
//    _actionFilterSelectedIndex = self.actionFilter.selectedSegmentIndex;
//    switch (_actionFilterSelectedIndex) {
//        default:            
//        case 0:
//            _actionFilterValue = ActionTypePoints;
//            break;
//        case 1:
//            _actionFilterValue = ActionTypeFoul;
//            break;
//        case 2:
//            _actionFilterValue = ActionTypeTimeout;
//            break;
//    }
    
    
}

- (void)reloadActionsInMatch{
    _actionsInMatch = [[ActionManager defaultManager] actionsForMatch:[_match.id integerValue]];
    
    // 加载技术统计信息。
    ActionManager * am = [ActionManager defaultManager];
    _homeTeamPointsSummary = [am summaryForFilter:ActionTypePoints 
                                         withTeam:[_match.homeTeam integerValue] 
                                        inActions:_actionsInMatch];
    _guestTeamPointsSummary = [am summaryForFilter:ActionTypePoints 
                                          withTeam:[_match.guestTeam integerValue] 
                                         inActions:_actionsInMatch];
    _homeTeamFoulsSummary = [am summaryForFilter:ActionTypeFoul 
                                        withTeam:[_match.homeTeam integerValue] 
                                       inActions:_actionsInMatch];
    _guestTeamFoulsSummary = [am summaryForFilter:ActionTypeFoul 
                                         withTeam:[_match.guestTeam integerValue] 
                                        inActions:_actionsInMatch];
    
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
        
        _filterNames = [NSArray arrayWithObjects:@"得分", @"犯规", @"暂停", nil];
        
        _actionFilterSelectedIndex = 0;
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
    
//    UIBarButtonItem * space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem * trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteCurrentMatch)];
//    NSArray * toolbarItems = [NSArray arrayWithObjects:space, trash, nil];
//    [self.toolbar setItems:toolbarItems];
//    self.navigationItem.rightBarButtonItem = trash;
    
//    [self.actionFilter addTarget:self action:@selector(actionFilterChanged:) forControlEvents:UIControlEventValueChanged];
//    self.actionFilter.selectedSegmentIndex = _actionFilterSelectedIndex;
    
//    CGRect frame = CGRectMake(0.0, 0.0, self.tableView.frame.size.width, self.tableHeaderView.frame.size.height);
//    self.tableHeaderView.backgroundColor = [UIColor clearColor];
//    self.tableHeaderView.frame = frame;
//    self.tableView.tableHeaderView = self.tableHeaderView;
    
//    
//    frame = self.actionFilter.frame;
//    frame.size.height += 10;
//    self.actionFilter.frame = frame;
    
    TeamManager * tm = [TeamManager defaultManager];
    NSString * title = [NSString stringWithFormat:@"%@ vs %@",
                        [tm teamWithId:_match.homeTeam].name,
                        [tm teamWithId:_match.guestTeam].name];
    
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
    if ([self.match.mode isEqualToString:kGameModeFourQuarter]) {
        _periodNameArray = _fourQuarterDescriptions;
    }else if([self.match.mode isEqualToString:kGameModeTwoHalf]){
        _periodNameArray = _twoHalfDescriptions;
    }else{
        _periodNameArray = nil;
    }
    
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"得分对比";
    }else if(section == 2){
        return @"犯规对比";
    }else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else if(section == 1 || section == 2){
        return [_periodNameArray count];
    }else{
        return 0;
    }
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
    }else if(indexPath.section == 1){
        // 在xib中设置UITableViewCell的reuseIdentifier。
        static NSString * CellIdentifier = @"SummaryReuseIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"MatchPartSummaryCell" owner:self options:nil];
            cell = _tvCell;
            self.tvCell = nil;
        }
        
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        UILabel * title = (UILabel *)[cell viewWithTag:UICellItemTitle];
        title.text = [_periodNameArray objectAtIndex:indexPath.row];
        
        UILabel * firstValue = (UILabel *)[cell viewWithTag:UICellFirstHome];
        NSNumber * statistics = [_homeTeamPointsSummary objectAtIndex:indexPath.row];
        firstValue.text = [statistics stringValue]; 
        
        UILabel * secondValue = (UILabel *)[cell viewWithTag:UICellFirstGuest];
        statistics = [_guestTeamPointsSummary objectAtIndex:indexPath.row];
        secondValue.text = [statistics stringValue];

    }else if(indexPath.section == 2){
        // 在xib中设置UITableViewCell的reuseIdentifier。
        static NSString * CellIdentifier = @"SummaryReuseIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"MatchPartSummaryCell" owner:self options:nil];
            cell = _tvCell;
            self.tvCell = nil;
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UILabel * title = (UILabel *)[cell viewWithTag:UICellItemTitle];
        title.text = [_periodNameArray objectAtIndex:indexPath.row];
        
        UILabel * firstValue = (UILabel *)[cell viewWithTag:UICellFirstHome];
        NSNumber * statistics = [_homeTeamFoulsSummary objectAtIndex:indexPath.row];
        firstValue.text = [statistics stringValue]; 
        
        UILabel * secondValue = (UILabel *)[cell viewWithTag:UICellFirstGuest];
        statistics = [_guestTeamFoulsSummary objectAtIndex:indexPath.row];
        secondValue.text = [statistics stringValue];
    }
    
    return cell;
}

#pragma mark UITableViewDelegate


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (_pointDetailsViewController == nil) {
            _pointDetailsViewController = [[PointDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        }
        
        _pointDetailsViewController.match = _match;
        _pointDetailsViewController.actions = [[ActionManager defaultManager] actionsWithType:ActionTypePoints inPeriod:indexPath.row inActions:_actionsInMatch];
        _pointDetailsViewController.title = [_periodNameArray objectAtIndex:indexPath.row];
        [_pointDetailsViewController.tableView reloadData];
        [self.navigationController pushViewController:_pointDetailsViewController animated:YES];
    }
}
 
@end
