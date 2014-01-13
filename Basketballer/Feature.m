//
//  Feature.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Feature.h"

static Feature * sDefaultFeatures;

@implementation Feature

@synthesize weChatTableBgColor = _weChatTableBgColor;
@synthesize navigationItemTintColor = _navigationItemTintColor;

- (UIColor *)weChatTableBgColor{
    if (nil == _weChatTableBgColor) {
        _weChatTableBgColor = [UIColor colorWithRed:0.882 green:0.874 blue:0.867 alpha:1.0];
    }
    return _weChatTableBgColor;
}

- (UIColor *)navigationItemTintColor{
    if (nil == _navigationItemTintColor) {
        _navigationItemTintColor = [UIColor colorWithRed:0.137 green:0.557 blue:0.867 alpha:1.0];
    }
    return _navigationItemTintColor;
}

+ (Feature *)defaultFeature{
    if (nil == sDefaultFeatures) {
        sDefaultFeatures = [[Feature alloc] init];
    }
    
    return sDefaultFeatures;
}

- (void)setNavigationBarBackgroundImage:(UINavigationBar *)navigationBar{
    UIImage * image = [UIImage imageNamed:@"ZhiHuNavigationBar"];
    [navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    navigationBar.tintColor = self.navigationItemTintColor;
}

- (void)initNavleftBarItemWithController:(UIViewController *)controller withAction:(SEL)action{
    if (action != nil) {
        controller.navigationItem.hidesBackButton = YES;
        UIButton *leftButton;
        UIBarButtonItem * item;
        
        leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [leftButton setImage:[UIImage imageNamed:@"backNavigationBar"] forState:UIControlStateNormal];
        [leftButton addTarget:controller action:action forControlEvents:UIControlEventTouchUpInside];
        item = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        controller.navigationItem.leftBarButtonItem = item;
    }else {
        controller.navigationItem.leftBarButtonItem = nil;
    }
}

- (UIColor *)cellTextColor {
    return [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
}

- (UIColor *)cellDetailTextColor; {
    return [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
}

@end
