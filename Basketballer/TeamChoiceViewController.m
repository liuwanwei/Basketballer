//
//  TeamChoiceViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TeamChoiceViewController.h"
#import "TeamManager.h"
#import "StartGameViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TeamChoiceViewController () {
      
}
@end

@implementation TeamChoiceViewController
@synthesize parentController = _parentController;
@synthesize teamCell = _teamCell;

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView * profileImageView;
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TeamRecordCell" owner:self options:nil];
        cell = _teamCell;
        self.teamCell = nil;
        
        // 图片圆角化。
        profileImageView = (UIImageView *)[cell viewWithTag:1];
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = 5.0f;
        profileImageView.frame = CGRectMake(2.0, 1.0, 42.0, 42.0);
    }
    profileImageView = (UIImageView *)[cell viewWithTag:1];
    UILabel * label = (UILabel *)[cell viewWithTag:2]; 
    NSArray * teams = [[TeamManager defaultManager] teams];
    Team * team = [teams objectAtIndex:indexPath.row];
    profileImageView.image = [[TeamManager defaultManager] imageForTeam:team];
    label.text = team.name;
    cell.accessoryType = UITableViewCellAccessoryNone;
   
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * teams = [[TeamManager defaultManager] teams];
    Team * team = [teams objectAtIndex:indexPath.row];
    
    [self.parentController refreshTableData:team];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
