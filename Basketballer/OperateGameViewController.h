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

#define kTimeoutMessage @"kTimeout"
#define kAddScoreMessage @"kAddScore"

typedef enum{
    TeamTypeHost = 0,
    TeamTypeGuest = 1
}TeamType;

@interface OperateGameViewController : UIView <FoulActionDelegate,UIActionSheetDelegate>

@property (nonatomic) NSInteger teamType;
@property (nonatomic, weak) Team * team;
@property (nonatomic, strong) NSDate * gameStartTime;
@property (nonatomic, weak) Match * match;
//@property (nonatomic) NSInteger period;
@property (nonatomic, weak) NSString * matchMode;
@property (nonatomic, weak) IBOutlet UIImageView * teamImageView;
@property (nonatomic, weak) IBOutlet UILabel * teamNameLabel;
@property (nonatomic, weak) IBOutlet UIButton * pointButton;
@property (nonatomic, weak) IBOutlet UIButton * foulButton;
@property (nonatomic, weak) IBOutlet UIButton * timeoutButton;
@property (nonatomic, weak) IBOutlet UILabel * pointsLabel;
@property (nonatomic, weak) IBOutlet UILabel * pointsPromptLabel;
@property (nonatomic, weak) IBOutlet UILabel * foulsLabel;
@property (nonatomic, weak) IBOutlet UILabel * foulsPromptLabel;
@property (nonatomic ,weak) IBOutlet UILabel * timeoutLabel;
@property (nonatomic, weak) IBOutlet UILabel * timeoutPromptLabel;

- (void)addScore:(NSInteger) score;
- (void)initContentWithTeam:(Team *)team 
               withTeamType:(TeamType)teamType 
              withMatchMode:(NSString *)matchMode;
- (void)initTimeoutAndFoulView;
- (void)refreshMatchData;
- (void)setButtonEnabled:(BOOL) enabled;

- (IBAction)showPopoer:(UIButton *)sender;
- (IBAction)addTimeOver:(UIButton *)sender;
- (IBAction)addFoul:(UIButton *)sender;
- (IBAction)buttonDown:(UIButton *)sender;
- (IBAction)buttonTouchOutside:(UIButton *)sender;

@end
