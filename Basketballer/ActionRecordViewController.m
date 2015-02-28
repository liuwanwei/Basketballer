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
#import "MatchFinishedDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Feature.h"
#import "AppDelegate.h"
#import "UIImageView+Additional.h"
#import "ImageManager.h"
#import "ActionRecordCell.h"

@interface ActionRecordViewController () {
    CGPoint _touchBeganPoint;
    Team * _homeTeam;
    Team * _guestTeam;
    
    NSMutableArray * _actionRecords;
}
@end

@implementation ActionRecordViewController
@synthesize tableView = _tableView;

#pragma 私有函数
- (void)initView{
    MatchUnderWay * match = [MatchUnderWay defaultMatch];
    
    if (_homeTeam == nil || _guestTeam == nil) {
        TeamManager * teamManager = [TeamManager defaultManager];
        _homeTeam = [teamManager teamWithId:match.home.teamId];
        _guestTeam = [teamManager teamWithId:match.guest.teamId];
    }
    [self.hostImageView makeCircle];
    self.hostImageView.layer.borderWidth = 2;
    self.hostImageView.layer.borderColor = [[UIColor colorWithRed:221 green:221 blue:221 alpha:1.0] CGColor];
    self.hostImageView.image = [[ImageManager defaultInstance] imageForName:_homeTeam.profileURL];
    self.hostLabel.text = _homeTeam.name;
    
    [self.guestImageView makeCircle];
    self.guestImageView.layer.borderWidth = 2;
    self.guestImageView.layer.borderColor = [[UIColor colorWithRed:221 green:221 blue:221 alpha:1.0] CGColor];
    self.guestImageView.image = [[ImageManager defaultInstance] imageForName:_guestTeam.profileURL];
    self.guestLabel.text = _guestTeam.name;
    
    self.actionRecordLabel.text = LocalString(@"ActionRecords");
}

- (void)initData {
    ActionManager * am = [ActionManager defaultManager];
    if (nil != am.actionArray && [am.actionArray count] > 0) {
        _actionRecords = [[NSMutableArray alloc] init];
        NSMutableDictionary * dic;
        NSNumber * key;
        NSMutableArray * tempActionRecords;
        Action * lastAction;
        for (Action * action in am.actionArray) {
            if (lastAction.period != action.period) {
                key = action.period;
                tempActionRecords = [[NSMutableArray alloc] init];
                dic = [[NSMutableDictionary alloc] init];
                [dic setObject:tempActionRecords forKey:key];
                [_actionRecords addObject:dic];
            }
            
            [tempActionRecords addObject:action];
            lastAction = action;
        }
    }
}

- (NSString *)pageName {
    MatchUnderWay * match = [MatchUnderWay defaultMatch];
    NSString * pageName = @"ActionRecord_";
    pageName = [pageName stringByAppendingString:match.matchMode];
    return pageName;
}

#pragma 事件函数
-(void) swip:(UISwipeGestureRecognizer *)swip {
    [self backToMatch:nil];
}

- (IBAction)backToMatch:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)realtimeStatistics:(id)sender{
    Match * match = [[MatchUnderWay defaultMatch] match];
    if (match == nil) {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"比赛未开始" message:@"开始比赛后，才能看到技术统计" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    
    self.navigationController.navigationBarHidden = NO;
    GameStatisticViewController * controller = [[GameStatisticViewController alloc] initWithNibName:@"GameStatisticViewController" bundle:nil];
    controller.match = match;
    [self.navigationController pushViewController:controller animated:YES];
    
//    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
//    [self presentViewController:nav animated:YES completion:nil];
}

//- (NSMutableArray *)actionsForTeam:(NSNumber *)teamId inActions:(NSArray *)allActions{
//    if (! allActions) {
//        return nil;
//    }
//    
//    NSMutableArray * resultArray = nil;
//    for(Action * action in allActions){
//        if ([action.team isEqualToNumber:teamId]) {
//            if (! resultArray) {
//                resultArray = [[NSMutableArray alloc] initWithObjects:action, nil];
//            }else{
//                [resultArray addObject:action];
//            }
//        }
//    }
//    
//    return resultArray;
//}
//
//- (void)teamChanged{
//    NSInteger value = self.teamSelector.selectedSegmentIndex;
//    NSNumber * teamId = nil;
//    if (value == 0) {
//        teamId = _homeTeam.id;
//    }else{
//        teamId = _guestTeam.id;
//    }
//
//    ActionManager * am = [ActionManager defaultManager];
//    self.actionRecords = [self actionsForTeam:teamId inActions:am.actionArray];
//    
//    [self.tableView reloadData];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(swip:)];
    swip.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swip];
    
    self.tableView.delegate = self;
//    self.tableView.rowHeight = 60.0;
    
    [self initView];
    [self initData];
    
    if (IOS_7) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[self pageName]];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:[self pageName]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (nil == _actionRecords) {
        return 0;
    }
    
    return [_actionRecords count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableDictionary * dic = [_actionRecords objectAtIndex:section];
    NSArray * tempActionRecords = [dic objectForKey:[[dic allKeys] objectAtIndex:0]];
    return [tempActionRecords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActionRecordCell";
    ActionRecordCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ActionRecordCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSMutableDictionary * dic = [_actionRecords objectAtIndex:indexPath.section];
    NSArray * tempActionRecords = [dic objectForKey:[[dic allKeys] objectAtIndex:0]];
    Action * action = [tempActionRecords objectAtIndex:indexPath.row];
    cell.hostId = _homeTeam.id;
    cell.guestId = _guestTeam.id;
    cell.action = action;
    
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    NSMutableDictionary * dic = [_actionRecords objectAtIndex:section];
//    NSString * peroid = [[MatchUnderWay defaultMatch] nameForPeriod:[[[dic allKeys] objectAtIndex:0] integerValue]];
//    return peroid;
//}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        Action * action = [[ActionManager defaultManager].actionArray objectAtIndex:indexPath.row];
        NSMutableDictionary * dic = [_actionRecords objectAtIndex:indexPath.section];
        NSMutableArray * tempActionRecords = [dic objectForKey:[[dic allKeys] objectAtIndex:0]];
        Action * action = [tempActionRecords objectAtIndex:indexPath.row];
        
        [[MatchUnderWay defaultMatch] deleteWrongAction:action];
        [tempActionRecords removeObject:action];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // 测试中发现，极少发生一次多个误操作，每次都只用删除一个action，
        // 所以删除后自动返回上级，减少一次操作。
        [self.navigationController popViewControllerAnimated:YES];
    }   
}

#define SectionHeaderHeight         20.0f
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString * headerIdentifier = @"header";
    UITableViewHeaderFooterView * header = nil;
    header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];

    if (header == nil) {
        header = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerIdentifier];
        [header setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, SectionHeaderHeight)];
//        header.backgroundColor = [UIColor lightTextColor];

        UIView * backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, SectionHeaderHeight)];
        backgroundView.backgroundColor = [UIColor clearColor];
        header.backgroundView = backgroundView;
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, SectionHeaderHeight - 2)];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [[UIColor alloc] initWithRed:91/255.0 green:179/255.0 blue:240/255.0 alpha:1];
        label.tag = 1;
        [header addSubview:label];
        
        UIView * sepraterView = [[UIView alloc] initWithFrame:CGRectMake(0, SectionHeaderHeight - 1, self.tableView.bounds.size.width, 1)];
        sepraterView.backgroundColor = [[UIColor alloc] initWithRed:231/255.0 green:230/255.0 blue:231/255.0 alpha:1];
        [header addSubview:sepraterView];
    }
    
    NSMutableDictionary * dic = [_actionRecords objectAtIndex:section];
    NSString * peroid = [[MatchUnderWay defaultMatch] nameForPeriod:(MatchPeriod)[[[dic allKeys] objectAtIndex:0] integerValue]];
    UILabel * label = (UILabel *)[header viewWithTag:1];
    label.text = peroid;
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SectionHeaderHeight;
}
@end
