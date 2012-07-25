//
//  TeamChoiceViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TeamManager.h"
#import "TeamChoiceViewController.h"
#import "StartGameViewController.h"
#import "EditTeamInfoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TeamChoiceViewController () {
    BOOL _teamEditState;
    
    UIBarButtonItem * _editItem;
    UIBarButtonItem * _doneItem;
    
    EditTeamInfoViewController * _editTeamViewController;
}
@end

@implementation TeamChoiceViewController
@synthesize parentController = _parentController;
@synthesize teamCell = _teamCell;

- (void)editTeam{
    if (! _teamEditState) {
        _teamEditState = YES;
        self.navigationItem.rightBarButtonItem = _doneItem;
        [self.tableView reloadData];
    }else{
        _teamEditState = NO;        
        self.navigationItem.rightBarButtonItem = _editItem;
        [self.tableView reloadData];
    }
}

#pragma 事件函数
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"球队列表"];
    
    _editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTeam)];
    _doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editTeam)];
    
    self.navigationItem.rightBarButtonItem = _editItem;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[TeamManager defaultManager].teams count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView * profileImageView;
    UILabel * label = (UILabel *)[cell viewWithTag:2]; 
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TeamRecordCell" owner:self options:nil];
        cell = _teamCell;
        self.teamCell = nil;
        
        // 图片圆角化。
        profileImageView = (UIImageView *)[cell viewWithTag:1];
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = 5.0f;
        profileImageView.frame = CGRectMake(5.0, 5.0, 60.0, 60.0);
        
        label = (UILabel *)[cell viewWithTag:2]; 
        label.frame = CGRectMake(80.0, 25.0, 200.0, 21.0);
    }
    profileImageView = (UIImageView *)[cell viewWithTag:1];
    label = (UILabel *)[cell viewWithTag:2]; 
    NSArray * teams = [[TeamManager defaultManager] teams];
    Team * team = [teams objectAtIndex:indexPath.row];
    profileImageView.image = [[TeamManager defaultManager] imageForTeam:team];
    label.text = team.name;
    
    if (_teamEditState) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
   
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * teams = [[TeamManager defaultManager] teams];
    Team * team = [teams objectAtIndex:indexPath.row];

    if (_teamEditState) {
        if (nil == _editTeamViewController) {
            _editTeamViewController = [[EditTeamInfoViewController alloc] initWithNibName:@"EditTeamInfoViewController" bundle:nil];
        }
        _editTeamViewController.team = team;
        [self.navigationController pushViewController: _editTeamViewController animated:YES];
    }else{        
        [self.parentController refreshTableData:team];
        [self.navigationController popViewControllerAnimated:YES];        
    }
}

@end
