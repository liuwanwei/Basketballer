//
//  TeamChoiceViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TeamManager.h"
#import "TeamListViewController.h"
#import "StartGameViewController.h"
#import "TeamInfoViewController.h"
#import "AppDelegate.h"
#import "Feature.h"
#import <QuartzCore/QuartzCore.h>

@interface TeamListViewController (){
    UIBarButtonItem * _rightBarButtonItem;
    BOOL _clearedIndex;
}
@end

@implementation TeamListViewController
@synthesize teamCell = _teamCell;

- (void)addTeam{
    [self editTeam:nil];
}

- (void)editTeam:(Team *)team{
    TeamInfoViewController * editTeam = [[TeamInfoViewController alloc] initWithNibName:@"TeamInfoViewController" bundle:nil];
    if (nil == team) {
        editTeam.operateMode = Insert;
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:editTeam];
        [[Feature defaultFeature] customNavigationBar:nav.navigationBar];
        [[AppDelegate delegate] presentModelViewController:nav];
    }else{
        editTeam.operateMode = Update;
        editTeam.team = team;
        editTeam.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editTeam animated:YES];
    }
}

- (void)teamChangedHandler:(NSNotification *)notification{
    NSLog(@"TeamChoiceViewController before handle %@", notification.name);
    [self.tableView reloadData];
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
    
    self.tableView.rowHeight = 56.0f; 
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(teamChangedHandler:) name:kTeamChanged object:nil]; 
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTeam)];
    self.navigationItem.rightBarButtonItem = item;
    
    [[Feature defaultFeature] hideExtraCellLineForTableView:self.tableView];
    
    self.title = NSLocalizedString(@"Teams", nil);
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
    NSArray * teams = [TeamManager defaultManager].teams;
    return teams.count;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

/*- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.section;
    if ((row % 2) == 0) {
        [cell setBackgroundColor:[UIColor colorWithRed:0.974 green:0.974 blue:0.974 alpha:1.0]];
    }else {
        [cell setBackgroundColor:[UIColor colorWithRed:0.936 green:0.936 blue:0.936 alpha:1.0]];
    }
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView * profileImageView;    
    // 这个ID必须跟TeamRecordCell.xib中设置的保持一致。
    static NSString *CellIdentifier = @"TeamRecordCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TeamRecordCell" owner:self options:nil];
        cell = _teamCell;
        self.teamCell = nil;
        
        // 图片圆角化。
        profileImageView = (UIImageView *)[cell viewWithTag:1];
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = 5.0f;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    UILabel * label;
    
    profileImageView = (UIImageView *)[cell viewWithTag:1];
    label = (UILabel *)[cell viewWithTag:2]; 
    NSArray * teams = [[TeamManager defaultManager] teams];
    Team * team = [teams objectAtIndex:indexPath.section];
    profileImageView.image = [[TeamManager defaultManager] imageForTeam:team];
    label.text = team.name;
    
    label = (UILabel *)[cell viewWithTag:3];
    label.hidden = YES;
   
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * teams = [[TeamManager defaultManager] teams];
    Team * team = [teams objectAtIndex:indexPath.section];
    [self editTeam:team];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray * teams = [[TeamManager defaultManager] teams];
        Team * team = [teams objectAtIndex:indexPath.section];
        [[TeamManager defaultManager] deleteTeam:team];
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

@end
