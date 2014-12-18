//
//  RuleDetailViewController.m
//  Basketballer    规则详情界面
//
//  Created by Liu Wanwei on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RuleDetailViewController.h"
#import "BaseRule.h"
#import "FibaRule.h"
#import "Fiba3pbRule.h"
#import "FibaCustomRule.h"
#import "CustomRuleManager.h"
#import "CustomRuleViewController.h"
#import "AppDelegate.h"
#import "Feature.h"

@interface RuleDetailViewController (){
    NSArray * _ruleTypeHeader;
    NSArray * _rowsInSection;
}

@end

@implementation RuleDetailViewController
@synthesize rule = _rule;

- (id)initWithStyle:(UITableViewStyle)style
{
    if(self = [super initWithStyle:style]){
        self.editable = YES;
    }
    
    return self;
}

- (void)makeRuleDetailString{
    NSArray * _timeRules;
    NSArray * _foulRules;
    NSArray * _timeoutRules;
    NSArray * _winningRules;
    
    _ruleTypeHeader = [NSArray arrayWithObjects:
                       LocalString(@"Time"),
                       LocalString(@"Foul"),
                       LocalString(@"Timeout"),
                       LocalString(@"Special"),
                       nil];
    
    _timeRules = [NSArray arrayWithObjects:
                  LocalString(@"PeriodNumber"),
                  LocalString(@"PeriodLength"),
                  LocalString(@"PeriodIntervalLength"),
                  LocalString(@"HalfTimeIntervalLength"),
                  LocalString(@"ExtraPeriodLength"),
                  LocalString(@"ExtraPeriodIntervalLength"),
                  nil];
    
    _foulRules = [NSArray arrayWithObjects:
                  LocalString(@"PersonalFoulLimit"),
                  LocalString(@"TeamFoulLimitWithinPeriod"),
                  nil];
    
    _timeoutRules = [NSArray arrayWithObjects:
                     LocalString(@"1stHalfTimeoutLimit"),
                     LocalString(@"2ndHalfTimeoutLimit"),
                     LocalString(@"OvertimeTimeoutLimit"),
                     LocalString(@"TimeoutLength"),
                     nil];
    
    _winningRules = [NSArray arrayWithObject:LocalString(@"Special")];
    _rowsInSection = [NSArray arrayWithObjects:_timeRules, _foulRules, _timeoutRules, _winningRules, nil];
}

// 修改自定义规则
- (void)modifyCustomRule{
    CustomRuleViewController * vc = [[CustomRuleViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.rule = (FibaCustomRule *)self.rule;
    [self.navigationController pushViewController:vc animated:YES];
}

// 删除自定义规则
- (void)deleteCustomRule{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:LocalString(@"DeleteRule") message:LocalString(@"a-u-sure?") delegate:self cancelButtonTitle:LocalString(@"Cancel") otherButtonTitles:LocalString(@"Confirm"), nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        // 取消
    }else if(buttonIndex == 1){
        // 确定要删除规则
        FibaCustomRule * customRule = (FibaCustomRule *)self.rule;
        [[CustomRuleManager defaultInstance] deleteRule:customRule.model];
        
        // 通知上层界面刷新规则列表
        [[NSNotificationCenter defaultCenter] postNotificationName:kRuleChangedNotification object:nil];
        
        // 返回上级界面
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

// 弹出编辑菜单
- (void)editMenu{
    UIActionSheet * menu = [[UIActionSheet alloc]
                            initWithTitle:nil delegate:self
                            cancelButtonTitle:LocalString(@"Cancel")
                            destructiveButtonTitle:LocalString(@"DeleteRule")
                            otherButtonTitles:LocalString(@"ModifyRule"), nil];
    
    [menu showInView:[UIApplication sharedApplication].keyWindow];

}

#pragma mark - ActionSheet view delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == actionSheet.destructiveButtonIndex) {
        [self deleteCustomRule];
    }else if(buttonIndex == actionSheet.firstOtherButtonIndex){
        [self modifyCustomRule];
    }
}

// 修改自定义规则消息通知处理
- (void)ruleChangedNotification:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation: UITableViewRowAnimationAutomatic];
    });
}

#pragma mark - 界面初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self makeRuleDetailString];
    
    self.title = LocalString(@"Rule");
    
    if ([self.rule isKindOfClass:[FibaCustomRule class]] && self.editable) {
        // 只允许“自定义规则”详情出现“编辑”按钮（比赛时例外，通过editable属性控制）
        UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editMenu)];
        self.navigationItem.rightBarButtonItem = item;
    }
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _ruleTypeHeader.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_ruleTypeHeader objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray * rows = [_rowsInSection objectAtIndex:section];
    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    if (indexPath.section == 3) {
        cell.textLabel.text = [self winningCondition];
    }else{
        NSArray * rows = [_rowsInSection objectAtIndex:indexPath.section];
        cell.textLabel.text = [rows objectAtIndex:indexPath.row];        
    }
    
    [self setRuleDetailForCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)setRuleDetailForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    NSString * detail = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                detail = [self regularPeriodNumber];
                break;
            case 1:
                detail = [self periodTimeLength];
                break;
            case 2:
                detail = [self restTimeLength];
                break;
            case 3:
                detail = [self restTimeLengthForHalftime];
                break;
            case 4:
                detail = [self overtimeLength];
                break;
            case 5:
                detail = [self restTimeLengthForOvertime];
                break;
            default:
                break;
        }

    }else if(indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                detail = [self playerFoulLimit];
                break;
            case 1:
                detail = [self teamFoulLimit];
                break;
            default:
                break;
        }
    }else if(indexPath.section == 2){
        switch (indexPath.row) {
            case 0:
                detail = [self timeoutLimitForPeriod:MatchPeriodSecond];
                break;
            case 1:
                detail = [self timeoutLimitForPeriod:MatchPeriodFourth];
                break;
            case 2:
                detail = [self timeoutLimitForPeriod:MatchPeriodOvertime];
                break;
            case 3:
                detail = [self timeoutLength];
                break;
            default:
                break;
        }   
    }
    
    cell.detailTextLabel.text = detail;
}

- (NSString *)readableTime:(NSInteger)seconds{
    if (seconds % 60 == 0) {
        return [NSString stringWithFormat:@"%d%@", (int)seconds/60, LocalString(@"Minutes")];
    }else{
        return [NSString stringWithFormat:@"%d%@", (int)seconds, LocalString(@"Seconds")];
    }
}

- (NSString *)regularPeriodNumber{
    NSInteger number = [self.rule regularPeriodNumber];
    return [NSString stringWithFormat:@"%d%@", (int)number, LocalString(@"Period")];
}
 
- (NSString *)periodTimeLength{
    NSInteger length = [self.rule timeLengthForPeriod:MatchPeriodFirst];
    return [self readableTime:length];
}

- (NSString *)restTimeLength{
    NSInteger length = [self.rule restTimeLengthAfterPeriod:MatchPeriodFirst];
    return [self readableTime:length];
}

- (NSString *)restTimeLengthForHalftime{
    NSInteger length = [self.rule restTimeLengthAfterPeriod:MatchPeriodSecond];
    return [self readableTime:length];
}

- (NSString *)overtimeLength{
    NSInteger length = [self.rule timeLengthForPeriod:MatchPeriodOvertime];
    return [self readableTime:length];
}

- (NSString *)restTimeLengthForOvertime{
    NSInteger length = [self.rule restTimeLengthAfterPeriod:MatchPeriodOvertime];
    return [self readableTime:length];
}

- (NSString *)playerFoulLimit{
    return [NSString stringWithFormat:@"%d", (int)[self.rule foulLimitForPlayer]];
}
            
- (NSString *)teamFoulLimit{
    return [NSString stringWithFormat:@"%d", (int)[self.rule foulLimitForTeam]];
}
    
- (NSString *)timeoutLimitForPeriod:(MatchPeriod)period{
    if ([self.rule isKindOfClass:[FibaRule class]]) {
        NSString * limit = [NSString stringWithFormat:@"%d%@", (int)[self.rule timeoutLimitBeforeEndOfPeriod:period], LocalString(@"Seconds")];
        return limit;
    }else if([self.rule isKindOfClass:[Fiba3pbRule class]]){
        return LocalString(@"Forbidden");
    }else{
        return nil;
    }
}

- (NSString *)timeoutLength{
    return [NSString stringWithFormat:@"%d%@", 60, LocalString(@"Seconds")];
}

- (NSString *)winningCondition{
    if ([self.rule isKindOfClass:[FibaRule class]]) {
        return LocalString(@"None");
    }else if([self.rule isKindOfClass:[Fiba3pbRule class]]){
        return [NSString stringWithFormat:LocalString(@"Get33PointsWinFormatter"), 
                [self.rule winningPoints]];
    }else{
        return nil;
    }
}
            
@end
