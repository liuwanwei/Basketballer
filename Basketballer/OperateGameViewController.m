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
@synthesize scoreLabel = _scoreLabel;
@synthesize timeoutLabel = _timeoutLabel;
@synthesize foulLabel = _foulLabel;

#pragma 私有函数
/*计算时间差*/
- (NSInteger)computeTimeDifference {
    NSDate * nowDate = [NSDate date];
    NSTimeInterval timeDifference = [nowDate timeIntervalSinceDate:self.gameStartTime]; 
    return timeDifference;
}

#pragma 类成员函数
/*
 设置button可用状态
 比赛开始前、暂停中button不可用
 比赛进行中可用
 注：设置球队按钮除外
 */
- (void)setButtonEnabled:(BOOL) enabled {
    NSInteger size = self.subviews.count;
    for (NSInteger index = 0; index < size; index++) {
        if([[self.subviews objectAtIndex:index] isKindOfClass:[UIButton class]]) {
            [[self.subviews objectAtIndex:index] setEnabled:enabled];
        }
    }
}

/*初始化球队信息*/
- (void)initTeam {
    if(_team != nil) {
        self.teamImageView.image = [[TeamManager defaultManager] imageForTeam:_team];
        self.teamNameLabel.text = _team.name;
    }
}

#pragma 事件函数
- (id)initWithFrame:(CGRect)frame {
    NSArray * nib =[[NSBundle mainBundle] loadNibNamed:@"OperateGameViewController" owner:self options:nil];
    self = [nib objectAtIndex:0];
    self.frame = frame;
    
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
                                            inView:self
                          permittedArrowDirections:UIPopoverArrowDirectionLeft
                                          animated:YES];

}

- (void)addScore:(NSInteger) score {
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",[self.scoreLabel.text intValue] + score];
    
    ActionManager * actionManager = [ActionManager defaultManager];
    NSInteger time = [self computeTimeDifference];
    BOOL result;
    if(_teamType == host) {
        result = [actionManager actionForHomeTeamInMatch:_match withType:score atTime:time inPeriod:_period];
    }else {
        result = [actionManager actionForGuestTeamInMatch:_match withType:score atTime:time inPeriod:_period];
    }
}

- (IBAction)addTimeOver:(id)sender {
    self.timeoutLabel.text = [NSString stringWithFormat:@"%d",[self.timeoutLabel.text intValue] + 1];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTimeoutMessage object:nil];
}

- (IBAction)addFoul:(id)sender {
    self.foulLabel.text = [NSString stringWithFormat:@"%d",[self.foulLabel.text intValue] + 1];
}

@end
