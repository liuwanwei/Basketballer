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

- (UIColor *)weChatTableBgColor{
    if (nil == _weChatTableBgColor) {
        _weChatTableBgColor = [UIColor colorWithRed:0.882 green:0.874 blue:0.867 alpha:1.0];
    }
    return _weChatTableBgColor;
}

+ (Feature *)defaultFeature{
    if (nil == sDefaultFeatures) {
        sDefaultFeatures = [[Feature alloc] init];
    }
    
    return sDefaultFeatures;
}


@end
