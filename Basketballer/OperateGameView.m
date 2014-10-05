//
//  OperateGameViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OperateGameView.h"
#import "PlayGameViewController.h"
#import "TeamManager.h"
#import "ImageManager.h"
#import "MatchManager.h"
#import "GameSetting.h"
#import "ActionManager.h"
#import "MatchUnderWay.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define kFoulButtunTag 100

@interface OperateGameView() {
    MatchUnderWay * _match;
}
@end

@implementation OperateGameView

@synthesize team = _team;
@synthesize statistics = _statstics;
@synthesize teamImageButton = _teamImageButton;
@synthesize backgroundButton = _backgroundButton;
@synthesize foulButton = _foulButton;
@synthesize teamImageView = _teamImageView;
@synthesize teamNameLabel = _teamNameLabel;
@synthesize timeoutLabel = _timeoutLabel;
@synthesize foulsLabel = _foulsLabel;
@synthesize pointsPromptLabel = _pointsPromptLabel;
@synthesize foulsPromptLabel = _foulsPromptLabel;
@synthesize timeoutPromptLabel = _timeoutPromptLabel;

#pragma 私有函数
- (void)showAlertView{
    UIAlertView * alertView = [[UIAlertView alloc] 
                               initWithTitle:LocalString(@"BeginMatchPrompt") 
                               message:LocalString(@"MatchUnbeginPrompt") delegate:self 
                               cancelButtonTitle:LocalString(@"No") 
                               otherButtonTitles:LocalString(@"Yes") , nil];
    [alertView show];
}

- (UIColor *)blueGreyColor {
    static UIColor * blueGrey;
    if(blueGrey == nil) {
        blueGrey = [UIColor colorWithRed:0.3 green:0.3 blue:0.5 alpha:1.0];
    }
    
    return blueGrey;
}

- (void)showShadow:(UIButton *)button {
    button.layer.masksToBounds = NO;
    button.layer.shouldRasterize = YES;
    button.layer.cornerRadius = 5.0f;
    button.layer.shadowOffset = CGSizeMake(1.0, 2.0);
    button.layer.shadowOpacity = 0.7;  
    button.layer.shadowColor =  [UIColor blackColor].CGColor;
}

- (void)hideShadow:(UIButton *)button {
    button.layer.shadowOffset =  CGSizeMake(0,0);  
    button.layer.shadowOpacity = 0;
}

- (void)showBoard:(UIButton *)button {
    button.layer.masksToBounds = NO;
    button.layer.shouldRasterize = YES;
    button.layer.cornerRadius = 5.0f;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)showBgGaryColor:(UIButton *)button {
    button.backgroundColor = [UIColor lightGrayColor];
}

- (void)showBgClearColor:(UIButton *)button {
    button.backgroundColor = [UIColor clearColor];
}

#pragma 类成员函数
/*
 设置button可用状态
 比赛开始前、暂停中button不可用
 比赛进行中可用
 */
- (void)setButtonEnabled:(BOOL) enabled {
    NSInteger size = self.subviews.count;
    for (NSInteger index = 0; index < size; index++) {
        if([[self.subviews objectAtIndex:index] isKindOfClass:[UIButton class]]) {
            [[self.subviews objectAtIndex:index] setEnabled:enabled];
        }
    }
}

- (void)initButtonsLayout {
    [self showShadow:self.backgroundButton];
    [self showShadow:self.teamImageButton];
    //[self showBoard:self.foulButton];
}

- (void)initContentWithTeam:(Team *)team {
    _team = team;

    [self initTeam];
    [self initButtonsLayout];
    //[self setButtonEnabled:NO];
}

/*初始化球队信息*/
- (void)initTeam {
    if(_team != nil) {
        self.teamImageView.layer.masksToBounds = YES;
        self.teamImageView.layer.cornerRadius = 5.0f;
        self.teamImageView.image = [[ImageManager defaultInstance] imageForName:_team.profileURL];
        self.teamNameLabel.text = _team.name;
    }
}

- (void)initTimeoutAndFoulView {
    if ([_match.rule isTimeoutExpiredBeforePeriod:_match.period] == YES) {
        self.timeoutLabel.textColor = [self blueGreyColor];
        self.timeoutLabel.text = @"0";
    }
    
    self.foulsLabel.textColor = [self blueGreyColor];
    self.foulsLabel.text = @"0";
}

- (void)refreshMatchData {
    if ([_statstics.fouls integerValue] <= [_match.rule foulLimitForTeam]) {
        self.foulsLabel.textColor = [self blueGreyColor];
    }
    
    NSInteger timeoutLimit = [_match.rule timeoutLimitBeforeEndOfPeriod:_match.period];
    if ([_statstics.timeouts integerValue] < timeoutLimit) {
        self.timeoutLabel.textColor = [self blueGreyColor];
    }
    self.foulsLabel.text = [_statstics.fouls stringValue];
    self.timeoutLabel.text = [_statstics.timeouts stringValue];
}

- (void)foulChanged:(NSNotification *)notification{
    if (nil != notification) {
        NSNumber * teamId = notification.object;
        if ([teamId isEqualToNumber:_team.id]) {
            // 刷新界面中的犯规次数。
            self.foulsLabel.text = [_statstics.fouls stringValue];
            if ([_statstics.fouls integerValue] > [_match.rule foulLimitForTeam]) {
                self.foulsLabel.textColor = [UIColor redColor];
            }
        }
    }
}

- (void)timeoutChanged:(NSNotification *)notification{
    if (nil != notification) {
        NSNumber * teamId = notification.object;
        if ([teamId isEqualToNumber:_team.id]) {
            // 刷新界面中的暂停次数。
            self.timeoutLabel.text = [_statstics.timeouts stringValue];
            NSInteger timeoutLimit = [_match.rule timeoutLimitBeforeEndOfPeriod:_match.period];
            if ([_statstics.timeouts integerValue] == timeoutLimit) {
                self.timeoutLabel.textColor = [UIColor redColor];
            }
        }
    }    
}

- (void)hideFoulsAndTimeoutView {
    [_foulsLabel setHidden:YES];
    [_foulsPromptLabel setHidden:YES];
    [_timeoutLabel setHidden:YES];
    [_timeoutPromptLabel setHidden:YES];
    _teamNameLabel.frame = CGRectMake(_teamNameLabel.frame.origin.x,_teamNameLabel.frame.origin.y + 15,_teamNameLabel.frame.size.width,_teamNameLabel.frame.size.height);
}

#pragma 事件函数
- (id)initWithFrame:(CGRect)frame {
    NSArray * nib =[[NSBundle mainBundle] loadNibNamed:@"OperateGameView" owner:self options:nil];
    self = [nib objectAtIndex:0];
    self.frame = frame;
    self.layer.cornerRadius = 5.0f;
    _match = [MatchUnderWay defaultMatch];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(foulChanged:) name:kAddFoulMessage object:nil];
    [nc addObserver:self selector:@selector(timeoutChanged:) name:kAddTimeoutMessage object:nil];
    
    self.foulsPromptLabel.text = LocalString(@"Foul");
    self.timeoutPromptLabel.text = LocalString(@"Timeout");
    
    return self;
}

- (IBAction)teamImageTouched:(UIButton *)sender{
    [self showShadow:sender];
    
    if (_match.state == MatchStatePrepare) {
        [self showAlertView];
        return;
    }
    
    PlayGameViewController * playViewController = [[AppDelegate delegate] playGameViewController];
    [playViewController showNewActionViewForTeam:_team withTeamStatistics:_statstics];
}

- (IBAction)foulButtonTouched:(id)sender {
    [self showBgClearColor:sender];
    
    if (_match.state == MatchStatePrepare) {
        [self showAlertView];
        return;
    }
    
    PlayGameViewController * playViewController = [[AppDelegate delegate] playGameViewController];
    [playViewController showPlayerFoulStatisticViewControllerForTeam:_team];
}

- (IBAction)buttonDown:(UIButton *)sender {
    if (sender.tag == kFoulButtunTag) {
        [self showBgGaryColor:sender];
    }else {
        [self hideShadow:sender];
    }
}

- (IBAction)buttonTouchOutside:(UIButton *)sender {
    if (sender.tag == kFoulButtunTag) {
        [self showBgClearColor:sender];
    }else {
        [self showShadow:sender];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [[[AppDelegate delegate] playGameViewController] startGame:nil];
    }
}

@end
