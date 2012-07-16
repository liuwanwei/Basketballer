//
//  ActionRecordViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Match;

typedef enum {
    UITeamProfileTag    = 1,
    UITeamNameTag       = 2,
    UITeamActionTag     = 3,
    UIPeroidTimeTag     = 4,
} TagsInActionRecordCell;

@interface ActionRecordViewController : UITableViewController

@property (nonatomic, weak) Match * match;
@property (nonatomic, weak) IBOutlet UITableViewCell * tvCell;

@end
