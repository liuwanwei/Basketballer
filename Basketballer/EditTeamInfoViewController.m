//
//  EditTeamInfoViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EditTeamInfoViewController.h"
#import "define.h"
#import "TeamManager.h"
#import "EditTeamNameViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface EditTeamInfoViewController() {
    UIImage * _image;
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

/*设置右导航按钮的enabled*/
- (void)setRightBarButtonItemEnable:(BOOL) enabled {
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

- (void)delTeam{    
    [self showAlertView:@"删除球队信息?删除后信息不可恢复。"];
}

/*初始化导航按钮*/
- (void)initNavigationItem {
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    if (_operateMode == Update && [_team.id intValue] != 0 && [_team.id intValue] != 1) {
        UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStyleBordered target:self action:@selector(delTeam)];
        self.navigationItem.rightBarButtonItem = rightItem;
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
    if(teamName == nil || teamName.length == 0) {
        [self setRightBarButtonItemEnable:NO];
        cell.textLabel.text = @"";
    }else {
        [self setRightBarButtonItemEnable:YES];
        cell.textLabel.text = teamName;
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
    self.title = @"设置球队";
    [self initNavigationItem];
    [self initRowsTitle];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)save:(id) send {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell  *cell = [self.tableView cellForRowAtIndexPath:indexPath];;
    NSString * teamName = cell.textLabel.text;
    if (teamName.length != 0) {
        TeamManager * teamManager = [TeamManager defaultManager];
        if(self.operateMode == Insert) {
            [teamManager newTeam:teamName withImage:_image];
        }else {
            [teamManager modifyTeam:self.team withNewName:teamName];
            [teamManager modifyTeam:self.team withNewImage:_image];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.rowsTitle objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
    if (indexPat.section == 0) {
         return 44;
    }else {
         return 70;
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView * profileImageView;
    UILabel * label;
    if (nil == cell) {
        [[NSBundle mainBundle] loadNibNamed:@"TeamRecordCell" owner:self options:nil];
        cell = _teamCell;
        self.teamCell = nil;
        
        // 图片圆角化。
        profileImageView = (UIImageView *)[cell viewWithTag:1];
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = 5.0f;
        profileImageView.frame = CGRectMake(5.0, 5.0, 60.0, 60.0);
    }
    TeamManager * teamManager = [TeamManager defaultManager]; 
    profileImageView = (UIImageView *)[cell viewWithTag:1];
    label = (UILabel *)[cell viewWithTag:2]; 
    if(indexPath.section == 1) {
        profileImageView.image = [teamManager imageForTeam:self.team];  
        _image = [teamManager imageForTeam:self.team]; 
        label.text = @"";
    }else {
        profileImageView.image = nil;
        label.text = @"";
        cell.textLabel.text = self.team.name;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1) {
        [self showActionSheet];
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    }else {
        EditTeamNameViewController * editTeamNameViewController = [[EditTeamNameViewController alloc] initWithNibName:@"EditTeamNameViewController" bundle:nil];
        editTeamNameViewController.teamName = self.team.name;
        editTeamNameViewController.parentController = self;
        [self.navigationController pushViewController:editTeamNameViewController animated:YES];
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
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    _image = [info valueForKey:UIImagePickerControllerEditedImage];
    UITableViewCell  *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView * profileImageView;
    profileImageView = (UIImageView *)[cell viewWithTag:1];

    profileImageView.image = _image;
    [self dismissModalViewControllerAnimated:YES];
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
