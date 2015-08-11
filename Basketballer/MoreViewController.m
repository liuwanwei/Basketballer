//
//  MoreViewController.m
//  Basketballer
//
//  Created by maoyu on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MoreViewController.h"
#import "Feature.h"
#import "AppDelegate.h"
#import "AboutUsViewController.h"
#import "HowToViewController.h"

#define kEMail          @"liuwanwei@gmail.com"
#define kAppKeyOfApple  559738184

NSString * const kHowto = @"HowTo";
NSString * const kRateMe = @"RateMe";
NSString * const kAboutUs = @"AboutUs";
NSString * const kAppRec = @"AppRec";
NSString * const kVesrion = @"Version";

@implementation MoreViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = LocalString(@"Others");
    
    [self initRowsInSection];
}

- (void)initRowsInSection {
    
    XLFormDescriptor * form = [XLFormDescriptor formDescriptor];
    self.form = form;

    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    // 新的section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 评分
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRateMe rowType:XLFormRowDescriptorTypeButton title:LocalString(@"WriteAReview")];
    [row.cellConfig setObject:@(NSTextAlignmentLeft) forKey:@"textLabel.textAlignment"];
    [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
    row.action.formBlock = ^(XLFormRowDescriptor * sender){
        NSString * blabla = @"非常感谢您给这个没有任何盈利点的 App 评分，但要是因为误操作点了这里，请点“取消”";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"请给五星好评鼓励开发者"
                                                         message:blabla
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"确定", nil];
        [alert show];
        [self deselectFormRow:sender];
    };
    [section addFormRow:row];
    
    // 关于我们
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAboutUs rowType:XLFormRowDescriptorTypeButton title:LocalString(@"AboutUs")];
    row.action.viewControllerStoryboardId = @"AboutUsTableView";
    [section addFormRow:row];
    
    // 应用推荐
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAppRec rowType:XLFormRowDescriptorTypeButton title:@"我们的其他 Apps"];
    row.action.viewControllerStoryboardId = @"AppRecommandation";
    [section addFormRow:row];
    
    // 新的section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVesrion rowType:XLFormRowDescriptorTypeInfo title:LocalString(@"Version")];
    row.value = [self appVersion];
    [section addFormRow:row];
    
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self jumpToAppStore];
    }
}

- (NSString *)appVersion{
    // 读取App版本
    NSDictionary * info =[[NSBundle mainBundle] infoDictionary];
    NSString * version = info[@"CFBundleShortVersionString"];
    NSString * build = info[@"CFBundleVersion"];
    NSString * versionBuild = [NSString stringWithFormat:@"v%@(%@)", version, build];
    
    return versionBuild;
}

- (void)jumpToAppStore{
    NSString *str = [NSString stringWithFormat:
                     @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",
                     kAppKeyOfApple];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]] == YES) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

- (UIStoryboard *)storyboardForRow:(XLFormRowDescriptor *)formRow{
    return [UIStoryboard storyboardWithName:@"Others" bundle:nil];
}


@end
