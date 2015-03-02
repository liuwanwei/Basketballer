//
//  NewPlayerViewController.m
//  Basketballer
//  新球员
//  Created by Liu Wanwei on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewPlayerViewController.h"
#import "PlayerManager.h"
#import "ImageManager.h"
#import "AppDelegate.h"
#import "Feature.h"
#import "ImageCell.h"
#import "TextEditorFormViewController.h"

@interface NewPlayerViewController (){
    UIBarButtonItem * _saveItem;
    NSIndexPath * _lastSelectedIndexPath;
    BOOL _dirty;
}

@end

@implementation NewPlayerViewController

@synthesize model = _model;
@synthesize team = _team;

- (void)showInvalidNumberAlert{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:LocalString(@"InvalidNumber") message:LocalString(@"InputValidNumber")
        delegate:self
        cancelButtonTitle:LocalString(@"Ok") otherButtonTitles:nil, nil];
    [alert show];
}

- (void)savePlayer{
    NSString * numberText = [self.playerNumber stringValue];
    if (nil == numberText || numberText.length == 0) {
        return;
    }
    
    NSInteger numberInteger = [numberText integerValue];
    if (numberInteger > 99) {
        [self showInvalidNumberAlert];
        return;
    }
    
    if (nil == self.playerName || self.playerName.length == 0) {
        return;
    }
    
    PlayerManager * pm = [PlayerManager defaultManager];
    Player * player = nil;
    if (self.model == nil) {
        player = [pm prepareForNewPlayer];
    }else{
        player = self.model;
    }
    
    player.team = _team;
    player.name = self.playerName;
    player.number = self.playerNumber;
    player.profileURL = [[ImageManager defaultInstance] saveImage:self.playerImage withProfileType:kProfileTypePlayer withObjectId:player.id];
    
    [pm commitPlayer:player];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerChangedNotification object:nil];

    [self.navigationController popViewControllerAnimated:YES];
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
    
    _saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePlayer)];
    self.navigationItem.rightBarButtonItem = _saveItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (self.model != nil) {
        self.playerName = self.model.name;
        self.playerNumber = self.model.number;
        self.playerImage = [[ImageManager defaultInstance] imageForName:self.model.profileURL];
    }
    
    // 隐藏多余的Cell分割线
    [[Feature defaultFeature] hideExtraCellLineForTableView:self.tableView];
    
    // 显示模式兼容iOS7的ExtendedLayout模式
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // 注册文本编辑完成事件处理函数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMessage:) name:kTextSavedMsg object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // 解除消息监听函数
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        cell.detailTextLabel.text = self.playerName;
    }else if(indexPath.row == 1){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = LocalString(@"Number");
        cell.detailTextLabel.text = [self.playerNumber stringValue];
    }else if(indexPath.row == 2){
        NSArray * nibs = [[NSBundle mainBundle] loadNibNamed:@"ImageCell" owner:self options:nil];
        cell = [nibs objectAtIndex:0];
        self.imageCell = (ImageCell *) cell;
        self.imageCell.title.text = LocalString(@"Profile");
        if (self.playerImage == nil) {
            self.playerImage = [UIImage imageNamed:@"player_profile"];
        }
        
        self.imageCell.profileImage.image = self.playerImage;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

#define kEditPlayerName     @"EditPlayerName"
#define kEditPlayerNumber   @"EditPlayerNumber"

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0 || indexPath.row == 1) {
            TextEditorFormViewController * vc = nil;
            // 设置文本界面标题
            if (indexPath.row == 0) {
                vc = [[TextEditorFormViewController alloc] initWithTitle:LocalString(@"PlayerName")];
                vc.keyboardType = UIKeyboardTypeNamePhonePad;
                vc.textToEdit = self.playerName;
                vc.textKeyword = kEditPlayerName;
            }else{
                vc = [[TextEditorFormViewController alloc] initWithTitle:LocalString(@"PlayerNumber")];
                vc.keyboardType = UIKeyboardTypeNumberPad;
                vc.textToEdit = [self.playerNumber stringValue];
                vc.textKeyword = kEditPlayerNumber;
            }
            
            _lastSelectedIndexPath = indexPath;
            
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 2){
            [self showActionSheet];
        }
    }
}

- (void)refreshRighBarButtonItem{
    if ((self.playerName != nil && self.playerName.length != 0) &&
        self.playerNumber != nil &&
        self.playerImage != nil) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)notificationMessage:(NSNotification *)notification{
    if ([notification.name isEqualToString:kTextSavedMsg]) {
        NSDictionary * userInfo = notification.userInfo;
        NSString * text = nil;
        if ((text = [userInfo objectForKey:kEditPlayerName]) != nil) {
            NSLog(@"球员名字 %@", text);
            self.playerName = text;
        }else if((text = [userInfo objectForKey:kEditPlayerNumber]) != nil){
            NSLog(@"球衣号码 %@", text);
            self.playerNumber = [NSNumber numberWithInteger:[text integerValue]];
        }else{
            text = [userInfo objectForKey:kTextSavedMsg];
        }
    
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:_lastSelectedIndexPath];
        cell.detailTextLabel.text = text;
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_lastSelectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self refreshRighBarButtonItem];
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
//        [self presentModalViewController:imagePickerController animated:YES];
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)showCamera {
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.allowsEditing = YES;
//        [self presentModalViewController:imagePickerController animated:YES];
        [self presentViewController:imagePickerController animated:YES completion:nil];
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
    
    [self refreshRighBarButtonItem];
    
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
