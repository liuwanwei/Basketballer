//
//  SettingViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "GameSetting.h"
#import "TeamManager.h"
#import "GameSettingViewController.h"
#import "EditTeamInfoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingViewController (){
    NSArray * _groupHeaders;
    
    GameSettingViewController * _gameSettingViewController;
}
@end

@implementation SettingViewController

@synthesize teamCell = _teamCell;

- (void)dismissMyself{
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    [delegate dismissModelViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissMyself)];
//    self.navigationItem.leftBarButtonItem = item;    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    _groupHeaders = [NSArray arrayWithObject:@"球队"];    
    [self setTitle:@"球队管理"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    static BOOL firstTimeShow = YES;
    if (firstTimeShow == YES) {
        firstTimeShow = NO;
    }else{
        [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return [[[TeamManager defaultManager] teams] count];
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    static NSString * CellIdentifier0 = @"Cell0";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier0];        
    if (nil == cell) {
        [[NSBundle mainBundle] loadNibNamed:@"TeamRecordCell" owner:self options:nil];
        cell = _teamCell;
        self.teamCell = nil;
        
        // 图片圆角化。
        UIImageView * profileImageView = (UIImageView *)[cell viewWithTag:1];
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = 5.0f;
        //            profileImageView.layer.borderWidth = 1.0f;
        //            profileImageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    }
        
    NSArray * teams = [[TeamManager defaultManager] teams];
    UIImageView * imageView = (UIImageView *)[cell viewWithTag:1];        
    UILabel * label = (UILabel *)[cell viewWithTag:2];        
    if (indexPath.section == 0) {    
        Team * team = [teams objectAtIndex:indexPath.row];
        imageView.image = [[TeamManager defaultManager] imageForTeam:team];
        label.text = team.name;
    }else{
        UIImage * image = [UIImage imageNamed:@"Add"];
        imageView.image = image;
        label.text = @"添加球队...";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditTeamInfoViewController *  editTeamInfoViewController = [[EditTeamInfoViewController alloc] initWithNibName:@"EditTeamInfoViewController" bundle:nil];
    
    if (indexPath.section == 0) {
        editTeamInfoViewController.operateMode = Update;
        
        NSArray * teams = [[TeamManager defaultManager] teams];        
        editTeamInfoViewController.team = [teams objectAtIndex:indexPath.row];
    }else {
        editTeamInfoViewController.operateMode = Insert;
        editTeamInfoViewController.team = nil;
    }
    
    NSLog(@"editTeam...ViewController %@", editTeamInfoViewController);
    [self.navigationController pushViewController:editTeamInfoViewController animated:YES];
}

@end
