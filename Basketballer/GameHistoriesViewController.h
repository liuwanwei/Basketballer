//
//  GameHistoriesViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UIHomeTeamProfileTag    = 1,
    UIHomeTeamNameTag       = 2,
    UIHomeTeamPointsTag     = 3,
    UIMatchDateTag          = 4,
    UIGuestTeamPointsTag    = 5,        
    UIGuestTeamProfileTag   = 6,
    UIGuestTeamNameTag      = 7    
        
} TagsInMatchRecordCell;

@interface GameHistoriesViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UITableViewCell * tvCell;

@end
