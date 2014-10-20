//
//  EditTeamInfoViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TeamInfoViewController.h"
#import "TeamManager.h"
#import "ImageManager.h"
#import "MatchManager.h"
#import "PlayerManager.h"
//#import "PlayerEditViewController.h"
#import "Feature.h"
#import "GameHistoryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Feature.h"
#import "AppDelegate.h"
#import "RosterViewController.h"
#import "ImageCell.h"
#import "TextEditorViewController.h"

@interface TeamInfoViewController() {
    NSArray * _matchesOfTeam;
    NSArray * _playersOfTeam;
    
    UIBarButtonItem * _cancelItem;
}
@end

@implementation TeamInfoViewController

@synthesize operateMode = _operateMode;
@synthesize team = _team;
@synthesize teamCell = _teamCell;

#pragma 私有函数

- (void)playerChanged{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
}

- (void)matchChanged{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
}

- (void)refreshRightBarButtonItem{
    if ((self.teamName != nil && self.teamName.length != 0) &&
        self.teamImage != nil) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

/*设置右导航按钮的enabled*/
- (void)setRightBarButtonItemEnable:(BOOL) enabled {
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

- (void)back {
    if (self.popViewControllerWhenFinished) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [[AppDelegate delegate] dismissModelViewController];
    }
}

// 球队名字修改消息处理
- (void) teamNameChangedNotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:kTextSavedMsg]) {
        if (notification.userInfo != nil) {
            NSString * teamName = [notification.userInfo objectForKey:kEditTeamName];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            UITableViewCell  *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            self.teamName = teamName;
            
            cell.detailTextLabel.text = teamName;
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self refreshRightBarButtonItem];
        }
    }
}

/*初始化导航按钮*/
- (void)initNavigationItem {
    UIBarButtonItem * rightItem;
    
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    _cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back)];
}

- (void)showActionSheet {
    UIActionSheet * menu = [[UIActionSheet alloc] 
            initWithTitle:nil delegate:self 
            cancelButtonTitle:LocalString(@"Cancel")
            destructiveButtonTitle:nil 
            otherButtonTitles:LocalString(@"FromLibrary"), LocalString(@"Snapshot"), nil];
    
    [menu showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)showPhotoAlbum {
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = YES;
        [self presentModalViewController:imagePickerController animated:YES];
    }
}

- (void)showCamera {
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.allowsEditing = YES;
        [self presentModalViewController:imagePickerController animated:YES];
    }
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
    
    // 注册消息处理函数
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    
    if (self.team != nil) {
        self.teamName = self.team.name;
        self.teamImage = [[ImageManager defaultInstance] imageForName:self.team.profileURL];
    }
    
    // 修改队员信息
    [nc addObserver:self selector:@selector(playerChanged) name:kPlayerChangedNotification object:nil];
    // 修改比赛信息
    [nc addObserver:self selector:@selector(matchChanged) name:kMatchChanged object:nil];
    // 修改队名
    [nc addObserver:self selector:@selector(teamNameChangedNotification:) name:kTextSavedMsg object:nil];
    
    [self initNavigationItem];
}

#pragma 类成员函数

- (void)viewDidUnload{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.navigationController != nil &&
        [self.navigationController.viewControllers count] == 1) {
        // 自身是UINavagationController中的RootViewController时，展示左侧“取消”按钮
        self.navigationItem.leftBarButtonItem = _cancelItem;
    }
    
    if (self.operateMode == Insert) {
        self.title = LocalString(@"CreateTeam");
    }else{
        self.title = LocalString(@"TeamInfo");
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)save{
    
    TeamManager * teamManager = [TeamManager defaultManager];
    if(self.operateMode == Insert) {
        [teamManager newTeam:self.teamName withImage:self.teamImage];
    }else {
        // 不改变图片路径，直接保存图片数据（覆盖到原路径中）。
        self.team.profileURL = [[ImageManager defaultInstance] saveImage:self.teamImage withProfileType:kProfileTypeTeam withObjectId:self.team.id];
        self.team.name = self.teamName;
        [teamManager synchroniseToStore];
    }
    
    [self back];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_operateMode == Update) {
        return 3;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ImageCell" owner:self options:nil];
        ImageCell * cell = [nib objectAtIndex:0];
        self.teamCell = cell;
        
        cell.title.text = LocalString(@"Profile");
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
        cell.profileImage.image = self.teamImage;
        
        return cell;
    }else if((indexPath.section == 0 && indexPath.row == 0) ||
             indexPath.section == 1 ||
             indexPath.section == 2){
        UITableViewCell *cell = nil;
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if (indexPath.section == 0) {
            cell.textLabel.text = LocalString(@"Name");
            cell.detailTextLabel.text = self.teamName;
        }else if(indexPath.section == 1){
            cell.textLabel.text = LocalString(@"Record");
            
            // 获取球队所有比赛记录数目和详情。数目用在这里，详情用于显示比赛列表。
            _matchesOfTeam = [[MatchManager defaultManager] matchesWithTeamId:[_team.id integerValue]];
            NSString * number;
            if (_matchesOfTeam.count > 0) {
                number = [NSString stringWithFormat:LocalString(@"MatchesFormatter"), _matchesOfTeam.count];
            }else{
                number = LocalString(@"NoMatch");
            }
            
            cell.detailTextLabel.text = number;
        }else if(indexPath.section == 2){
            cell.textLabel.text = LocalString(@"Roster");
            
            NSString * description;
            _playersOfTeam = [[PlayerManager defaultManager] playersForTeam:_team.id];
            if (_playersOfTeam == nil || _playersOfTeam.count == 0) {
                description = LocalString(@"NoPlayer");
            }else{
                description = [NSString stringWithFormat:LocalString(@"PlayersFormatter"), _playersOfTeam.count];
            }
            
            cell.detailTextLabel.text = description;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else{
        return nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 1) {
        [self showActionSheet];
    }else if(indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell  *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        TextEditorViewController * vc = [[TextEditorViewController alloc] initWithNibName:@"TextEditorViewController" bundle:nil];
        vc.keyboardType = UIKeyboardTypeNamePhonePad;
        vc.text = cell.detailTextLabel.text;
        vc.title = LocalString(@"TeamName");
        vc.textkey = kEditTeamName;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if(indexPath.section == 1 && indexPath.row == 0){
        GameHistoryViewController * history = [[GameHistoryViewController alloc] initWithNibName:@"GameHistoryViewController" bundle:nil];
        history.matches = _matchesOfTeam;
        history.historyType = HistoryTypeTeam;
        [self.navigationController pushViewController:history animated:YES];
    }else if(indexPath.section == 2 && indexPath.row == 0){
        RosterViewController * playerList = [[RosterViewController alloc] initWithNibName:@"RosterViewController" bundle:nil];

        playerList.teamId = _team.id;
        playerList.title = @"队员名单";
        
        [self.navigationController pushViewController:playerList animated:YES];
    }
}

#pragma mark - ActionSheet view delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        [self showPhotoAlbum];
    }else if(buttonIndex == 1){
        [self showCamera];
    }
}

#pragma mark - ImagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell  *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView * profileImageView;
    profileImageView = (UIImageView *)[cell viewWithTag:1];

    profileImageView.image = image;
    
    self.teamImage = image;
    
    [self refreshRightBarButtonItem];
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
