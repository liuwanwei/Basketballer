//
//  MatchSettingViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameSettingViewController.h"
#import "GameSetting.h"
#import "AppDelegate.h"
#import "PlayGameViewController.h"
#import "RuleDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MatchUnderWay.h"
#import "Feature.h"
#import "Rule.h"
#import "GameSetting.h"
#import "AccountRuleDetailViewController.h"

typedef enum{
    CellTagMessage = 1,
    CellTagSwitch = 2
}CellElementTag;

typedef enum{
    SwitchTagStatistics = 1,
    SwitchTagSound
}SwitchTag;

@interface GameSettingViewController ()

@end

@implementation GameSettingViewController
@synthesize switchCell = _switchCell;

#pragma 私有函数
- (void)showAlertViewWithTitle:(NSString *) title withMessage:(NSString *)message {
    UIAlertView * alertView;
    alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:LocalString(@"Cancel")  otherButtonTitles:LocalString(@"Save"),LocalString(@"Abandon") , nil];
        
    [alertView show];
}

- (void)AbandonGame {
    PlayGameViewController * playViewController = [[AppDelegate delegate] playGameViewController];
    if (nil != playViewController) {
        NSString * title;
        if ([[MatchUnderWay defaultMatch].matchMode isEqualToString:kMatchModeAccount]) {
            title = LocalString(@"FinishMatch");
        }else {
            title = LocalString(@"AbandonGame");
        }
        if (YES == playViewController.gameStart) {
            [self showAlertViewWithTitle:title withMessage:LocalString(@"SaveMatchPrompt")];
        }else {
            [playViewController stopGame:MatchStateStopped withWinTeam:nil];
        }
    }
}

- (void)initUIButton {
    
    NSString * buttonTitle;
    if ([[MatchUnderWay defaultMatch].matchMode isEqualToString:kMatchModeAccount]) {
        buttonTitle = LocalString(@"FinishMatch");
    }else {
        buttonTitle = LocalString(@"AbandonGame");
    }
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 54)];
    UIButton * button;
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.frame = CGRectMake(10, 15, 300, 44);
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    [button setBackgroundImage:[UIImage imageNamed:@"buttonDelete"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(AbandonGame) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    self.tableView.tableFooterView = view;
}

- (void)statisticsSwitchValueChanged:(UISwitch *)sender{
    [[GameSetting defaultSetting] setEnablePlayerStatistics:sender.on];
}

- (void)soundSwitchValueChanged:(UISwitch *)sender{
    [[GameSetting defaultSetting] setEnableAutoPromptSound:sender.on];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LocalString(@"Setting");
    [self initUIButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (0 == section) {
        return LocalString(@"PlayerStatisticDetail");
    }else if(1 == section){
        return LocalString(@"SoundEffectDetail");
    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * SwitchCellIdentifier = @"SwitchCell";
    if (0 == indexPath.section ||
        1 == indexPath.section) {
        [[NSBundle mainBundle] loadNibNamed:SwitchCellIdentifier owner:self options:nil];
        UITableViewCell * cell = _switchCell;
        self.switchCell = nil;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        BOOL isOn = NO;
        UILabel * label = (UILabel *)[cell.contentView viewWithTag:CellTagMessage];
        UISwitch * object = (UISwitch *)[cell.contentView viewWithTag:CellTagSwitch];
        if (0 == indexPath.section) {
            label.text = LocalString(@"PlayerStatistic");
            isOn = [GameSetting defaultSetting].enablePlayerStatistics;            
            [object addTarget:self action:@selector(statisticsSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
        }else if(1 == indexPath.section){
            isOn = [GameSetting defaultSetting].enableAutoPromptSound;
            label.text = LocalString(@"SoundEffectSwitch");
            [object addTarget:self action:@selector(soundSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];            
        }
        
        [object setOn:isOn];
        
        return cell;   
    }else if(indexPath.section == 2){
        UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ToNextVCCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = LocalString(@"Rule");
        // 填充真正规则名称
        cell.detailTextLabel.text = self.ruleInUse.name;
        
        return cell;
    }
    else{
        return nil;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        if ([self.ruleInUse.name isEqualToString:kMatchModeAccount]) {
            AccountRuleDetailViewController * vc = [[AccountRuleDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            RuleDetailViewController * vc = [[RuleDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
            vc.editable = NO;
            vc.rule = self.ruleInUse;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma alert delete
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        PlayGameViewController * playViewController = [[AppDelegate delegate] playGameViewController];
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [playViewController stopGame:MatchStateFinished withWinTeam:nil];
        }else {
            [playViewController stopGame:MatchStateStopped withWinTeam:nil];   
        }
    }
}
@end
