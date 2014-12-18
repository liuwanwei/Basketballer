//
//  PlayerActionViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayerActionViewController.h"
#import "NewPlayerViewController.h"
#import "AppDelegate.h"
#import "MatchUnderWay.h"

typedef enum{
    PlayerCellActionEnabled = 0,    
    PlayerCellActionUnEnabled = 1,    
}PlayerCellAction;

typedef enum{
    PlayerCellTagNumber = 1,
    PlayerCellTagName = 2,
    PlayerCellTagFoul = 3,
}PlayerCellTag;

@interface PlayerActionViewController ()

@end

@implementation PlayerActionViewController
@synthesize actionsInMatch = _actionsInMatch;
@synthesize actionType = _actionType;
@synthesize playerActionCell = _playerActionCell;

- (void)showAlertView:(NSString *)message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:LocalString(@"Alert") 
                                               message:message 
                                               delegate:self 
                                               cancelButtonTitle:LocalString(@"Ok") 
                                               otherButtonTitles:nil , nil];
    [alertView show];
}

- (NSString *)pageName {
    MatchUnderWay * match = [MatchUnderWay defaultMatch];
    NSString * pageName = @"PlayerAction_";
    pageName = [pageName stringByAppendingString:match.matchMode];
    return pageName;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = LocalString(@"SelectPlayer");
    self.tableView.rowHeight = 50.0f;
//    if (self.actionType == ActionType3Points) {
//        self.title = @"选择得分球员";
//    }else if (self.actionType == ActionTypeFoul) {
//        self.title = @"选择犯规球员";
//    }else {
//        self.title = @"选择球员";
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[self pageName]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[self pageName]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.actionType == ActionTypeFoul) {
         return LocalString(@"PlayerFoulViewHeader");
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (self.players.count + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    int fouls = 0;
    NSMutableDictionary * data;
    UILabel * numberLabel = nil;
    UILabel * foulLabel = nil;
    Player * player;
    
    NSInteger playersSize = self.players.count;
    
    //if (_actionType == ActionTypeFoul) {
        static NSString *CellIdentifier = @"PlayerActionCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"PlayerActionCell" owner:self options:nil];
            cell = _playerActionCell;
            self.playerActionCell = nil;
        }
        
        numberLabel = (UILabel *)[cell.contentView viewWithTag:PlayerCellTagNumber];
        UILabel * nameLabel = (UILabel *)[cell.contentView viewWithTag:PlayerCellTagName];
        if (playersSize > 0 && indexPath.row < playersSize) {
            player = [self.players objectAtIndex:indexPath.row];
            //号码
            numberLabel.text = [NSString stringWithFormat:@"%.2d", [player.number intValue]];
            //姓名
            nameLabel.text = player.name;
        }
    //}else {
    //    cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    //}
    
    //犯规数
    if (playersSize > 0 && indexPath.row < playersSize) {
        ActionManager * am = [ActionManager defaultManager];
        data = [am statisticsForPlayer:player.id inActions:_actionsInMatch];
        fouls = [[data objectForKey:kPersonalFouls] intValue];
        if (_actionType == ActionTypeFoul) {
            //犯规数
            foulLabel = (UILabel *)[cell.contentView viewWithTag:PlayerCellTagFoul]; 
            foulLabel.text = [NSString stringWithFormat:@"%d", fouls];
        }
    }
    
    cell.tag = PlayerCellActionEnabled;
    if ([MatchUnderWay defaultMatch].rule.foulLimitForPlayer < fouls) {
        if (_actionType == ActionTypeFoul) {
            foulLabel.textColor = [UIColor redColor];
        }else {
            nameLabel.textColor = [UIColor redColor];
        }
        cell.tag = PlayerCellActionUnEnabled;
    }
    
    if(indexPath.row == self.players.count){
        NSString * text = LocalString(@"Others...");
        numberLabel.text = text;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController * viewController = (UIViewController *)[[AppDelegate delegate] playGameViewController];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == PlayerCellActionUnEnabled) {
//        [self showAlertView:@"不能对此球员进行操作！"];
        [self showAlertView:LocalString(@"OperationForbidden")];
        return;
    }
    
    [self.navigationController popToViewController:viewController animated:YES];
    
    NSNumber * number = nil;
    if (indexPath.row < self.players.count) {
        // 获取球员id，在消息通知里使用。
        Player * player = [self.players objectAtIndex:indexPath.row];
        number = player.id;
    }else{/*选中最后一行"其他球员"，number默认值就是nil*/}
    
    // 这里只是选择球员，假如犯规次数已到，应该在上一个NewActionViewController界面就提示。
    // 犯规次数达到罚球次数时，弹出罚球提示对话框，也应该在NewActionViewController中进行。
    NSNotification * notification;
    notification = [NSNotification notificationWithName:kActionDetermined object:number];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
