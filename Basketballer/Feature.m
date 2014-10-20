//
//  Feature.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Feature.h"
#import <objc/runtime.h>

static Feature * sDefaultFeatures;
static char UITopViewControllerKey;

@implementation Feature

+ (Feature *)defaultFeature{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == sDefaultFeatures) {
            sDefaultFeatures = [[Feature alloc] init];
        }
    });
    
    return sDefaultFeatures;
}


// 导航栏左侧按钮消息通用处理函数
- (void)back:(id)sender {
    UIViewController * topVC = (UIViewController *)objc_getAssociatedObject(sender, &UITopViewControllerKey);
    if (nil != topVC) {
        topVC.hidesBottomBarWhenPushed = NO;
        [topVC.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setNavigationBarBackgroundImage:(UINavigationBar *)navigationBar{
    UIImage * image = [UIImage imageNamed:@"ZhiHuNavigationBar"];
    [navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        navigationBar.tintColor = [UIColor whiteColor];
    }else {
        navigationBar.tintColor = self.navigationItemTintColor;
    }
}

- (UIColor *)cellTextColor {
    return [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
}

- (UIColor *)cellDetailTextColor; {
    return [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
}

// 隐藏空白的cell分割线
- (void)hideExtraCellLineForTableView:(UITableView *)tableView{
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

@end
