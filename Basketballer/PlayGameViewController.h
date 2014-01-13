//
//  PlayGameViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"
#import "LocationManager.h"
#import <MapKit/MapKit.h>
#import "MatchUnderWay.h"
@class  OperateGameView;
@class  TeamStatistics;

@interface PlayGameViewController : UIViewController <UIAlertViewDelegate,UIActionSheetDelegate,FoulActionDelegate,LocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UIView * backgroundView;
@property (nonatomic, weak) IBOutlet UIView * promptView;
@property (nonatomic, weak) IBOutlet UILabel * gameTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel * gamePeroidLabel;
@property (nonatomic, weak) IBOutlet UILabel * gameHostScoreLable;
@property (nonatomic, weak) IBOutlet UILabel * gameGuestScoreLable;
@property (nonatomic, weak) IBOutlet UIButton * gamePeroidButton;
@property (nonatomic, weak) OperateGameView * operateGameView1;
@property (nonatomic, weak) OperateGameView * operateGameView2;
@property (nonatomic, weak) NSTimer * timeCountDownTimer;
@property (nonatomic, weak) Team * hostTeam;
@property (nonatomic, weak) Team * guestTeam;
@property (nonatomic, weak) TeamStatistics * selectedStatistics;

@property (nonatomic) BOOL testSwitch;
@property (nonatomic) BOOL gameStart;

- (IBAction)startGame:(id)sender;
- (void)stopGame:(NSInteger)mode withWinTeam:(NSNumber *)teamId;
- (IBAction)showActionRecordController:(id)sender;
- (IBAction)showPlaySoundController:(id)sender;
- (IBAction)changePeriod:(UIButton *)sender;

- (void)pauseCountdownTime;

- (void)showNewActionViewForTeam:(Team *)team withTeamStatistics:(TeamStatistics *)statistics;
- (void)showPlayerFoulStatisticViewControllerForTeam:(Team *)team;
- (void)initWithHostTeam:(Team *)hostTeam andGuestTeam:(Team *)guestTeam;
- (void)showPlaySoundView;

- (void)dismissView;

@end
