//
//  TeamsInGameViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChooseTeamViewController.h"
#import "TeamManager.h"
#import "GameSetting.h"
#import "ImageManager.h"
#import "ActionManager.h"
#import "AppDelegate.h"
#import "PlayGameViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TeamInfoViewController.h"
#import "Feature.h"

typedef enum{
    TeamCellStyleNotSelected = 0,    
    TeamCellStyleSelected = 1,    
    
    TeamCellTagSelection = 5,
    TeamCellTagProfile = 6,
    TeamCellTagName = 7
    
}TeamCell;

@interface ChooseTeamViewController (){
    Team * _homeTeam;
    Team * _guestTeam;
    
    NSInteger _homeTeamIndex;
    NSInteger _guestTeamIndex;
}

@end

@implementation ChooseTeamViewController

@synthesize tableView = _tableView;
@synthesize teamCell = _teamCell;
@synthesize homeImageView = _homeImageView;
@synthesize guestImageView = _guestImageView;
@synthesize startMatchButton = _startMatchButton;

- (NSString *)pageName {
    MatchUnderWay * match = [MatchUnderWay defaultMatch];
    NSString * pageName = @"ChooseTeam_";
    pageName = [pageName stringByAppendingString:match.matchMode];
    return pageName;
}

- (void)checkStartMatchButtonEnabled {
    static CAShapeLayer * sShapeLayer = nil;
    
    if (_homeTeam == nil || _guestTeam == nil) {
        [sShapeLayer removeFromSuperlayer];

        self.startMatchButton.enabled = NO;
    }else {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (sShapeLayer == nil) {
                CAShapeLayer * layer = [CAShapeLayer layer];
                CGSize radii = CGSizeMake(5, 30);
                UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.startMatchButton.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:radii];
                layer.path = path.CGPath;
                layer.fillColor = [MainColor CGColor];
                
                sShapeLayer = layer;
            }
        });
        
        // 这里不能用 layer.mask，因为我还要修改区域背景的颜色，layer.mask 只有 alpha 通道用来拦截图形。
        [self.startMatchButton.layer insertSublayer:sShapeLayer atIndex:0];

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

- (void)reloadTeams{
    [self.tableView reloadData];
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

    self.title = LocalString(@"ChooseTeam");
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = item;
    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewTeam:)];
    self.navigationItem.rightBarButtonItem = item;
    
    [self.startMatchButton setTitle:LocalString(@"Done") forState:UIControlStateNormal];
    [self checkStartMatchButtonEnabled];
    
    [self makeRoundedView:_homeImageView withRadius:3.0];
    [self makeRoundedView:_guestImageView withRadius:3.0];
    
    // 添加新球队后，刷新球队数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTeams) name:kTeamChanged object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[self pageName]];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    static BOOL DebugMode = NO;

    // FIXME: 测试用，默认自动选中前两队
    DebugMode = YES;
    
    if (DebugMode) {
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [self startMatchTouched:self.startMatchButton];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[self pageName]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray * teams = [TeamManager defaultManager].teams;
    return teams.count;
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
    
    UITableViewCell * cell = nil;
    // 这个ID必须跟xib中设置的保持一致。
    if (indexPath.section == 0) {
        UIImageView * profileImageView;
        static NSString *CellIdentifier = @"TeamSelectionCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
        Team * team = [teams objectAtIndex:indexPath.row];
        
        // 选中标志。
        BOOL selected = (team == _homeTeam || team == _guestTeam);
        [self updateSelectedMark:selected forCell:cell];
        
        // 球队图片。
        if (profileImageView == nil) {
            profileImageView = [self profileImageViewInCell:cell];
        }
        profileImageView.image = [[ImageManager defaultInstance] imageForName:team.profileURL];
        
        // 球队名称。
        UILabel * label = (UILabel *)[cell viewWithTag:TeamCellTagName];
        label.text = team.name;
    }
    
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
        _homeImageView.image = [[ImageManager defaultInstance] imageForName:_homeTeam.profileURL];
    }else{
        _homeImageView.image = [self teamPanelBackgroundImage];
    }
    
    if (_guestTeam) {
        _guestImageView.image = [[ImageManager defaultInstance] imageForName:_guestTeam.profileURL];
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

- (void)selectTeam:(Team *)team withFlag:(BOOL)selected atIndexPath:(NSIndexPath *)indexPath{
    if (selected) {
        // 添加选中的球队信息。
        if (_homeTeam == nil) {
            _homeTeam = team;
            _homeTeamIndex = indexPath.row;
        }else if(_guestTeam == nil){
            _guestTeam = team;
            _guestTeamIndex = indexPath.row;
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

- (void)addNewTeam:(id)sender{
    // 添加新球队
    TeamInfoViewController * editTeam = [[TeamInfoViewController alloc] initWithNibName:@"TeamInfoViewController" bundle:nil];
    editTeam.operateMode = Insert;
    editTeam.popViewControllerWhenFinished = YES;
    [self.navigationController pushViewController:editTeam animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    Team * team = [[[TeamManager defaultManager] teams] objectAtIndex:indexPath.row];
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
