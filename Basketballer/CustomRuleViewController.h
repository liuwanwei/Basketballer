//
//  CustomRuleViewController.h
//  Basketballer
//
//  Created by sungeo on 14-9-30.
//
//

#import <UIKit/UIKit.h>

#define kRuleChangedNotification        @"RuleChangedNotification"

@class FibaCustomRule;

@interface CustomRuleViewController : UITableViewController

@property (nonatomic, strong) FibaCustomRule * rule;

@end
