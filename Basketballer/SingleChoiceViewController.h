//
//  SingleChoiceViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleChoiceViewController : UITableViewController

@property (nonatomic, strong) NSString * parameterKey;        // 选项名称，用于保存选项。
@property (nonatomic, strong) NSString * unitString;          // 选项单位，用于显示。
@property (nonatomic, strong) NSString * currentChoice;       // 当前选项，用于显示。
@property (nonatomic, strong) NSArray * choices;              // 所有选项，用于显示。

@end
