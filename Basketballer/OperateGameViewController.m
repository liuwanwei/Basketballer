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
    NSInteger _timeoutSize;
}
@end

@implementation OperateGameViewController

@synthesize team = _team;
@synthesize teamType = _teamType;
@synthesize gameStartTime = _gameStartTime;
@synthesize teamImageView = _teamImageView;
@synthesize match = _match;
//@synthesize period = _period;
@synthesize teamNameLabel = _teamNameLabel;
@synthesize foulButton = _foulButton;
@synthesize timeoutButton = _timeoutButton;
@synthesize pointButton = _pointButton;
@synthesize pointsLabel = _pointsLabel;
@synthesize timeoutLabel = _timeoutLabel;
@synthesize foulsLabel = _foulsLabel;
@synthesize pointsPromptLabel = _pointsPromptLabel;
@synthesize foulsPromptLabel = _foulsPromptLabel;
@synthesize timeoutPromptLabel = _timeoutPromptLabel;
@synthesize matchMode = _matchMode;

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
        self.teamImageView.layer.masksToBounds = YES;
        self.teamImageView.layer.cornerRadius = 5.0f;
        self.teamImageView.image = [[TeamManager defaultManager] imageForTeam:_team];
        self.teamNameLabel.text = _team.name;
    }
}

- (void)initTimeoutAndFoulView {
    [self.timeoutButton setBackgroundImage:[UIImage imageNamed:@"nil"] forState:UIControlStateNormal];
    self.timeoutLabel.textColor = [UIColor colorWithRed:0.325490196078431 green:0.313725490196078 blue:0.545098039215686 alpha:1.0];
    self.timeoutLabel.text = @"0";
    _timeoutSize = 0;
    
    [self.foulButton setBackgroundImage:[UIImage imageNamed:@"nil"] forState:UIControlStateNormal];
    self.foulsLabel.textColor = [UIColor colorWithRed:0.325490196078431 green:0.313725490196078 blue:0.545098039215686 alpha:1.0];
    self.foulsLabel.text = @"0";
}

- (void)refreshMatchData {
    ActionManager * actionManager = [ActionManager defaultManager];
    NSInteger foulLimit;
    NSInteger timeoutLimit;
    if (_match.mode == kGameModeTwoHalf) {
        foulLimit = [[GameSetting defaultSetting].foulsOverHalfLimit intValue];
        timeoutLimit = [[GameSetting defaultSetting].timeoutsOverHalfLimit intValue];
    }else if (_match.mode == kGameModeFourQuarter){
        foulLimit = [[GameSetting defaultSetting].foulsOverQuarterLimit intValue];
        timeoutLimit = [[GameSetting defaultSetting].timeoutsOverQuarterLimit intValue];
    }else {
        foulLimit = [[GameSetting defaultSetting].foulsOverWinningPointsLimit intValue];
    }
   
    if(_teamType == HostTeam) {
        if (actionManager.homeTeamFouls < foulLimit) {
            self.foulsLabel.textColor = [UIColor colorWithRed:0.325490196078431 green:0.313725490196078 blue:0.545098039215686 alpha:1.0];
        }
        if (actionManager.homeTeamTimeouts < timeoutLimit) {
            self.timeoutLabel.textColor = [UIColor colorWithRed:0.325490196078431 green:0.313725490196078 blue:0.545098039215686 alpha:1.0];
        }
        self.foulsLabel.text = [NSString stringWithFormat:@"%d",actionManager.homeTeamFouls];
        self.pointsLabel.text = [NSString stringWithFormat:@"%d",actionManager.homeTeamPoints];
        self.timeoutLabel.text = [NSString stringWithFormat:@"%d",actionManager.homeTeamTimeouts];
        _timeoutSize = actionManager.homeTeamTimeouts;
    }else {
        if (actionManager.guestTeamFouls < foulLimit) {
            self.foulsLabel.textColor = [UIColor colorWithRed:0.325490196078431 green:0.313725490196078 blue:0.545098039215686 alpha:1.0];
        }
        if (actionManager.guestTeamTimeouts < timeoutLimit) {
            self.timeoutLabel.textColor = [UIColor colorWithRed:0.325490196078431 green:0.313725490196078 blue:0.545098039215686 alpha:1.0];
        }
        self.pointsLabel.text = [NSString stringWithFormat:@"%d",actionManager.guestTeamPoints];
        self.timeoutLabel.text = [NSString stringWithFormat:@"%d",actionManager.guestTeamTimeouts];
        self.foulsLabel.text = [NSString stringWithFormat:@"%d",actionManager.guestTeamFouls];
        _timeoutSize = actionManager.guestTeamTimeouts;
    }
    
}

#pragma 类成员函数
- (void)initButtonsLayout {
    if (_matchMode == kGameModePoints) {
        self.timeoutButton.hidden = YES;
        self.timeoutPromptLabel.hidden = YES;
        self.timeoutLabel.hidden = YES;
        
        self.pointButton.layer.frame = CGRectMake(self.pointButton.layer.frame.origin.x, self.pointButton.layer.frame.origin.y, 150.0, self.pointButton.layer.frame.size.height);
        self.pointsPromptLabel.layer.frame = CGRectMake(self.pointsPromptLabel.layer.frame.origin.x + 30.0, self.pointsPromptLabel.layer.frame.origin.y, self.pointsPromptLabel.layer.frame.size.width, self.pointsPromptLabel.layer.frame.size.height);
        self.pointsLabel.layer.frame = CGRectMake(self.pointsLabel.layer.frame.origin.x + 30.0, self.pointsLabel.layer.frame.origin.y, self.pointsLabel.layer.frame.size.width, self.pointsLabel.layer.frame.size.height);
        
        self.foulButton.layer.frame = CGRectMake(self.foulButton.layer.frame.origin.x + 51.0, self.foulButton.layer.frame.origin.y, 150.0, self.foulButton.layer.frame.size.height);
        self.foulsPromptLabel.layer.frame = CGRectMake(self.foulsPromptLabel.layer.frame.origin.x + 80.0, self.foulsPromptLabel.layer.frame.origin.y, self.foulsPromptLabel.layer.frame.size.width, self.foulsPromptLabel.layer.frame.size.height);
        self.foulsLabel.layer.frame = CGRectMake(self.foulsLabel.layer.frame.origin.x + 80.0, self.foulsLabel.layer.frame.origin.y, self.foulsLabel.layer.frame.size.width, self.foulsLabel.layer.frame.size.height);
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
    sender.backgroundColor = [UIColor whiteColor];
    /*if(_popoverController == nil && _popoverContentController == nil) {
        _popoverContentController = [[WEPopoverContentViewController alloc] initWithStyle:UITableViewStylePlain];
        _popoverController = [[WEPopoverController alloc] initWithContentViewController:_popoverContentController];
        
        _popoverContentController.wePopoverController = _popoverController;
        _popoverContentController.opereteGameViewController = self;
    }
    
    [_popoverController presentPopoverFromRect:sender.frame 
                                            inView:sender
                          permittedArrowDirections:UIPopoverArrowDirectionDown
                                          animated:YES];*/
    UIActionSheet * menu = [[UIActionSheet alloc] initWithTitle:_team.name delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@" + 1分",@" + 2分",@" + 3分", nil];
    menu.tag = 1;
    [menu showInView:self];
}

- (void)addScore:(NSInteger) score {
    ActionManager * actionManager = [ActionManager defaultManager];
    NSInteger time = [self computeTimeDifference];
    NSInteger points;
    
    if(_teamType == HostTeam) {
        [actionManager actionForHomeTeamInMatch:_match withType:score atTime:time];        
        points = [actionManager homeTeamPoints];
    }else {
        [actionManager actionForGuestTeamInMatch:_match withType:score atTime:time];
        points = [actionManager guestTeamPoints];
    }
    self.pointsLabel.text = [NSString stringWithFormat:@"%d",points];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddScoreMessage object:nil];
}

- (IBAction)addTimeOver:(UIButton *)sender {
    sender.backgroundColor = [UIColor whiteColor];
    NSInteger timeoutLimit;
    if (_match.mode == kGameModeTwoHalf) {
        timeoutLimit = [[GameSetting defaultSetting].timeoutsOverHalfLimit intValue];
    }else {
        timeoutLimit = [[GameSetting defaultSetting].timeoutsOverQuarterLimit intValue];
    }
    
    if (_timeoutSize >= timeoutLimit) {
        [self showAlertView:@"本节暂停已使用完"];

    }else {
        UIActionSheet * menu = [[UIActionSheet alloc] initWithTitle:_team.name delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@" + 1次暂停", nil];
        menu.tag = 3;
        [menu showInView:self];    
    }
}

- (IBAction)addFoul:(id)sender {
    self.foulButton.backgroundColor = [UIColor whiteColor];
    UIActionSheet * menu = [[UIActionSheet alloc] initWithTitle:_team.name delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@" + 1次犯规", nil];
    menu.tag = 2;
    [menu showInView:self];
}

- (IBAction)buttonDown:(UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithRed:0.215686274509803 green:0.392156862745098 blue:0.839215686274509 alpha:1];
}

- (IBAction)buttonTouchOutside:(UIButton *)sender {
     sender.backgroundColor = [UIColor whiteColor];
}

#pragma FoulActionDelegate
- (void)FoulsBeyondLimit:(NSNumber *)teamId {
    [self showAlertView:@"本节犯规已超最大数，请进行罚球"];
}

#pragma mark - ActionSheet view delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        [self addScore:buttonIndex + 1];
    }else if (actionSheet.tag == 2){
        if (buttonIndex == 0) {
            ActionManager * actionManager = [ActionManager defaultManager];
            NSInteger time = [self computeTimeDifference];
            NSInteger foulSize;
            NSInteger foulLimit;
            if (_match.mode == kGameModeTwoHalf) {
                foulLimit = [[GameSetting defaultSetting].foulsOverHalfLimit intValue];
            }else if (_match.mode == kGameModeFourQuarter){
                foulLimit = [[GameSetting defaultSetting].foulsOverQuarterLimit intValue];
            }else {
                foulLimit = [[GameSetting defaultSetting].foulsOverWinningPointsLimit intValue];
            }
            
            if (_teamType == HostTeam) {
                [actionManager actionForHomeTeamInMatch:_match withType:ActionTypeFoul atTime:time];                
                foulSize = actionManager.homeTeamFouls;
            }else {
                [actionManager actionForGuestTeamInMatch:_match withType:ActionTypeFoul atTime:time];
                foulSize = actionManager.guestTeamFouls;
            }
            
            if (foulSize >= foulLimit) {
                self.foulsLabel.textColor = [UIColor redColor];
            }
            self.foulsLabel.text = [NSString stringWithFormat:@"%d",foulSize];
        }
    }else {
        if (buttonIndex == 0) {
            ActionManager * actionManager = [ActionManager defaultManager];
            NSInteger time = [self computeTimeDifference];
            BOOL result;
            
            if(_teamType == HostTeam) {
                result = [actionManager actionForHomeTeamInMatch:_match withType:ActionTypeTimeout atTime:time];            
            }else {
                result = [actionManager actionForGuestTeamInMatch:_match withType:ActionTypeTimeout atTime:time];
            }
            if (result) {
                NSInteger timeoutLimit;
                if (_match.mode == kGameModeTwoHalf) {
                    timeoutLimit = [[GameSetting defaultSetting].timeoutsOverHalfLimit intValue];
                }else {
                    timeoutLimit = [[GameSetting defaultSetting].timeoutsOverQuarterLimit intValue];
                }
                if (_teamType == HostTeam) {
                    _timeoutSize = actionManager.homeTeamTimeouts;
                    
                }else {
                    _timeoutSize = actionManager.guestTeamTimeouts;
                }
                if (timeoutLimit == _timeoutSize) {
                    self.timeoutLabel.textColor = [UIColor redColor];
                }
                self.timeoutLabel.text = [NSString stringWithFormat:@"%d",_timeoutSize];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTimeoutMessage object:nil];
            }else {
                [self showAlertView:@"本节暂停已使用完"];
            }
        }
    }
}

@end
