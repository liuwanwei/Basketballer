//
//  EditTeamInfoViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EditTeamInfoViewController.h"
#import "TeamManager.h"
#import "MatchManager.h"
#import "PlayerManager.h"
#import "EditTeamNameViewController.h"
#import "PlayerEditViewController.h"
#import "Feature.h"
#import "GameHistoriesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Feature.h"
#import "AppDelegate.h"

@interface EditTeamInfoViewController() {
    NSArray * _matchesOfTeam;
    NSArray * _playersOfTeam;
    
    UIImage * _image;
    BOOL _dirty;
}
@end

@implementation EditTeamInfoViewController

@synthesize rowsTitle = _rowsTitle;
@synthesize operateMode = _operateMode;
@synthesize team = _team;
@synthesize teamCell = _teamCell;

#pragma 私有函数
- (void)showAlertView:(NSString *)message{
    UIAlertView * alertView;
    alertView = [[UIAlertView alloc] initWithTitle:@"确认" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定" , nil];
    
    [alertView show];
}

- (void)playerChanged{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
}

- (void)matchChanged{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
}

/*设置右导航按钮的enabled*/
- (void)setRightBarButtonItemEnable:(BOOL) enabled {
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

- (void)delTeam{    
    [self showAlertView:@"删除球队信息?删除后信息不可恢复。"];
}

- (void)save {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell  *cell = [self.tableView cellForRowAtIndexPath:indexPath];;
    NSString * teamName = cell.detailTextLabel.text;
    if (teamName.length != 0) {
        TeamManager * teamManager = [TeamManager defaultManager];
        if(self.operateMode == Insert) {
            [teamManager newTeam:teamName withImage:_image];
        }else {
            if (_dirty) {
                [teamManager modifyTeam:self.team withNewName:teamName];
                [teamManager modifyTeam:self.team withNewImage:_image];
                _dirty = NO;
            }
        }
    }
    
    if (_operateMode == Insert) {
        [[AppDelegate delegate] dismissModelViewController];
    }else{
        self.hidesBottomBarWhenPushed = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)back {
    [[AppDelegate delegate] dismissModelViewController];
}

/*初始化导航按钮*/
- (void)initNavigationItem {
    
    UIBarButtonItem * rightItem;
    if (_operateMode == Insert) {
        rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(save)];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        [[Feature defaultFeature] initNavleftBarItemWithController:self withAction:@selector(back)];
    }else if (_operateMode == Update) {
        if ([_team.id intValue] != 1 && [_team.id intValue] != 2) {
            rightItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStyleBordered target:self action:@selector(delTeam)];
            self.navigationItem.rightBarButtonItem = rightItem;
        }
        
        [[Feature defaultFeature] initNavleftBarItemWithController:self withAction:@selector(save)];
    }
}

- (void)initRowsTitle {
    self.rowsTitle = [NSArray arrayWithObjects:@"球队名称",@"选择头像", nil]; 
}

- (void)showActionSheet {
    UIActionSheet * menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"用户相册",@"拍照", nil];
    [menu showFromTabBar:[[AppDelegate delegate] tabBarController].tabBar];
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

#pragma 类成员函数
- (void) refreshViewWithTeamName:(NSString *) teamName {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell  *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(teamName == nil || 
       teamName.length == 0) {
        [self setRightBarButtonItemEnable:NO];
        cell.detailTextLabel.text = @"";
    }else {
        [self setRightBarButtonItemEnable:YES];
        cell.detailTextLabel.text = teamName;
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
    
    self.tableView.backgroundColor = [[Feature defaultFeature] weChatTableBgColor];
    [self initRowsTitle];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(playerChanged) name:kPlayerChangedNotification object:nil];
    [nc addObserver:self selector:@selector(matchChanged) name:kMatchChanged object:nil];
    
    _dirty = NO;
}

- (void)viewDidUnload{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initNavigationItem];
    if (_operateMode == Insert) {
        [self setTitle:@"组建球队"];
    }else{
        [self setTitle:@"球队信息"];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [self.rowsTitle objectAtIndex:section];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else{
        return 1;
    }
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0) {
//         return 56.0;
//    }else {
//         return 44.0f;
//    }
//   
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
   if (indexPath.section == 0 && indexPath.row == 1) {
        UIImageView * profileImageView;

        [[NSBundle mainBundle] loadNibNamed:@"TeamImageEditCell" owner:self options:nil];
        cell = _teamCell;
        self.teamCell = nil;
        
        // 图片圆角化。
        profileImageView = (UIImageView *)[cell viewWithTag:1];
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = 5.0f;

        TeamManager * teamManager = [TeamManager defaultManager]; 
        profileImageView.image = [teamManager imageForTeam:self.team];  
   }else if((indexPath.section == 0 && indexPath.row == 0) || indexPath.section == 1 || indexPath.section == 2){
       static NSString *CellIdentifier = @"Cell";  
       cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
       if (nil == cell) {
           cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
           cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
       }
       
       if (indexPath.section == 0) {
           cell.textLabel.text = @"名字";
           cell.detailTextLabel.text = self.team.name;
       }else if(indexPath.section == 1){
           cell.textLabel.text = @"比赛记录";
           
           // 获取球队所有比赛记录数目和详情。数目用在这里，详情用于显示比赛列表。
           _matchesOfTeam = [[MatchManager defaultManager] matchesWithTeamId:[_team.id integerValue]];
           NSString * number;
           if (_matchesOfTeam.count > 0) {
               number = [NSString stringWithFormat:@"%d 场比赛", _matchesOfTeam.count];
           }else{
               number = @"没有比赛";
           }

           cell.detailTextLabel.text = number;
       }else if(indexPath.section == 2){
           cell.textLabel.text = @"队员名单";
           
           NSString * description;
           _playersOfTeam = [[PlayerManager defaultManager] playersForTeam:_team.id];
           if (_playersOfTeam == nil || _playersOfTeam.count == 0) {
               description = @"添加队员";
           }else{
               description = [NSString stringWithFormat:@"%d 名队员", _playersOfTeam.count];
           }
           
           cell.detailTextLabel.text = description;
       }
   } 
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 1) {
        [self showActionSheet];
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    }else if(indexPath.section == 0 && indexPath.row == 0) {
        EditTeamNameViewController * editTeamNameViewController = [[EditTeamNameViewController alloc] initWithNibName:@"EditTeamNameViewController" bundle:nil];
        editTeamNameViewController.teamName = self.team.name;
        editTeamNameViewController.parentController = self;
        [self.navigationController pushViewController:editTeamNameViewController animated:YES];
        _dirty = YES;
        
    }else if(indexPath.section == 1 && indexPath.row == 0){
        GameHistoriesViewController * history = [[GameHistoriesViewController alloc] initWithNibName:@"GameHistoriesViewController" bundle:nil];
        history.matches = _matchesOfTeam;
        [self.navigationController pushViewController:history animated:YES];
    }else if(indexPath.section == 2 && indexPath.row == 0){
        PlayerEditViewController * playerList = [[PlayerEditViewController alloc] initWithStyle:UITableViewStylePlain];
        playerList.teamId = _team.id;
        playerList.players = _playersOfTeam;
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
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    _image = [info valueForKey:UIImagePickerControllerEditedImage];
    UITableViewCell  *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView * profileImageView;
    profileImageView = (UIImageView *)[cell viewWithTag:1];

    profileImageView.image = _image;
    [self dismissModalViewControllerAnimated:YES];
    
    _dirty = YES;
}

#pragma alert delete
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (_team != nil) {
            [[TeamManager defaultManager] deleteTeam:_team];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
