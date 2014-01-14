//
//  ActionRecordViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ActionRecordViewController.h"
#import "ActionManager.h"
#import "TeamManager.h"
#import "MatchUnderWay.h"
#import <QuartzCore/QuartzCore.h>
#import "Feature.h"
#import "AppDelegate.h"

@interface ActionRecordViewController () {
    CGPoint _touchBeganPoint;
    Team * _homeTeam;
    Team * _guestTeam;
}
@end

@implementation ActionRecordViewController
@synthesize teamSelector = _teamSelector;
@synthesize tableView = _tableView;
@synthesize actionRecords = _actionRecords;

#pragma 事件函数
-(void) swip:(UISwipeGestureRecognizer *)swip {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initView{
    MatchUnderWay * match = [MatchUnderWay defaultMatch];
    
    if (_homeTeam == nil || _guestTeam == nil) {       
        TeamManager * teamManager = [TeamManager defaultManager];         
        _homeTeam = [teamManager teamWithId:match.home.teamId];
        _guestTeam = [teamManager teamWithId:match.guest.teamId];
    }
    
    [self.teamSelector setTitle:_homeTeam.name forSegmentAtIndex:0];
    [self.teamSelector setTitle:_guestTeam.name forSegmentAtIndex:1];
    
    self.teamSelector.selectedSegmentIndex = 0;    
}

- (NSMutableArray *)actionsForTeam:(NSNumber *)teamId inActions:(NSArray *)allActions{
    if (! allActions) {
        return nil;
    }
    
    NSMutableArray * resultArray = nil;
    for(Action * action in allActions){
        if ([action.team isEqualToNumber:teamId]) {
            if (! resultArray) {
                resultArray = [[NSMutableArray alloc] initWithObjects:action, nil];
            }else{
                [resultArray addObject:action];
            }
        }
    }
    
    return resultArray;
}

- (void)teamChanged{
    NSInteger value = self.teamSelector.selectedSegmentIndex;
    NSNumber * teamId = nil;
    if (value == 0) {
        teamId = _homeTeam.id;
    }else{
        teamId = _guestTeam.id;
    }

    ActionManager * am = [ActionManager defaultManager];
    self.actionRecords = [self actionsForTeam:teamId inActions:am.actionArray];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LocalString(@"ActionRecords");
    [[Feature defaultFeature] initNavleftBarItemWithController:self];
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(swip:)];
    swip.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swip];
    
    self.tableView.delegate = self;
    self.tableView.editing = YES;
    
    [self.teamSelector addTarget:self action:@selector(teamChanged) forControlEvents:UIControlEventValueChanged];
    
    [self initView];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self teamChanged];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
//- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 44.0;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.actionRecords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    Action * action = [self.actionRecords objectAtIndex:indexPath.row];
    
//    Team * team;
//    TeamManager * tm = [TeamManager defaultManager];
//    team = [tm teamWithId:action.team];
//    // 球队名字。    
//    cell.textLabel.text = team.name;
    // 操作记录 TODO 应该跟NewActionViewController中的字符串使用同一套。
    NSString * actionStr;
    switch ([action.type intValue]) {
        case ActionType1Point:
            actionStr = LocalString(@"1PTS");
            break;
        case ActionType2Points:
            actionStr = LocalString(@"2PTS");
            break;
        case ActionType3Points:
            actionStr = LocalString(@"3PTS");
            break;
        case ActionTypeFoul:
            actionStr = LocalString(@"PF");
            break;
        case ActionTypeTimeoutRegular:
            actionStr = LocalString(@"TO");
            break;

        default:
            break;
    }
    //时间
    NSInteger time = [action.time intValue];
    NSString * peroid = [[MatchUnderWay defaultMatch] nameForPeriod:[action.period integerValue]];    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %02d:%02d  %@", peroid,time/60,time%60, actionStr];
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return LocalString(@"ActionDelete");
//}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Action * action = [self.actionRecords objectAtIndex:indexPath.row];
        [[MatchUnderWay defaultMatch] deleteWrongAction:action];

        [self.actionRecords removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // 测试中发现，极少发生一次多个误操作，每次都只用删除一个action，
        // 所以删除后自动返回上级，减少一次操作。
        [self.navigationController popViewControllerAnimated:YES];
    }   
}
@end
