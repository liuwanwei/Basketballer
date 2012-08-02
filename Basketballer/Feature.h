//
//  Feature.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Feature : NSObject

@property (strong, nonatomic, readonly) UIColor * weChatTableBgColor;

+ (Feature *)defaultFeature;

- (void)setNavigationBarBackgroundImage:(UINavigationBar *)navigationBar;

@end
