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
#import "MatchUnderWay.h"
#import "TeamStatistics.h"
//#import "WEPopoverController.h"
//#import "WEPopoverContentViewController.h"

@interface OperateGameView : UIView <UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic, weak) Team * team;
@property (nonatomic, weak) TeamStatistics * statistics;

@property (nonatomic, weak) IBOutlet UIButton * teamImageButton;
@property (nonatomic, weak) IBOutlet UIImageView * teamImageView;
@property (nonatomic, weak) IBOutlet UILabel * teamNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * pointsPromptLabel;
@property (nonatomic, weak) IBOutlet UILabel * foulsLabel;
@property (nonatomic, weak) IBOutlet UILabel * foulsPromptLabel;
@property (nonatomic ,weak) IBOutlet UILabel * timeoutLabel;
@property (nonatomic, weak) IBOutlet UILabel * timeoutPromptLabel;
@property (nonatomic, weak) IBOutlet UIButton * backgroundButton;
@property (nonatomic, weak) IBOutlet UIButton * foulButton;

- (void)initContentWithTeam:(Team *)team;
- (void)initTimeoutAndFoulView;
- (void)hideFoulsAndTimeoutView;
- (void)refreshMatchData;
- (void)setButtonEnabled:(BOOL) enabled;

- (IBAction)teamImageTouched:(id)sender;
- (IBAction)foulButtonTouched:(id)sender;
- (IBAction)buttonDown:(UIButton *)sender;
- (IBAction)buttonTouchOutside:(UIButton *)sender;

@end
