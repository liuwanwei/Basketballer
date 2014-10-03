//
//  NewPlayerViewController.m
//  Basketballer
//  新球员
//  Created by Liu Wanwei on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewPlayerViewController.h"
#import "PlayerManager.h"
#import "AppDelegate.h"
#import "Feature.h"
#import "ImageCell.h"
#import "TextEditorViewController.h"

@interface NewPlayerViewController (){
    UIBarButtonItem * _saveItem;
    BOOL _dirty;
}

@end

@implementation NewPlayerViewController

@synthesize numberLabel = _numberLabel;
@synthesize nameLabel = _nameLabel;
@synthesize number = _number;
@synthesize name = _name;
@synthesize player = _player;
@synthesize team = _team;
@synthesize parentWhoPresentedMe = _parentWhoPresentedMe;

- (void)dismiss{
    if (_parentWhoPresentedMe) {
        [_parentWhoPresentedMe dismissModalViewControllerAnimated:YES];
    }else if(self.navigationController != nil){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showInvalidNumberAlert{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:LocalString(@"InvalidNumber") message:LocalString(@"InputValidNumber")
        delegate:self
        cancelButtonTitle:LocalString(@"Ok") otherButtonTitles:nil, nil];
    [alert show];
}

- (void)save{
    NSString * numberText = self.playerNumber;
    if (nil == numberText || numberText.length == 0) {
        [self showInvalidNumberAlert];
        return;
    }
    
    NSInteger numberInteger = [numberText integerValue];
    if (numberInteger > 99) {
        [self showInvalidNumberAlert];
        return;
    }
    
    PlayerManager * pm = [PlayerManager defaultManager];                
    NSNumber * number = [NSNumber numberWithInteger:numberInteger];    
    Player * player = nil;
    if (self.player == nil) {
        player = [pm addPlayerForTeam:_team withNumber:number withName:self.name.text];
    }else{
        player = [pm updatePlayer:self.player withNumber:number andName:self.name.text];
    }

    if(nil == player){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:
                               LocalString(@"RepeatNumber")
                               message:LocalString(@"RepeatNumberMessage") 
                               delegate:self 
                               cancelButtonTitle:LocalString(@"Ok") 
                               otherButtonTitles:nil, nil];
        [alert show];
        [self.number becomeFirstResponder];
    }else{
        [self dismiss];
    }
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
    
    _dirty = false;
    
    _saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = _saveItem;    
    
    [[Feature defaultFeature] initNavleftBarItemWithController:self];        
    
    // 显示模式兼容iOS7的ExtendedLayout模式
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // 注册文本编辑完成事件处理函数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMessage:) name:kTextSavedMsg object:nil];
    
    // 隐藏多余的Cell分割线
    [[Feature defaultFeature] hideExtraCellLineForTableView:self.tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // 解除消息监听函数
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.player != nil) {
        self.number.text = [self.player.number stringValue];
        self.name.text = self.player.name;
        
        self.title = LocalString(@"PlayerInfo");
    }else{
        self.title = LocalString(@"NewPlayer");
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = nil;
    
    if (indexPath.row == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = LocalString(@"Name");
        cell.detailTextLabel.text = self.player.name;
    }else if(indexPath.row == 1){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = LocalString(@"Number");
        cell.detailTextLabel.text = [self.player.number stringValue];
    }else if(indexPath.row == 2){
        NSArray * nibs = [[NSBundle mainBundle] loadNibNamed:@"ImageCell" owner:self options:nil];
        cell = [nibs objectAtIndex:0];
        self.imageCell = (ImageCell *) cell;
        self.imageCell.profileImage.image = [UIImage imageNamed:@"player_profile"];
        self.imageCell.title.text = LocalString(@"Profile");
    }
    
    return cell;
}

static int sLastSelectedRow = -1;

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0 || indexPath.row == 1) {
            TextEditorViewController * vc = [[TextEditorViewController alloc] initWithNibName:@"TextEditorViewController" bundle:nil];
            
            // 设置文本界面标题
            if (indexPath.row == 0) {
                vc.title = LocalString(@"PlayerName");
                vc.keyboardType = UIKeyboardTypeNamePhonePad;
            }else{
                vc.title = LocalString(@"PlayerNumber");
                vc.keyboardType = UIKeyboardTypeNumberPad;
            }
            
            sLastSelectedRow = indexPath.row;
            
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 2){
            [self showActionSheet];
        }
    }
}

- (void)notificationMessage:(NSNotification *)notification{
    if ([notification.name isEqualToString:kTextSavedMsg]) {
        NSDictionary * userInfo = notification.userInfo;
        NSString * text = [userInfo objectForKey:kTextSavedMsg];
        if (text != nil) {
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sLastSelectedRow inSection:0]];
            if (sLastSelectedRow == 0) {
                NSLog(@"球员名字 %@", text);
                self.playerName = text;
            }else{
                NSLog(@"球衣号码 %@", text);
                self.playerNumber = text;
            }
            
            cell.detailTextLabel.text = text;
        }
    }
}

// 展示拍照或选照片菜单
- (void)showActionSheet {
    UIActionSheet * menu = [[UIActionSheet alloc]
                            initWithTitle:nil delegate:self
                            cancelButtonTitle:LocalString(@"Cancel")
                            destructiveButtonTitle:nil
                            otherButtonTitles:LocalString(@"FromLibrary"), LocalString(@"Snapshot"), nil];
    
    [menu showInView:[UIApplication sharedApplication].keyWindow];
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


#pragma mark UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    ImageCell  *cell = (ImageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.profileImage.image = image;
    self.playerImage = image;
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
