//
//  Feature.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IOS_7 ([[UIDevice currentDevice].systemVersion doubleValue] > 6.2)

@interface Feature : NSObject

@property (strong, nonatomic, readonly) UIColor * weChatTableBgColor;
@property (strong, nonatomic, readonly) UIColor * navigationItemTintColor;

+ (Feature *)defaultFeature;

- (void)customNavigationBar:(UINavigationBar *)navigationBar;
- (void)initNavleftBarItemWithController:(UIViewController *)controller;

- (UIColor *)cellTextColor;
- (UIColor *)cellDetailTextColor;

- (void)hideExtraCellLineForTableView:(UITableView *)tableView;
@end
