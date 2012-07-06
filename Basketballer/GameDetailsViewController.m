//
//  GameDetailsViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameDetailsViewController.h"

typedef enum {
    UICellItemTitle = 1,
    UICellFirstValue = 2,
    UICellSecondValue = 3,
    UICellActionFilter = 4
}UIMatchPartSummaryCellTag;

@interface GameDetailsViewController (){
    NSArray * _fourQuarterDescriptions;
    NSArray * _twoHalfDescriptions;
    
    NSArray * __weak _currentModeDescriptions;      // TODO
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

- (void)actionFilterChanged{
    NSLog(@"I'm changed to %d", self.actionFilter.selectedSegmentIndex);

    NSMutableArray * indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < _currentModeDescriptions.count; i++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic]; // TODO animation ?
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _fourQuarterDescriptions = [NSArray arrayWithObjects:@"第一节", @"第二节", @"第三节", @"第四节", nil];
        _twoHalfDescriptions = [NSArray arrayWithObjects:@"上半场", @"下半场", nil];
        _currentModeDescriptions = _fourQuarterDescriptions;
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
    
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self.match.mode isEqualToString:kGameModeFourQuarter]) {
        _currentModeDescriptions = _fourQuarterDescriptions;
    }else if([self.match.mode isEqualToString:kGameModeTwoHalf]){
        _currentModeDescriptions = _twoHalfDescriptions;
    }else{
        _currentModeDescriptions = nil;
    }
    
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    static NSArray * Headers = nil;
    if (nil == Headers) {
        // TODO query team names from db.        
        Headers = [NSArray arrayWithObjects:@"主队 vs 客队", @"筛选", nil];
    }
    return [Headers objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [_currentModeDescriptions count];
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
            UISegmentedControl * segmentedFilter = (UISegmentedControl *)[cell viewWithTag:UICellActionFilter];
            [segmentedFilter addTarget:self action:@selector(actionFilterChanged) forControlEvents:UIControlEventValueChanged];
        }
    }
    
    if (indexPath.section == 0) {
        UILabel * title = (UILabel *)[cell viewWithTag:UICellItemTitle];
        title.text = [_currentModeDescriptions objectAtIndex:indexPath.row];
        
        UILabel * firstValue = (UILabel *)[cell viewWithTag:UICellFirstValue];
        firstValue.text = @"3"; // TODO summary from db.
        
        UILabel * secondValue = (UILabel *)[cell viewWithTag:UICellSecondValue];
        secondValue.text = @"2";
    }
    
    return cell;
}

#pragma mark UITableViewDelegate
 
@end
