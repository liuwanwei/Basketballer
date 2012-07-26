//
//  OperateGameViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"
#import "MatchManager.h"
#import "WEPopoverController.h"
#import "WEPopoverContentViewController.h"

@interface OperateGameViewController : UIView <FoulActionDelegate,UIActionSheetDelegate>

@property (nonatomic) NSInteger teamType;
@property (nonatomic, weak) Team * team;
@property (nonatomic, strong) NSDate * gameStartTime;
@property (nonatomic, weak) Match * match;
@property (nonatomic) NSInteger period;
@property (nonatomic, weak) IBOutlet UIImageView * teamImageView;
@property (nonatomic, weak) IBOutlet UILabel * teamNameLabel;
@property (nonatomic, weak) IBOutlet UIButton * foulButton;
@property (nonatomic, weak) IBOutlet UIButton * timeoutButton;
@property (nonatomic, weak) IBOutlet UIView * buttonRegionView;

- (void)addScore:(NSInteger) score;
- (void)initTeam;
- (void)initTimeoutAndFoulView;
- (void)refreshMatchData;

- (IBAction)showPopoer:(id)sender;
- (IBAction)addTimeOver:(id)sender;
- (IBAction)addFoul:(id)sender;

- (void)setButtonEnabled:(BOOL) enabled;

@end
