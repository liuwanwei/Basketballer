//
//  PointDetailsViewController.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Match.h"

@interface PointDetailsViewController : UITableViewController

@property (nonatomic, strong) NSArray * actions;
@property (nonatomic, strong) Match * match;

@end
