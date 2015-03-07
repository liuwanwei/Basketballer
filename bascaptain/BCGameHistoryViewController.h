//
//  FirstViewController.h
//  bascaptain
//
//  Created by sungeo on 15/3/6.
//
//

#import <UIKit/UIKit.h>
#import "GameHistoryViewController.h"

@interface BCGameHistoryViewController : UITableViewController

@property (nonatomic, strong) NSArray * matches;
@property (nonatomic, strong) NSDictionary * history;
@property (nonatomic, strong) NSArray * historyGroupKeys;

@end

