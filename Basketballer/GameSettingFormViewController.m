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
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwitchBoolHomeTeamPlayer rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"主队队员技术统计"];
    row.value = [NSNumber numberWithBool:gameSetting.enableHomeTeamPlayerStatistics];
    [sectionTeamPlayer addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwitchBoolGuestTeamPlayer rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"客队队员技术统计"];
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
    row.action.viewControllerClass = [RuleDetailViewController class];
    [sectionRule addFormRow:row];
    [form addFormSection:sectionRule];
    
//    // 结束比赛按钮
//    XLFormSectionDescriptor * sectionStop = [XLFormSectionDescriptor formSectionWithTitle:nil];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kButtonStop rowType:XLFormRowDescriptorTypeButton title:LocalString(@"FinishMatch")];
//    row.action.formSelector = @selector(finishButtonClicked:);
//    [row.cellConfig setObject:[UIColor redColor] forKey:@"textLabel.color"];
//    [sectionStop addFormRow:row];
//    [form addFormSection:sectionStop];
    
    self.form = form;

}


@end
