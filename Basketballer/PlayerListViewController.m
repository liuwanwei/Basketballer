//
//  PlayerListViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayerListViewController.h"
#import "Feature.h"
#import "AppDelegate.h"

@interface PlayerListViewController (){
}

@end

@implementation PlayerListViewController

@synthesize teamId = _teamId;
@synthesize players = _players;

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initWithTeamId:(NSNumber *)teamId{
    _teamId = teamId;
    _players = [[PlayerManager defaultManager] playersForTeam:_teamId];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[Feature defaultFeature] initNavleftBarItemWithController:self withAction:@selector(back)];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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
    return _players.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell * cell = nil;
    static NSString *CellIdentifier = @"Cell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    if (indexPath.row < _players.count) {
        Player * player = [_players objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:
                               LocalString(@"PlayerInfoFormatter"), 
                               [player.number integerValue]];
        cell.detailTextLabel.text = player.name;   

    }
        
    return cell;
}

@end
