//
//  GameSettingViewControllerViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    UIGameSettingViewStyleEdit = 0,
    UIGameSettingViewStyleShow = 1
}UIGameSettingViewStyle;

@interface GameSettingViewController : UITableViewController

@property (nonatomic, strong) NSString * gameMode;
@property (nonatomic) NSInteger viewStyle;

@end
