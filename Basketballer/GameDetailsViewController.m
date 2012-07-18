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

typedef enum {
    UICellItemTitle = 1,
    UICellFirstValue = 2,
    UICellSecondValue = 3,
    UICellActionFilter = 4,
    UICellItemDelete = 5
}UIMatchPartSummaryCellTag;

@interface GameDetailsViewController (){
    
    // 比赛若是上下半场，指向_twohalfDescriptions；若是四节，指向_fourQuarterDescriptions.
    NSArray * __weak _periodNameArray;      
    NSArray * _fourQuarterDescriptions;
    NSArray * _twoHalfDescriptions;    
    
    NSString * _homeTeamName;
    NSString * _guestTeamName;
    NSMutableArray * _actionsInMatch;
    
    NSInteger _actionFilterValue;
    NSMutableArray * _homeTeamActionSummaryArray;
    NSMutableArray * _guestTeamActionSummaryArray;
    
    NSInteger _actionFilterSelectedIndex;
    
    NSArray * _filteredActions;
    ActionRecordViewController * _actionsViewController;
}
@end

@implementation GameDetailsViewController
@synthesize actionFilter = _actionFilter;
@synthesize tableView = _tableView;
@synthesize tvCell = _tvCell;
@synthesize actionFilterCell = _actionFilterCell;
@synthesize deletionCell = _deletionCell;
@synthesize match = _match;

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (1 == buttonIndex) {
        [[MatchManager defaultManager] deleteMatch:_match];
        [self back];
    }
}

- (void)deleteCurrentMatch{    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"确认" message:@"删除本场比赛信息？删除后信息不可恢复。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)actionFilterChanged:(id)sender{
    _actionFilterSelectedIndex = self.actionFilter.selectedSegmentIndex;
    switch (_actionFilterSelectedIndex) {
        default:            
        case 0:
            _actionFilterValue = ActionTypePoints;
            break;
        case 1:
            _actionFilterValue = ActionTypeFoul;
            break;
        case 2:
            _actionFilterValue = ActionTypeTimeout;
            break;
    }
    
    
    // 加载技术统计信息。
    ActionManager * am = [ActionManager defaultManager];
    _homeTeamActionSummaryArray = [am summaryForFilter:_actionFilterValue 
                                            withTeam:[_match.homeTeam integerValue] 
                                            inActions:_actionsInMatch];
    _guestTeamActionSummaryArray = [am summaryForFilter:_actionFilterValue 
                                            withTeam:[_match.guestTeam integerValue] 
                                            inActions:_actionsInMatch];

    [self.tableView reloadData];
}

- (void)reloadActionsInMatch{
    _actionsInMatch = [[ActionManager defaultManager] actionsForMatch:[_match.id integerValue]];
    [_actionFilter setSelectedSegmentIndex:0];
    
    [self actionFilterChanged:_actionFilter];
}

- (NSArray *)actionsWithType:(ActionType)actionType inPeriod:(NSInteger)period{
    NSMutableArray * actionArray = [[NSMutableArray alloc] init];
    for (Action * action in _actionsInMatch) {
        if ([action.period integerValue] == period) {
            NSInteger tmpType = [action.type integerValue];
            if (actionType == tmpType){
                if (actionType == ActionTypeFoul || 
                    actionType == ActionTypeTimeout) {
                    [actionArray addObject:action];
                }
            }else if(actionType == ActionTypePoints){
                if (tmpType == ActionType1Point || 
                    tmpType == ActionType2Points || 
                    tmpType == ActionType3Points) {
                    [actionArray addObject:action];
                }
            }
        }        
    }
    
    return actionArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _fourQuarterDescriptions = [NSArray arrayWithObjects:@"第一节", @"第二节", @"第三节", @"第四节", nil];
        _twoHalfDescriptions = [NSArray arrayWithObjects:@"上半场", @"下半场", nil];
        _periodNameArray = _fourQuarterDescriptions;
        
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
    
    UIBarButtonItem * delete = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteCurrentMatch)];
//    delete.tintColor = [UIColor redColor];
    self.navigationItem.rightBarButtonItem = delete;
    
    [self setTitle:@"比赛概况"];
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
    
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        TeamManager * tm =  [TeamManager defaultManager];
        NSString * homeTeamName = [tm teamNameWithDeletedStatus:[tm teamWithId:self.match.homeTeam]];
        NSString * guestTeamName = [tm teamNameWithDeletedStatus:[tm teamWithId:self.match.guestTeam]];
        NSString * header = [NSString stringWithFormat:@"%@ vs %@", homeTeamName, guestTeamName];
        return header;
    }else if(section == 1){
        return @"筛选条件";
    }else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [_periodNameArray count];
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"CellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (indexPath.section == 0) {
            [[NSBundle mainBundle] loadNibNamed:@"MatchPartSummaryCell" owner:self options:nil];
            cell = _tvCell;
            self.tvCell = nil;
        }else if(indexPath.section == 1){
            [[NSBundle mainBundle] loadNibNamed:@"MatchActionFilterCell" owner:self options:nil];
            cell = _actionFilterCell;
            self.actionFilterCell = nil;
            
            self.actionFilter = (UISegmentedControl *)[cell viewWithTag:UICellActionFilter];
            [self.actionFilter addTarget:self action:@selector(actionFilterChanged:) forControlEvents:UIControlEventValueChanged];
            self.actionFilter.selectedSegmentIndex = _actionFilterSelectedIndex;
        }else{
            [[NSBundle mainBundle] loadNibNamed:@"DeletionCell" owner:self options:nil];
            cell = _deletionCell;
            self.deletionCell = nil;
            
            UIButton * deleteButton = (UIButton *)[cell viewWithTag:UICellItemDelete];
            [deleteButton addTarget:self action:@selector(deleteCurrentMatch) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    if (indexPath.section == 0) {
        UILabel * title = (UILabel *)[cell viewWithTag:UICellItemTitle];
        title.text = [_periodNameArray objectAtIndex:indexPath.row];
        
        UILabel * firstValue = (UILabel *)[cell viewWithTag:UICellFirstValue];
        NSNumber * statistics = [_homeTeamActionSummaryArray objectAtIndex:indexPath.row];
        firstValue.text = [statistics stringValue]; 
        
        UILabel * secondValue = (UILabel *)[cell viewWithTag:UICellSecondValue];
        statistics = [_guestTeamActionSummaryArray objectAtIndex:indexPath.row];
        secondValue.text = [statistics stringValue];
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (_actionsViewController == nil) {
            _actionsViewController = [[ActionRecordViewController alloc] initWithStyle:UITableViewStylePlain];
        }
        _filteredActions = [self actionsWithType:_actionFilterValue inPeriod:indexPath.row];
        _actionsViewController.actionRecords = _filteredActions;
        [_actionsViewController.tableView reloadData];
        [self.navigationController pushViewController:_actionsViewController animated:YES];
    }
}
 
@end
