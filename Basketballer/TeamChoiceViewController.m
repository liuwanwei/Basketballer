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

@interface TeamChoiceViewController () {
      
}
@end

@implementation TeamChoiceViewController
@synthesize parentController = _parentController;


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
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray * teams = [[TeamManager defaultManager] teams];
    Team * team = [teams objectAtIndex:indexPath.row];
    cell.imageView.image = [[TeamManager defaultManager] imageForTeam:team];
    cell.textLabel.text = team.name;
   
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
