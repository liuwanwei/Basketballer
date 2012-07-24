//
//  OperateGameViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OperateGameViewController.h"
#import "EditTeamInfoViewController.h"
#import "AppDelegate.h"
#import "define.h"
#import "TeamManager.h"
#import "MatchManager.h"
#import "GameSetting.h"
#import <QuartzCore/QuartzCore.h>

@interface OperateGameViewController() {
    WEPopoverController * _popoverController;
    WEPopoverContentViewController * _popoverContentController;
}
@end

@implementation OperateGameViewController

@synthesize team = _team;
@synthesize teamType = _teamType;
@synthesize gameStartTime = _gameStartTime;
@synthesize teamImageView = _teamImageView;
@synthesize match = _match;
@synthesize period = _period;
@synthesize teamNameLabel = _teamNameLabel;
@synthesize foulButton = _foulButton;
@synthesize timeoutButton = _timeoutButton;
@synthesize buttonRegionView = _buttonRegionView;

#pragma 私有函数
/*计算时间差*/
- (NSInteger)computeTimeDifference {
    NSDate * nowDate = [NSDate date];
    NSTimeInterval timeDifference = [nowDate timeIntervalSinceDate:self.gameStartTime]; 
    return timeDifference;
}

- (void)showAlertView:(NSString *)message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil , nil];
    [alertView show];
}

#pragma 类成员函数
/*
 设置button可用状态
 比赛开始前、暂停中button不可用
 比赛进行中可用
 注：设置球队按钮除外
 */
- (void)setButtonEnabled:(BOOL) enabled {
    NSInteger size = self.buttonRegionView.subviews.count;
    for (NSInteger index = 0; index < size; index++) {
        if([[self.buttonRegionView.subviews objectAtIndex:index] isKindOfClass:[UIButton class]]) {
            [[self.buttonRegionView.subviews objectAtIndex:index] setEnabled:enabled];
        }
    }
}

/*初始化球队信息*/
- (void)initTeam {
    if(_team != nil) {
        self.teamImageView.layer.masksToBounds = YES;
        self.teamImageView.layer.cornerRadius = 5.0f;
        self.teamImageView.image = [[TeamManager defaultManager] imageForTeam:_team];
        self.teamNameLabel.text = _team.name;
    }
}

- (void)initTimeoutAndFoulView {
    self.timeoutButton.titleLabel.text = @"0";
    [self.timeoutButton setBackgroundImage:[UIImage imageNamed:@"badgeValueBlue@2x"] forState:UIControlStateNormal];
    self.foulButton.titleLabel.text = @"0";
    [self.foulButton setBackgroundImage:[UIImage imageNamed:@"badgeValueBlue@2x"] forState:UIControlStateNormal];
}

- (void)refreshMatchData {
    ActionManager * actionManager = [ActionManager defaultManager];
    if(_teamType == host) {
        self.timeoutButton.titleLabel.text = [NSString stringWithFormat:@"%d",actionManager.homeTeamTimeouts];
        self.foulButton.titleLabel.text = [NSString stringWithFormat:@"%d",actionManager.homeTeamFouls];
    }else {
        self.timeoutButton.titleLabel.text = [NSString stringWithFormat:@"%d",actionManager.guestTeamTimeouts];
        self.foulButton.titleLabel.text = [NSString stringWithFormat:@"%d",actionManager.guestTeamFouls];
    }
    
}

#pragma 事件函数
- (id)initWithFrame:(CGRect)frame {
    NSArray * nib =[[NSBundle mainBundle] loadNibNamed:@"OperateGameViewController" owner:self options:nil];
    self = [nib objectAtIndex:0];
    self.frame = frame;
    ActionManager * actionManager = [ActionManager defaultManager];
    actionManager.delegate = self;
    return self;
}

- (IBAction)showPopoer:(UIButton *)sender {
    if(_popoverController == nil && _popoverContentController == nil) {
        _popoverContentController = [[WEPopoverContentViewController alloc] initWithStyle:UITableViewStylePlain];
        _popoverController = [[WEPopoverController alloc] initWithContentViewController:_popoverContentController];
        
        _popoverContentController.wePopoverController = _popoverController;
        _popoverContentController.opereteGameViewController = self;
    }
    
    [_popoverController presentPopoverFromRect:sender.frame 
                                            inView:sender
                          permittedArrowDirections:UIPopoverArrowDirectionDown
                                          animated:YES];

}

- (void)addScore:(NSInteger) score {
    ActionManager * actionManager = [ActionManager defaultManager];
    NSInteger time = [self computeTimeDifference];
    if(_teamType == host) {
        [actionManager actionForHomeTeamInMatch:_match withType:score atTime:time inPeriod:_period];
    }else {
        [actionManager actionForGuestTeamInMatch:_match withType:score atTime:time inPeriod:_period];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddScoreMessage object:nil];
}

- (IBAction)addTimeOver:(id)sender {
    ActionManager * actionManager = [ActionManager defaultManager];
    NSInteger time = [self computeTimeDifference];
    BOOL result;
    if(_teamType == host) {
        result = [actionManager actionForHomeTeamInMatch:_match withType:ActionTypeTimeout atTime:time inPeriod:_period];
    }else {
        result = [actionManager actionForGuestTeamInMatch:_match withType:ActionTypeTimeout atTime:time inPeriod:_period];
    }
    if (result) {
        NSInteger timeoutSize;
        NSInteger timeoutLimit;
        if (_match.mode == kGameModeTwoHalf) {
            timeoutLimit = [[GameSetting defaultSetting].timeoutsOverHalfLimit intValue];
        }else {
            timeoutLimit = [[GameSetting defaultSetting].timeoutsOverQuarterLimit intValue];
        }
        if (_teamType == host) {
            timeoutSize = actionManager.homeTeamTimeouts;
            
        }else {
            timeoutSize = actionManager.guestTeamTimeouts;
        }
        if (timeoutLimit == timeoutSize) {
            [self.timeoutButton setBackgroundImage:[UIImage imageNamed:@"badgeValueRed"] forState:UIControlStateNormal];
        }
        self.timeoutButton.titleLabel.text = [NSString stringWithFormat:@"%d",timeoutSize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTimeoutMessage object:nil];
    }else {
        [self showAlertView:@"本节暂停已使用完"];
    }
}

- (IBAction)addFoul:(id)sender {
    ActionManager * actionManager = [ActionManager defaultManager];
    NSInteger time = [self computeTimeDifference];
    NSInteger foulSize;
    NSInteger foulLimit;
    if (_match.mode == kGameModeTwoHalf) {
        foulLimit = [[GameSetting defaultSetting].foulsOverHalfLimit intValue];
    }else {
        foulLimit = [[GameSetting defaultSetting].foulsOverQuarterLimit intValue];
    }
    
    if (_teamType == host) {
        [actionManager actionForHomeTeamInMatch:_match withType:ActionTypeFoul atTime:time inPeriod:_period];
        foulSize = actionManager.homeTeamFouls;
    }else {
        [actionManager actionForGuestTeamInMatch:_match withType:ActionTypeFoul atTime:time inPeriod:_period];
        foulSize = actionManager.guestTeamFouls;
    }
    
    if (foulSize >= foulLimit) {
        [self.foulButton setBackgroundImage:[UIImage imageNamed:@"badgeValueRed"] forState:UIControlStateNormal];
    }
    self.foulButton.titleLabel.text = [NSString stringWithFormat:@"%d",foulSize];
}

#pragma FoulActionDelegate
- (void)FoulsBeyondLimit:(NSNumber *)teamId {
    [self showAlertView:@"本节犯规已超最大数，请进行罚球"];
}

@end
