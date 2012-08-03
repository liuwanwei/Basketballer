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
#import <QuartzCore/QuartzCore.h>

@interface ActionRecordViewController () {
    CGPoint _touchBeganPoint;
}
@end

@implementation ActionRecordViewController
@synthesize tableView = _tableView;
@synthesize actionRecords = _actionRecords;

-(void) swip:(UISwipeGestureRecognizer *)swip {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"裁判记录";
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(swip:)];
    swip.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swip];
    
    self.tableView.delegate = self;
    self.tableView.editing = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

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
    
    Team * team;
    TeamManager * tm = [TeamManager defaultManager];
    team = [tm teamWithId:action.team];
    // 球队名字。    
    cell.textLabel.text = team.name;
    // 操作记录
    NSString * actionStr;
    switch ([action.type intValue]) {
        case ActionType1Point:
            actionStr = @"得分+1";
            break;
        case ActionType2Points:
            actionStr = @"得分+2";
            break;
        case ActionType3Points:
            actionStr = @"得分+3";
            break;
        case ActionTypeFoul:
            actionStr = @"犯规+1";
            break;
        case ActionTypeTimeout:
            actionStr = @"暂停+1";
            break;

        default:
            break;
    }
    //时间
    NSInteger time = [action.time intValue];
    NSString * peroid;
    switch ([action.period intValue]) {
        case 0:
            peroid = @"第一节";
            break;
        case 1:
            peroid = @"第二节";
            break;
        case 2:
            peroid = @"第三节";
            break;
        case 3:
            peroid = @"第四节";
            break;
        default:
            break;
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %02d:%02d  %@", peroid,time/60,time%60, actionStr];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"发生误操作时请在这里删除";
}

// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Action * action = [self.actionRecords objectAtIndex:indexPath.row];
        [[ActionManager defaultManager] deleteAction:action];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
