//
//  StartGameViewController.m
//  Basketballer
//  新比赛界面（第一个Tab）
//  Created by maoyu on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StartGameViewController.h"
#import "TeamListViewController.h"
#import "TeamManager.h"
#import "CustomRuleManager.h"
#import "Rule.h"
#import "FibaCustomRule.h"
#import "PlayGameViewController.h"
#import "GameSetting.h"
#import "AppDelegate.h"
#import "Feature.h"
#import "ChooseTeamViewController.h"
#import "RuleDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ActionManager.h"
#import "MatchUnderWay.h"
#import "PointsRuleDetailViewController.h"

#import "FibaRule.h"
#import "CustomRuleViewController.h"
#import "NSDictionary+dictionaryWithObject.h"

@interface StartGameViewController () {
    Team * _hostTeam;
    Team * _guestTeam;
    NSInteger _curClickRowIndex;
    
    SingleChoiceViewController * _chooseGameModeView;
    
    NSArray * _modeDetailArray;
}
@end

@implementation StartGameViewController
@synthesize inspirationView = _teamsView;
@synthesize label1 = _label1;
@synthesize label2 = _label2;

#pragma 私有函数

- (UIColor *)cellDetailTextColor{
    // RGB(81, 86, 132)
    return [UIColor colorWithRed:0.317647 green:0.337254 blue:0.517647 alpha:1.0];
}

#pragma 类成员函数

#pragma 事件函数
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 60;
    self.title = NSLocalizedString(@"Start", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ruleChangedNotification:) name:kRuleChangedNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// 处理自定义规则消息
- (void)ruleChangedNotification:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 1 : Fiba
    // 2 : 简单记分
    // 3 : 自定义
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else if(section == 1){
        return 1;
    }else if(section == 2){
        // 所有自定义规则入口，再加上“添加新规则入口”
        return ([[CustomRuleManager defaultInstance].rules count] + 1);
    }else{
        return 0;
    }
}

// 图片圆角化。
- (void)makeRoundedImage:(UIImageView *)image{
    image.layer.masksToBounds = YES;
    image.layer.cornerRadius = 5.0f;    
}

- (NSInteger)gameModeIndexForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return indexPath.row;
    }else if(indexPath.section == 1){
        return (2 + indexPath.row);      // 跳过第一个section的两行
    }else{
        return -1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return LocalString(@"FibaMode");
    }else if(section == 1){
        return LocalString(@"FreeMode");
    }else if(section == 2){
        return LocalString(@"CustomMode");
    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
  
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    cell.textLabel.textColor = [self cellDetailTextColor];
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        NSInteger index = [self gameModeIndexForIndexPath:indexPath];
        
        cell.textLabel.text = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:index];
        
        if (indexPath.section == 0) {
            cell.imageView.image = [UIImage imageNamed:@"BasketballBlueWhite"];
        }else if(indexPath.section == 1){
            cell.imageView.image = [UIImage imageNamed:@"BasketballBlueRed"];
        }
    }else{
        NSArray * rules = [[CustomRuleManager defaultInstance] rules];
        if (indexPath.row < rules.count) {
            Rule * rule = [rules objectAtIndex:indexPath.row];
            cell.textLabel.text = rule.name;
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = LocalString(@"Add");
        }
    }

        
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameSetting * gs = [GameSetting defaultSetting];
    MatchUnderWay * match = [MatchUnderWay defaultMatch];
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        // 使用内置规则进行比赛
        NSInteger index = [self gameModeIndexForIndexPath:indexPath];
        
        match.matchMode = [gs.gameModes objectAtIndex:index];
        
        ChooseTeamViewController * viewController;
        viewController = [[ChooseTeamViewController alloc] initWithNibName:@"ChooseTeamViewController" bundle:nil];
        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:viewController];
        
        [[AppDelegate delegate] presentModelViewController:nav];
    }else if(indexPath.section == 2){
        CustomRuleViewController * vc = [[CustomRuleViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.createMode = YES;
        
        NSArray * rules = [[CustomRuleManager defaultInstance] rules];
        if (indexPath.row >= rules.count) {
            // 新建自定义规则
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            // 使用自定义规则进行比赛
            Rule * rule = [rules objectAtIndex:indexPath.row];
            match.matchMode = rule.name;
            
            ChooseTeamViewController * viewController;
            viewController = [[ChooseTeamViewController alloc] initWithNibName:@"ChooseTeamViewController" bundle:nil];
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:viewController];
            
            [[AppDelegate delegate] presentModelViewController:nav];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        NSInteger index = [self gameModeIndexForIndexPath:indexPath];
        
        NSString * mode = [[[GameSetting defaultSetting] gameModes] objectAtIndex:index];
        if ([mode isEqualToString:kMatchModePoints]) {
            // 记分模式
            PointsRuleDetailViewController * details;
            details = [[PointsRuleDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:details animated:YES];
            
        }else {
            // Fiba模式
            RuleDetailViewController * details;
            details = [[RuleDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
            details.rule = [BaseRule ruleWithName:mode];
            [self.navigationController pushViewController:details animated:YES];
        }
        
    }else{
        // 自定义模式
        NSArray * rules = [[CustomRuleManager defaultInstance] rules];
        Rule * ruleModel = rules[indexPath.row];
        BaseRule * rule = [BaseRule ruleWithName:ruleModel.name];
        
        RuleDetailViewController * vc = [[RuleDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.rule = rule;
        vc.editable = YES;
        vc.title = rule.name;

        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
