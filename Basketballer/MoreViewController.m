//
//  MoreViewController.m
//  Basketballer
//
//  Created by maoyu on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MoreViewController.h"
#import "Feature.h"
//#import "UMFeedback.h"
#import "AppDelegate.h"
#import "AboutUsViewController.h"

#define kEMail          @"liuwanwei@gmail.com"
#define kAppKeyOfApple  559738184

@interface MoreViewController () {
    NSArray * _rowsInSection;
    NSArray * _contentInSecondSection;
}
@end

@implementation MoreViewController

#pragma 私有函数
- (void)initRowsInSection {
    NSArray * rowsInFirstSection = [NSArray arrayWithObjects:
                                    LocalString(@"WriteAReview"),
                                    LocalString(@"AboutUs"), 
                                    nil];
    NSArray * rowsInSecondSection = [NSArray arrayWithObjects:
                                     LocalString(@"Version"), 
                                     nil];
    _rowsInSection = [NSArray arrayWithObjects:rowsInFirstSection, rowsInSecondSection, nil];
    
    // 读取App版本并显示
    NSDictionary * info =[[NSBundle mainBundle] infoDictionary];
    NSString * version = info[@"CFBundleShortVersionString"];
    NSString * build = info[@"CFBundleVersion"];
    NSString * versionBuild = [NSString stringWithFormat:@"v%@(%@)", version, build];
    _contentInSecondSection = [NSArray arrayWithObjects:versionBuild, kEMail, nil];
}

- (void)initTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
//    self.tableView.backgroundColor = [UIColor whiteColor];
//    self.tableView.rowHeight = 48.0f;
}

#pragma 事件函数
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initRowsInSection];
    [self initTableView];
    
    self.title = NSLocalizedString(@"Others", nil);
    
    if (IOS_7) {
        self.tableView.separatorInset =  UIEdgeInsetsZero;
    }
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
    return _rowsInSection.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_rowsInSection objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (IOS_7) {
            self.tableView.separatorInset =  UIEdgeInsetsZero;
        }
    }
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.detailTextLabel.text = [_contentInSecondSection objectAtIndex:indexPath.row];
        cell.detailTextLabel.textColor = [[Feature defaultFeature] cellDetailTextColor]; 
    }
    
    cell.textLabel.text = [[_rowsInSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [[Feature defaultFeature] cellTextColor];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSString *str = [NSString stringWithFormat: 
                             @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", 
                             kAppKeyOfApple];
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]] == YES) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]]; 
            }
            
        }else {
            AboutUsViewController * controller = [[AboutUsViewController alloc] initWithStyle:UITableViewStyleGrouped];
//            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

@end
