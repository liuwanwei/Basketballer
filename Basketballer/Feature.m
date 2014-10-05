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

// 设置导航栏背景和文字颜色（知乎App2012年版的亮蓝色背景）
- (void)customNavigationBar:(UINavigationBar *)navigationBar{
    return;//TODO
//    UIImage * image = [UIImage imageNamed:@"ZhiHuNavigationBar"];
//    [navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
//    navigationBar.tintColor = [UIColor colorWithRed:0.137 green:0.557 blue:0.867 alpha:1.0];;
}

// 自定义导航栏返回按钮
- (void)initNavleftBarItemWithController:(UIViewController *)controller {
    return;//TODO
//        controller.navigationItem.hidesBackButton = YES;
//        UIButton *leftButton;
//        UIBarButtonItem * item;
//        
//        leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//        [leftButton setImage:[UIImage imageNamed:@"backNavigationBar"] forState:UIControlStateNormal];
//        [leftButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//        
//        objc_setAssociatedObject(leftButton, &UITopViewControllerKey, controller, OBJC_ASSOCIATION_ASSIGN);
//        
//        item = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//        
//        controller.navigationItem.leftBarButtonItem = item;
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
