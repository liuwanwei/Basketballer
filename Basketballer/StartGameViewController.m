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
#import "WellKnownSaying.h"
#import "AccountRuleDetailViewController.h"

#import "FibaRule.h"
#import "CustomRuleViewController.h"
#import "NSDictionary+dictionaryWithObject.h"

@interface StartGameViewController () {
//    NSArray * _sectionsTitle;
    Team * _hostTeam;
    Team * _guestTeam;
    NSInteger _curClickRowIndex;
    
//    NSString * __weak _gameMode;
    SingleChoiceViewController * _chooseGameModeView;
    
    NSArray * _modeDetailArray;
}
@end

@implementation StartGameViewController
@synthesize inspirationView = _teamsView;
@synthesize label1 = _label1;
@synthesize label2 = _label2;
//@synthesize matchModeCell = _matchModeCell;

#pragma 私有函数

- (UIColor *)cellDetailTextColor{
    // RGB(81, 86, 132)
    return [UIColor colorWithRed:0.317647 green:0.337254 blue:0.517647 alpha:1.0];
}

// 展示“名言警句”，暂时关闭。
- (void)updateSaying:(NSDictionary *)saying{
    if (saying) {
        UILabel * wordsLabel = (UILabel *)[self.inspirationView viewWithTag:1];
        UILabel * whomLabel = (UILabel *)[self.inspirationView viewWithTag:2];
        UILabel * slash = (UILabel *)[self.inspirationView viewWithTag:3];
        
        NSString * words = [saying objectForKey:kWords];
        wordsLabel.text = words;
        
        NSString * whom = [saying objectForKey:kWhom];
        whomLabel.text = whom;
        
        wordsLabel.hidden = NO;
        whomLabel.hidden = NO;
        slash.hidden = NO;
    }
}

//- (void)newSayingComing:(NSNotification *)notification{
//    NSDictionary * saying = [[WellKnownSaying defaultSaying] lastSaying];
//    if (nil != saying) {
//        [self updateSayingWithWords:saying];
//    }
//}

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
//    _sectionsTitle = [NSArray arrayWithObjects:@"主队", @"客队" ,@"竞技规则",nil];
//    _gameMode = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:0];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    /*[[NSBundle mainBundle] loadNibNamed:@"Inspiration" owner:self options:nil];
    CGRect frame = self.inspirationView.frame;
    frame.size.height = 160;
    self.inspirationView.frame = frame;
    self.tableView.tableFooterView = self.inspirationView;
    
    _modeDetailArray = [NSArray arrayWithObjects:
                      @"We Are Basketball！", 
                      @"无兄弟，不篮球！", nil];*/
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //NSDictionary * saying = [[WellKnownSaying defaultSaying] oneSaying];
    //[self updateSaying:saying];
}

- (void)ruleChangedNotification:(NSNotification *)notification{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            cell.textLabel.text = LocalString(@"Add");
        }
    }

        
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSArray * rules = [[CustomRuleManager defaultInstance] rules];
//    if (indexPath.section == 2 && indexPath.row >= rules.count) {
//        CustomRuleViewController * vc = [[CustomRuleViewController alloc] initWithStyle:UITableViewStyleGrouped];
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
//        [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
//    }
    
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
        
//        NSString * title = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:index];
        NSString * mode = [[[GameSetting defaultSetting] gameModes] objectAtIndex:index];
        UITableViewController * details;
        
        if ([mode isEqualToString:kMatchModeAccount]) {
            details = [[AccountRuleDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
        }else {
            details = [[RuleDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
            ((RuleDetailViewController *)details).rule = [BaseRule ruleWithMode:mode];
        }
//        details.hidesBottomBarWhenPushed = YES;
//        details.title = title;
        [self.navigationController pushViewController:details animated:YES];
    }else{
        NSArray * rules = [[CustomRuleManager defaultInstance] rules];
        FibaCustomRule * rule = [[FibaCustomRule alloc] initWithRuleModel:[rules objectAtIndex:indexPath.row]];
        RuleDetailViewController * vc = [[RuleDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.rule = rule;
        vc.title = rule.name;
//        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
