//
//  StartGameViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StartGameViewController.h"
#import "TeamChoiceViewController.h"
#import "TeamManager.h"
#import "PlayGameViewController.h"
#import "GameSetting.h"
#import "AppDelegate.h"
#import "Feature.h"
#import "GameSettingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface StartGameViewController () {
    NSArray * _sectionsTitle;
    Team * _hostTeam;
    Team * _guestTeam;
    NSInteger _curClickRowIndex;
    
    NSString * __weak _gameMode;
    SingleChoiceViewController * _chooseGameModeView;
}
@end

@implementation StartGameViewController
@synthesize teamCell = _teamCell;
@synthesize modeCell = _modeCell;
@synthesize startMatchView = _startMatchView;

#pragma 私有函数
/*显示提示信息*/
- (void)showAlertView:(NSString *) message{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定" , nil];
    [alertView show];
}

- (void)dismissMyself{
    [[AppDelegate delegate] dismissModelViewController];
}

#pragma 类成员函数
- (void)refreshTableData:(Team *) team{
    if(team == nil) {
        return;
    }
    if(_curClickRowIndex == 0) {
        _hostTeam = team;
    }else if(_curClickRowIndex == 1){
        _guestTeam = team;
    }
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:_curClickRowIndex];
    UITableViewCell  *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView * profileImageView = (UIImageView *)[cell viewWithTag:1];
    UILabel * label = (UILabel *)[cell viewWithTag:2]; 
    profileImageView.image = [[TeamManager defaultManager] imageForTeam:team];
    label.text = team.name;
}

- (void)handleNotification:(NSNotification *)notification{
    NSLog(@"StartGameViewController got notification");
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
    
    _sectionsTitle = [NSArray arrayWithObjects:@"主队", @"客队" ,@"竞技规则",nil];
    
    _gameMode = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:0];  
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleNotification:) name:kTeamChanged object:nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [[Feature defaultFeature] weChatTableBgColor];
    
//    [[NSBundle mainBundle] loadNibNamed:@"StartMatchCell" owner:self options:nil];
//    CGRect frame = self.startMatchView.frame;
//    frame.size.width = 160;
//    self.startMatchView.frame = frame;
//    self.tableView.tableFooterView = self.startMatchView;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)startGame:(id)sender {
    if (_hostTeam == nil || _guestTeam == nil) {
        [self showAlertView:@"请选择球队信息"];
        return;
    }
    
    if(_hostTeam == _guestTeam) {
        [self showAlertView:@"不能选择相同球队进行比赛"];
        return;
    }
    
    PlayGameViewController * playGameViewController = [[PlayGameViewController alloc] initWithNibName: @"PlayGameViewController" bundle:nil];
    playGameViewController.hostTeam = _hostTeam;
    playGameViewController.guestTeam = _guestTeam;
    playGameViewController.gameMode = [[GameSetting defaultSetting] gameModeForName:_gameMode];
    playGameViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:playGameViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//   return [_sectionsTitle objectAtIndex:section];
    if(section == 1){
        return @"                           vs.";
    }else if(section == 2){
        return nil;
//        return @"规则";
//        return @"比赛模式";
    }else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return [[[GameSetting defaultSetting] gameModes] count];
    }else{
        return 1;   
    }
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return  0.1f;
    }else{
        return 0.0f;
    }
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 23.0f;
    }else if(section == 2){
        return 50.0f;
    }else{
        return 0.0f;
    }
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        return 44.0f;
    }else{
        return 56.0f;   
    }    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    if (indexPath.section == 0 || indexPath.section == 1) {
        [[NSBundle mainBundle] loadNibNamed:@"TeamRecordCell" owner:self options:nil];
        cell = _teamCell;
        self.teamCell = nil;   
    
        // 图片圆角化。
        UIImageView * profileImageView;        
        profileImageView = (UIImageView *)[cell viewWithTag:1];
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = 5.0f;

        UILabel * label = (UILabel *)[cell viewWithTag:2]; 
        Team * team = [[TeamManager defaultManager].teams objectAtIndex:indexPath.section];
        if (indexPath.section == 0) {
            _hostTeam = team;
        }else {
            _guestTeam = team;
        }
        
        profileImageView.image = [[TeamManager defaultManager] imageForTeam:team];
        label.text = team.name;
    }else if (indexPath.section == 2){   
//        [[NSBundle mainBundle] loadNibNamed:@"MatchModeCell" owner:self options:nil];
//        cell = _modeCell;
//        self.modeCell = nil;
    
//        UILabel * label;
//        label = (UILabel *)[cell viewWithTag:2];
//        label.text = _gameMode;
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];        
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = @"go!"; 
        cell.imageView.image = [UIImage imageNamed:@"Add"];
    }
        
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0 || section == 1) {
        _curClickRowIndex = indexPath.section;
        TeamChoiceViewController *teamChoiceViewController = [[TeamChoiceViewController alloc] initWithNibName:@"TeamChoiceViewController" bundle:nil];

        teamChoiceViewController.choosedTeamId = (section == 0 ? _hostTeam.id : _guestTeam.id);
        teamChoiceViewController.parentController = self;
        teamChoiceViewController.viewControllerMode = UITeamChoiceViewControllerModeChoose;
        teamChoiceViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:teamChoiceViewController animated:YES];
    }else if(indexPath.section == 2){
        _gameMode = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:indexPath.row];
        [self startGame:nil];
//        if (indexPath.row == 0) {
//            if (_chooseGameModeView == nil) {
//                _chooseGameModeView = [[SingleChoiceViewController alloc] initWithStyle:UITableViewStyleGrouped];
//                _chooseGameModeView.choices = [[GameSetting defaultSetting] gameModeNames];  
//                _chooseGameModeView.delegate = self;
//            }
//            
//            _chooseGameModeView.currentChoice = _gameMode;
//            _chooseGameModeView.hidesBottomBarWhenPushed = YES;
//            [_chooseGameModeView setTitle:@"比赛模式"];
//            [self.navigationController pushViewController:_chooseGameModeView animated:YES];
//        }
    }
}


# pragma SingleChoiceViewDelegate
- (void)choosedParameter:(NSString *)parameter{
    _gameMode = parameter;
    // TODO 只刷新group2就够了。
    [self.tableView reloadData];
}

@end
