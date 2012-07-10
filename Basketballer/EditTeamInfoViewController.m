//
//  EditTeamInfoViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EditTeamInfoViewController.h"
#import "define.h"

@implementation EditTeamInfoViewController

@synthesize rowsTitle = _rowsTitle;
@synthesize teamType = _teamType;

#pragma 私有函数
- (void)initRowsTitle {
    self.rowsTitle = [NSArray arrayWithObjects:@"选择头像",@"球队名称", nil]; 
}

-(NSString *)dataPath{
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
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

- (UIImage *)loadTeamImage {
    UIImage * image = nil;
    if(self.teamType == host) {
        image = [UIImage imageNamed:@"host_basketball"];
    }
    return image;
}

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
    [self initRowsTitle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if(indexPath.section == 0) {
        cell.imageView.image = [self loadTeamImage];
       
    }else {
        cell.textLabel.text = @"球队名称";
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        [self showActionSheet];
    }
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
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
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UIImage * image = [info valueForKey:UIImagePickerControllerEditedImage];
    UITableViewCell  *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSData *data;
    if (UIImageJPEGRepresentation(image, 1) == nil) {
        data = UIImagePNGRepresentation(image);

    } else {
        data = UIImageJPEGRepresentation(image, 1);

    }
    /*if (UIImagePNGRepresentation(image) == nil) {
        data = UIImageJPEGRepresentation(image, 1);
        
    } else {
        
        data = UIImagePNGRepresentation(image);
        
    }*/
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [[NSString stringWithString:[self dataPath]] stringByAppendingString:@"/image"];         //将图片存储到本地documents
    
    
    [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [fileManager createFileAtPath:[filePath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
    

    cell.imageView.image = [UIImage imageWithContentsOfFile:[filePath stringByAppendingString:@"/image.png"]];
    [self dismissModalViewControllerAnimated:YES];
}
@end
