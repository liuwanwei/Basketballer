//
//  GameSettingFormViewController.m
//  Basketballer
//
//  Created by sungeo on 15/2/21.
//
//

#import "GameSettingFormViewController.h"
#import "RuleDetailViewController.h"
#import "PlayGameViewController.h" // TODO: 应该通过Notification通信
#import "GameSetting.h"
#import "MatchUnderWay.h"
#import "AppDelegate.h" // TODO: 为了引用LocalString，应该移到公共部分

NSString * const kSwitchBoolHomeTeamPlayer = @"switchBoolHomeTeamPlayer";
NSString * const kSwitchBoolGuestTeamPlayer = @"switchBoolGuestTeamPlayer";
NSString * const kSwitchBoolSoundEffect = @"switchBoolSoundEffect";
NSString * const kGameRules = @"gameRule";
NSString * const kButtonStop = @"buttonStop";

@implementation GameSettingFormViewController

- (instancetype)init{
    if (self = [super init]) {
        [self initializeForm];
    }
    
    return self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    GameSetting * gameSetting = [GameSetting defaultSetting];
    gameSetting.enableHomeTeamPlayerStatistics = [[self.form formRowWithTag:kSwitchBoolHomeTeamPlayer].value boolValue];
    gameSetting.enableGuestTeamPlayerStatistics = [[self.form formRowWithTag:kSwitchBoolGuestTeamPlayer].value boolValue];
    gameSetting.enableAutoPromptSound = [[self.form formRowWithTag:kSwitchBoolSoundEffect].value boolValue];
}

- (void)initializeForm{
    GameSetting * gameSetting = [GameSetting defaultSetting];
    
    XLFormDescriptor * form = [XLFormDescriptor formDescriptorWithTitle:LocalString(@"Setting")];
    XLFormSectionDescriptor * sectionTeamPlayer = [XLFormSectionDescriptor formSectionWithTitle:nil];
    sectionTeamPlayer.footerTitle = LocalString(@"PlayerStatisticDetail");;
    
    // 球员统计开关
    XLFormRowDescriptor * row;
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwitchBoolHomeTeamPlayer rowType:XLFormRowDescriptorTypeBooleanSwitch title:LocalString(@"PlayerStatistic1")];
    row.value = [NSNumber numberWithBool:gameSetting.enableHomeTeamPlayerStatistics];
    [sectionTeamPlayer addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwitchBoolGuestTeamPlayer rowType:XLFormRowDescriptorTypeBooleanSwitch title:LocalString(@"PlayerStatistic2")];
    row.value = [NSNumber numberWithBool:gameSetting.enableGuestTeamPlayerStatistics];
    [sectionTeamPlayer addFormRow:row];
    [form addFormSection:sectionTeamPlayer];
    
    // 播放暂停、开始提示音
    XLFormSectionDescriptor * sectionSound = [XLFormSectionDescriptor formSectionWithTitle:nil];
    sectionSound.footerTitle = LocalString(@"SoundEffectDetail");
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwitchBoolSoundEffect rowType:XLFormRowDescriptorTypeBooleanSwitch title:LocalString(@"SoundEffectSwitch")];
    row.value = [NSNumber numberWithBool:gameSetting.enableAutoPromptSound];
    [sectionSound addFormRow:row];
    [form addFormSection:sectionSound];
    
    // 比赛规则
    XLFormSectionDescriptor * sectionRule = [XLFormSectionDescriptor formSectionWithTitle:nil];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGameRules rowType:XLFormRowDescriptorTypeButton title:LocalString(@"Rule")];
    row.buttonViewController = [RuleDetailViewController class];
    [sectionRule addFormRow:row];
    [form addFormSection:sectionRule];
    
    // 结束比赛按钮
    XLFormSectionDescriptor * sectionStop = [XLFormSectionDescriptor formSectionWithTitle:nil];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kButtonStop rowType:XLFormRowDescriptorTypeButton title:LocalString(@"FinishMatch")];
    row.action.formSelector = @selector(finishButtonClicked:);
    [sectionStop addFormRow:row];
    [form addFormSection:sectionStop];
    
    self.form = form;

}

//- (void)showRuleDetails:(id)sender{
//    RuleDetailViewController * vc = [[RuleDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    vc.editable = NO;
//    vc.rule = self.ruleInUse;
//    [self.navigationController pushViewController:vc animated:YES];
//
//}

- (void)finishButtonClicked:(id)sender{
    PlayGameViewController * playViewController = [[AppDelegate delegate] playGameViewController];
    if (nil != playViewController) {
        NSString * title;
        if ([[MatchUnderWay defaultMatch].matchMode isEqualToString:kMatchModeAccount]) {
            title = LocalString(@"FinishMatch");
        }else {
            title = LocalString(@"AbandonGame");
        }
        if (YES == playViewController.gameStart) {
            UIAlertView * alertView;
            alertView = [[UIAlertView alloc] initWithTitle:title message:LocalString(@"SaveMatchPrompt") delegate:self cancelButtonTitle:LocalString(@"Cancel")  otherButtonTitles:LocalString(@"Save"),LocalString(@"Abandon") , nil];
            
            [alertView show];
        }else {
            [playViewController stopGame:MatchStateStopped withWinTeam:nil];
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
