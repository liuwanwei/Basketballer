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
@synthesize delTeamBtn = _delTeamBtn;
@synthesize teamCell = _teamCell;

#pragma 私有函数
/*设置右导航按钮的enabled*/
- (void)setRightBarButtonItemEnable:(BOOL) enabled {
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

/*初始化导航按钮*/
- (void)initNavigationItem {
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    if (_operateMode == Insert) {
        [self setRightBarButtonItemEnable:NO];
    }else {
        [self setRightBarButtonItemEnable:YES];
    }
}

- (void)initRowsTitle {
    self.rowsTitle = [NSArray arrayWithObjects:@"球队名称",@"选择头像", nil]; 
}

- (void)showActionSheet {
    UIActionSheet * menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"用户相册",@"拍照", nil];
    [menu showInView:self.view];
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

- (void)initDelTeamBtn {
    if (_operateMode == Insert || _team == nil) {
        [self.delTeamBtn setHidden:YES];
    }else if(_team != nil){
        if ([_team.id intValue] == 0 || [_team.id intValue] == 1) {
            [self.delTeamBtn setHidden:YES];
        }
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
    [self initDelTeamBtn];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)delTeam:(id)sender {
    if (_team != nil) {
        [[TeamManager defaultManager] deleteTeam:_team];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView * profileImageView;
    if (nil == cell) {
        [[NSBundle mainBundle] loadNibNamed:@"TeamRecordCell" owner:self options:nil];
        cell = _teamCell;
        self.teamCell = nil;
        
        // 图片圆角化。
        profileImageView = (UIImageView *)[cell viewWithTag:1];
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = 5.0f;
        profileImageView.frame = CGRectMake(2.0, 1.0, 42.0, 42.0);

    }
    TeamManager * teamManager = [TeamManager defaultManager]; 
    profileImageView = (UIImageView *)[cell viewWithTag:1];
    UILabel * label = (UILabel *)[cell viewWithTag:2]; 
    if(indexPath.section == 1) {
        UILabel * label = (UILabel *)[cell viewWithTag:2]; 
        profileImageView.image = [teamManager imageForTeam:self.team];  
        _image = [teamManager imageForTeam:self.team]; 
        label.text = @"";
    }else {
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

@end
