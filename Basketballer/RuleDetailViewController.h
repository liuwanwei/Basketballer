//
//  RuleDetailViewController.h
//  Basketballer
//  
//  Created by Liu Wanwei on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  BaseRule;

@interface RuleDetailViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic) BOOL editable;
@property (nonatomic, weak) BaseRule * rule;

@end
