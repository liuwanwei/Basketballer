//
//  GameDetailsViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameDetailsViewController.h"
#import "ActionManager.h"
#import "TeamManager.h"

typedef enum {
    UICellItemTitle = 1,
    UICellFirstValue = 2,
    UICellSecondValue = 3,
    UICellActionFilter = 4
}UIMatchPartSummaryCellTag;

@interface GameDetailsViewController (){
    // 从比赛历史界面第二次进入当前view时，需要刷新tableview。从下级菜单返回时，不用刷新tableview。
    BOOL _viewNeedRefresh;
    
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
}
@end

@implementation GameDetailsViewController
@synthesize actionFilter = _actionFilter;
@synthesize tableView = _tableView;
@synthesize tvCell = _tvCell;
@synthesize actionFilterCell = _actionFilterCell;
@synthesize match = _match;

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
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

    // 刷新主客队技术统计”table group“。
//    NSMutableArray * indexPaths = [[NSMutableArray alloc] init];
//    for (NSInteger i = 0; i < _periodNameArray.count; i++) {
//        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//        [indexPaths addObject:indexPath];
//    }
//    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic]; // TODO animation ?
    [self.tableView reloadData];
}

- (void)reloadActionsInMatch{
    _actionsInMatch = [[ActionManager defaultManager] actionsForMatch:_match];
    [_actionFilter setSelectedSegmentIndex:0];
    
    [self actionFilterChanged:_actionFilter];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _fourQuarterDescriptions = [NSArray arrayWithObjects:@"第一节", @"第二节", @"第三节", @"第四节", nil];
        _twoHalfDescriptions = [NSArray arrayWithObjects:@"上半场", @"下半场", nil];
        _periodNameArray = _fourQuarterDescriptions;
        
        _viewNeedRefresh = NO;
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
    
    /*
    [self.actionFilter addTarget:self action:@selector(actionFilterChanged) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.actionFilter;
     */
    
    self.tableView.delegate = self;
    [self setTitle:@"比赛概况"];
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_viewNeedRefresh) {
        _actionFilterSelectedIndex = 0;
        [self.tableView reloadData];
    }else{
        _viewNeedRefresh = YES;
    }
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
    static NSArray * Headers = nil;
    if (nil == Headers) {
        // TODO query team names from db.        
        Headers = [NSArray arrayWithObjects:@"主队 vs 客队", @"筛选", nil];
    }
    if (section == 0) {
        TeamManager * tm =  [TeamManager defaultManager];
        NSString * homeTeamName = [[tm teamWithId:self.match.homeTeam] name];
        NSString * guestTeamName = [[tm teamWithId:self.match.guestTeam] name];
        NSString * header = [NSString stringWithFormat:@"%@ vs %@", homeTeamName, guestTeamName];
        return header;
    }else{
        return @"筛选条件";
    }
    return [Headers objectAtIndex:section];
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
        }else{
            [[NSBundle mainBundle] loadNibNamed:@"MatchActionFilterCell" owner:self options:nil];
            cell = _actionFilterCell;
            self.actionFilterCell = nil;
            
            self.actionFilter = (UISegmentedControl *)[cell viewWithTag:UICellActionFilter];
            [self.actionFilter addTarget:self action:@selector(actionFilterChanged:) forControlEvents:UIControlEventValueChanged];
            self.actionFilter.selectedSegmentIndex = _actionFilterSelectedIndex;
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
 
@end
