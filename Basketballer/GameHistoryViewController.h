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
    UIHomeTeamPointsTag     = 2,    
    UIHomeTeamNameTag       = 3,
    UIMatchDateTag          = 4,
    UIGuestTeamPointsTag    = 5,
    UIGuestTeamNameTag      = 6,    
    UIMatchTimeTag          = 7,
    UIGuestTeamProfileTag   = 8,
        
} TagsInMatchRecordCell;

typedef enum {
    HistoryTypeTeams = 0,
    HistoryTypeTeam = 1,
}HistoryType;

@interface GameHistoryViewController : UITableViewController

//@property (nonatomic, weak) IBOutlet UITableViewCell * tvCell;

@property (nonatomic, strong) NSArray * matches;
@property (nonatomic, strong) NSDictionary * history;

@property (nonatomic) HistoryType historyType;

@end
