//
//  Feature.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IOS_7 ([[UIDevice currentDevice].systemVersion doubleValue] > 6.2)

#define MainColor            [UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90]

@interface Feature : NSObject

@property (strong, nonatomic, readonly) UIColor * weChatTableBgColor;
@property (strong, nonatomic, readonly) UIColor * navigationItemTintColor;

+ (Feature *)defaultFeature;

- (UIColor *)cellTextColor;
- (UIColor *)cellDetailTextColor;

- (void)hideExtraCellLineForTableView:(UITableView *)tableView;
@end
