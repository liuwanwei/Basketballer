//
//  NewActionViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewActionViewController.h"
#import "PlayerActionViewController.h"
#import "ActionManager.h"
#import "AppDelegate.h"
#import "PlayerManager.h"
#import "GameSetting.h"
#import "MatchUnderWay.h"
#import "Team.h"
#import "TeamStatistics.h"
#import "Feature.h"

static 
ActionType _actionTypeArray[][3] = {{ActionType3Points, ActionType2Points, ActionType1Point}, 
                                    {ActionTypeFoul, 0, 0},
                                    {ActionTypeTimeoutRegular, 0, 0}};

@interface NewActionViewController (){
    NSArray * _sectionLabels;
    NSArray * _sectionDetails;
    NSInteger _sectionCount;
    NSArray * _rowImages;
    
    ActionType _selectedActionType;
    ActionManager * _actionManager;
}

@end

@implementation NewActionViewController

@synthesize team = _team;
@synthesize statistics = _statistics;

- (void)showAlertView:(NSString *)message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:LocalString(@"Alert") 
                                               message:message delegate:self 
                                               cancelButtonTitle:LocalString(@"Ok") 
                                               otherButtonTitles:nil , nil];
    [alertView show];
}

- (void)notificationHandler:(NSNotification *)notification{
    NSNumber * playerId = nil;
    if (nil != notification) {
        playerId = notification.object;
        /*if (playerId == nil) {
            playerId = [NSNumber numberWithInt:0];
        }*/
    }
    
    UIViewController * viewController = (UIViewController *)[[AppDelegate delegate] playGameViewController];
    [self.navigationController popToViewController:viewController animated:YES];
    
    [[MatchUnderWay defaultMatch] addActionForTeam:_team.id forPlayer:playerId withAction:_selectedActionType];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationHandler:) name:kActionDetermined object:nil];
    
    _actionManager = [ActionManager defaultManager];
    
    NSArray * pointLabels, * pointDetails;
    NSArray * foulLabels, * foulDetails;
    NSArray * timeoutLabels, * timeoutDetails;
    pointLabels = [NSArray arrayWithObjects:
                   LocalString(@"3Points"),
                   LocalString(@"2Points"),
                   LocalString(@"FreeThrow"), nil];
    pointDetails = [NSArray arrayWithObjects:@"+ 3", @"+ 2", @"+ 1", nil];
    
    foulLabels = [NSArray arrayWithObjects:LocalString(@"Foul"), nil];
    foulDetails = [NSArray arrayWithObjects:@"+ 1", nil];
    
    timeoutLabels = [NSArray arrayWithObjects:LocalString(@"Timeout"), nil];
    timeoutDetails = [NSArray arrayWithObjects:@"+ 1", nil];
    
    //TODO if else 判断的办法比较笨，可以建一个NewActionView的基类，让两个界面继承自基类，各自做自己的事情
    if (![[MatchUnderWay defaultMatch].matchMode isEqualToString:kMatchModeAccount]) {
        _sectionLabels = [NSArray arrayWithObjects:pointLabels, foulLabels, timeoutLabels, nil];
        _sectionDetails = [NSArray arrayWithObjects:pointDetails, foulDetails, timeoutDetails, nil];
    }else {
        _sectionLabels = [NSArray arrayWithObjects:pointLabels, nil];
        _sectionDetails = [NSArray arrayWithObjects:pointDetails, nil];
    }
   
    
    _sectionCount = _sectionLabels.count;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setTitle:LocalString(@"NewStatistic")];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.team.name;        
    }else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * sectionRows = [_sectionLabels objectAtIndex:section];
    return sectionRows.count;
}

- (UIColor *)alarmColor{
    return [UIColor redColor];
}

- (UIColor *)normalColor{
    return [UIColor blackColor];
}


- (UIImage *)imageAtIndexPath:(NSIndexPath *)indexPath{
    NSString * imageName = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                imageName = @"ThreePoints";
                break;
            case 1:
                imageName = @"TwoPoints";
                break;
            case 2:
                imageName = @"FreeThrow";
            default:
                break;
        }
    }else if(indexPath.section == 1){
        imageName = @"Foul";
    }else if(indexPath.section == 2){
        imageName = @"TimeoutAction";
    }
    
    return [UIImage imageNamed:imageName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    UIImage * image = [self imageAtIndexPath:indexPath];
    cell.imageView.image = image;
    NSArray * labels = [_sectionLabels objectAtIndex:indexPath.section];
    cell.textLabel.text = [labels objectAtIndex:indexPath.row];
//    NSArray * details = [_sectionDetails objectAtIndex:indexPath.section];
//    cell.detailTextLabel.text = [details objectAtIndex:indexPath.row];
    
    MatchUnderWay * match = [MatchUnderWay defaultMatch];
    NSInteger timeoutLimit = [match.rule timeoutLimitBeforeEndOfPeriod:match.period];
    if ((indexPath.section == 1 && [_statistics.fouls intValue] > [match.rule foulLimitForTeam]) ||
        (indexPath.section == 2 && 
         [_statistics.timeouts intValue] >= timeoutLimit)){
        cell.textLabel.textColor = [self alarmColor];
    }else {
        cell.textLabel.textColor = [UIColor blackColor];
    }                
    
    if([[GameSetting defaultSetting] enablePlayerStatistics]){
        if (indexPath.section == 2) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.detailTextLabel.text = @"";
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.detailTextLabel.text = LocalString(@"Select");
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 记下当前选中的Action。
    _selectedActionType = _actionTypeArray[indexPath.section][indexPath.row];
    
    MatchUnderWay * match = [MatchUnderWay defaultMatch];
    if (indexPath.section == 2) {
        
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        
        if (match.state == MatchStateTimeout || 
    match.state == MatchStateTimeoutFinished ||
        match.state == MatchStateQuarterTime) {
            [self showAlertView:LocalString(@"AlreadyTimeouted")];
            
        }else if (match.state == MatchStatePeriodFinished ||
                  match.state == MatchStateQuarterTimeFinished) {
            [self showAlertView:LocalString(@"AlreadyPaused")];
        }else if ([_statistics.timeouts intValue] < 
                  [match.rule timeoutLimitBeforeEndOfPeriod:match.period]) {
            // 记暂停不需要进入球员列表。
            [[NSNotificationCenter defaultCenter] postNotificationName:kActionDetermined object:nil];
        }else {
            [self showAlertView:LocalString(@"NoTimeout")];
        }
    }else{
        // 开关打开时，记得分和犯规需要进入球员列表。
        if ([GameSetting defaultSetting].enablePlayerStatistics) {
            NSNumber * matchId = [MatchUnderWay defaultMatch].match.id;
            NSArray * players = [[PlayerManager defaultManager] playersForTeam:_team.id];     
            PlayerActionViewController * playerList = [[PlayerActionViewController alloc] initWithStyle:UITableViewStylePlain];
            playerList.players = players;
            playerList.teamId = _team.id;
            if (indexPath.section == 0) {
                playerList.actionType = ActionType3Points;
            }else {
                playerList.actionType = ActionTypeFoul;
                playerList.actionsInMatch = [[ActionManager defaultManager] actionsForMatch:[matchId integerValue]];
            }
           
            [self.navigationController pushViewController:playerList animated:YES];        
        }else{
            // 记录无球员对象的action。
            [[NSNotificationCenter defaultCenter] postNotificationName:kActionDetermined object:nil];            
        }             
    }
    

}

@end
