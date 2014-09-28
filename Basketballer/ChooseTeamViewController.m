//
//  TeamsInGameViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TeamsInGameViewController.h"
#import "TeamManager.h"
#import "GameSetting.h"
#import "ActionManager.h"
#import "AppDelegate.h"
#import "PlayGameViewController.h"
#import <QuartzCore/QuartzCore.h>

typedef enum{
    TeamCellStyleNotSelected = 0,    
    TeamCellStyleSelected = 1,    
    
    TeamCellTagSelection = 5,
    TeamCellTagProfile = 6,
    TeamCellTagName = 7
    
}TeamCell;

@interface TeamsInGameViewController (){
    Team * _homeTeam;
    Team * _guestTeam;
    
    NSInteger _homeTeamIndex;
    NSInteger _guestTeamIndex;
}

@end

@implementation TeamsInGameViewController

@synthesize tableView = _tableView;
@synthesize teamCell = _teamCell;
@synthesize homeImageView = _homeImageView;
@synthesize guestImageView = _guestImageView;
@synthesize startMatchButton = _startMatchButton;

- (void)checkStartMatchButtonEnabled {
    if (_homeTeam == nil || _guestTeam == nil) {
        [self.startMatchButton setBackgroundImage:nil forState:UIControlStateNormal];
        self.startMatchButton.enabled = NO;
    }else {
        [self.startMatchButton setBackgroundImage:[UIImage imageNamed:@"btnBlue"] forState:UIControlStateNormal];
        self.startMatchButton.enabled = YES;
    }
}

- (UIImage *)teamPanelBackgroundImage{
    return [UIImage imageNamed:@"TeamsPanelDotRect"];
}

- (void)reloadCellWithSelectedIndex:(NSInteger)index{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    NSArray * selectedIndexPath = [NSArray arrayWithObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:selectedIndexPath withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)homeImageTouched:(id)sender{
    if (_homeTeam != nil) {
        _homeTeam = nil;
        self.homeImageView.image = [self teamPanelBackgroundImage];
        [self reloadCellWithSelectedIndex:_homeTeamIndex];
        [self checkStartMatchButtonEnabled];
    }
}

- (IBAction)guestImageTouched:(id)sender{
    if (_guestTeam != nil) {
        _guestTeam = nil;
        self.guestImageView.image = [self teamPanelBackgroundImage];
        [self reloadCellWithSelectedIndex:_guestTeamIndex];
        [self checkStartMatchButtonEnabled];
    }
}

- (IBAction)startMatchTouched:(id)sender{
    PlayGameViewController * playGameViewController = [[PlayGameViewController alloc] initWithNibName: @"PlayGameViewController" bundle:nil];
    
    [playGameViewController initWithHostTeam:_homeTeam andGuestTeam:_guestTeam];
    playGameViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:playGameViewController animated:YES];    
}

- (void)makeRoundedView:(UIImageView *)imageView withRadius:(float)radius{
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 5.0f;
}

- (void)dismiss{
    [[AppDelegate delegate] dismissModelViewController];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = 56.0f;

    self.title = LocalString(@"SelectTeam");
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = item;
    
    [self.startMatchButton setTitle:LocalString(@"Done") forState:UIControlStateNormal];
    [self checkStartMatchButtonEnabled];
    
    [self makeRoundedView:_homeImageView withRadius:3.0];
    [self makeRoundedView:_guestImageView withRadius:3.0];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSArray * teams = [TeamManager defaultManager].teams;
    return teams.count;    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UIImageView *)profileImageViewInCell:(UITableViewCell *)cell{
    return (UIImageView *)[cell viewWithTag:TeamCellTagProfile];    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (0 == section) {
        return LocalString(@"SelectTeamGuide");
    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIImageView * profileImageView;    
    // 这个ID必须跟xib中设置的保持一致。
    static NSString *CellIdentifier = @"TeamSelectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TeamSelectionCell" owner:self options:nil];
        cell = _teamCell;
        self.teamCell = nil;
        
        cell.tag = TeamCellStyleNotSelected;
        
        // 图片圆角化。
        profileImageView = [self profileImageViewInCell:cell];
        [self makeRoundedView:profileImageView withRadius:5.0];
    }
    
    NSArray * teams = [[TeamManager defaultManager] teams];
    Team * team = [teams objectAtIndex:indexPath.section];
    
    // 选中标志。
    BOOL selected = (team == _homeTeam || team == _guestTeam);
    [self updateSelectedMark:selected forCell:cell];
    
    // 球队图片。
    if (profileImageView == nil) {
        profileImageView = [self profileImageViewInCell:cell];
    }
    profileImageView.image = [[TeamManager defaultManager] imageForTeam:team];
    
    // 球队名称。        
    UILabel * label = (UILabel *)[cell viewWithTag:TeamCellTagName];     
    label.text = team.name;
    
    return cell;
}

- (BOOL)isCellSelected:(UITableViewCell *)cell{
    return cell.tag == TeamCellStyleSelected ? YES : NO;
}

- (UIImage *)selectedImage{
    return [UIImage imageNamed:@"CellBlueSelected"];
}

- (UIImage *)notSelectedImage{
    return [UIImage imageNamed:@"CellNotSelected"];
}

- (void)updateTeamsPanel{
    if (_homeTeam) {
        _homeImageView.image = [[TeamManager defaultManager] imageForTeam:_homeTeam];
    }else{
        _homeImageView.image = [self teamPanelBackgroundImage];
    }
    
    if (_guestTeam) {
        _guestImageView.image = [[TeamManager defaultManager] imageForTeam:_guestTeam];
    }else{
        _guestImageView.image = [self teamPanelBackgroundImage];
    }
    
    [self checkStartMatchButtonEnabled];
}

- (void)updateSelectedMark:(BOOL)selected forCell:(UITableViewCell *)cell{
    cell.tag = selected ? TeamCellStyleSelected : TeamCellStyleNotSelected;
    
    UIImage * image = selected ? [self selectedImage] : [self notSelectedImage];        
    UIImageView * selectedView = (UIImageView *)[cell viewWithTag:TeamCellTagSelection];
    selectedView.image = image;
}

- (NSInteger)selectedIndexAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section;
}

- (void)selectTeam:(Team *)team withFlag:(BOOL)selected atIndexPath:(NSIndexPath *)indexPath{
    if (selected) {
        // 添加选中的球队信息。
        if (_homeTeam == nil) {
            _homeTeam = team;
            _homeTeamIndex = [self selectedIndexAtIndexPath:indexPath];
        }else if(_guestTeam == nil){
            _guestTeam = team;
            _guestTeamIndex = [self selectedIndexAtIndexPath:indexPath];
        }
    }else{
        
        // 取消选中的球队信息。
        if (_homeTeam == team) {
            _homeTeam = nil;
        }else if(_guestTeam == team){
            _guestTeam = nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    Team * team = [[[TeamManager defaultManager] teams] objectAtIndex:indexPath.section];
    BOOL toBeSelected = [self isCellSelected:cell] ? NO : YES;

    if (toBeSelected && _homeTeam && _guestTeam) {
        // 两支参赛队都已选择，不能继续添加。
        return;
    }
    
    [self selectTeam:team withFlag:toBeSelected atIndexPath:indexPath];
    
    // 更新Cell的选中状态。
    [self updateSelectedMark:toBeSelected forCell:cell];
    
    // 更新最下方面板中的图片。
    [self updateTeamsPanel];    
}


@end
