//
//  GameSettingViewControllerViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    GameSettingViewStyleEdit = 0,
    GameSettingViewStyleShow = 1
}GameSettingViewStyle;

@interface GameSettingViewController : UITableViewController

@property (nonatomic, strong) NSString * gameMode;
@property (nonatomic) NSInteger viewStyle;

@property (nonatomic, weak) NSArray * settingsArray;
@property (nonatomic, weak) NSArray * settingsKeyArray;

@end
