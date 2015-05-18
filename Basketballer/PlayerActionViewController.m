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

@interface PlayerActionViewController (){
    NSArray * _actionsInMatch;
}

@end

@implementation PlayerActionViewController
@synthesize actionType = _actionType;
@synthesize playerActionCell = _playerActionCell;

#pragma mark - View controller

- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlayer:)];
    self.navigationItem.rightBarButtonItem = item;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerChanged:) name:kPlayerChangedNotification object:nil];
    
    self.tableView.tableHeaderView = [self headerView];
    
    _actionsInMatch = [ActionManager defaultManager].actionArray;
    
    if (self.modalPresentationStyle == UIModalPresentationFormSheet) {
        UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissPresentedForm:)];
        self.navigationItem.leftBarButtonItem = item;
    }
}

- (void)dismissPresentedForm:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addPlayer:(id)sender{
    NewPlayerViewController * vc = [[NewPlayerViewController alloc] initWithNibName:@"NewPlayerViewController" bundle:nil];
    vc.team = self.teamId;
    vc.title = LocalString(@"NewPlayer");
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)playerChanged:(NSNotification *)note{
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[self pageName]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[self pageName]];
}

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

- (UIView *)headerView{
    const CGFloat ViewHeight = 30;
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, ViewHeight)];
    view.backgroundColor = [UIColor clearColor];
    
    const CGFloat LeftMargin = 16;
    const CGFloat TopMargin = 5;
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(LeftMargin, TopMargin, self.view.bounds.size.width - LeftMargin * 2, ViewHeight - TopMargin * 2)];
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:14.0f];
    label.text = @"点击右上角加号快速添加队员";
    [view addSubview:label];
    
    UIView * bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, ViewHeight - 1, self.view.bounds.size.width, 1.0)];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    bottomLine.alpha = 0.2;
    [view addSubview:bottomLine];
    
    return view;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (self.players.count + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    
    static NSString *CellIdentifier = @"PlayerActionCell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PlayerActionCell" owner:self options:nil];
        cell = _playerActionCell;
        self.playerActionCell = nil;
    }
    
    UILabel * numberLabel = (UILabel *)[cell.contentView viewWithTag:PlayerCellTagNumber];;
    UILabel * nameLabel = (UILabel *)[cell.contentView viewWithTag:PlayerCellTagName];
    UILabel * foulLabel = (UILabel *)[cell.contentView viewWithTag:PlayerCellTagFoul];
    
    if(indexPath.row == self.players.count){
        numberLabel.text = LocalString(@"xx");
        nameLabel.text = @"其他队员";
        foulLabel.text = nil;
        
    }else{
        Player * player = [self.players objectAtIndex:indexPath.row];
        numberLabel.text = [player.number stringValue];
        nameLabel.text = player.name;
        
        // 设置该球员犯规数
        if (_actionType == ActionTypeFoul) {
            ActionManager * am = [ActionManager defaultManager];
            Statistics * data = [am statisticsForPlayer:player.id inActions:_actionsInMatch];
            NSInteger fouls = data.fouls;
            foulLabel.text = [NSString stringWithFormat:@"犯规：%d", (int)fouls];
            
            if ([MatchUnderWay defaultMatch].rule.foulLimitForPlayer < fouls) {
                // 球员超出犯规次数，理应被罚出场，名字显示红色
                nameLabel.textColor = [UIColor redColor];
                
                // 球员超出犯规次数，犯规数显示红色
                if (_actionType == ActionTypeFoul) {
                    foulLabel.textColor = [UIColor redColor];
                }
                
                // 设置不允许添加技术统计标识
                cell.tag = PlayerCellActionUnEnabled;
                
            }else{
                cell.tag = PlayerCellActionEnabled;
            }
        }else{
            foulLabel.text = nil;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == PlayerCellActionUnEnabled) {
        [self showAlertView:LocalString(@"OperationForbidden")];
        return;
    }
    
    NSNumber * number = nil;
    if (indexPath.row < self.players.count) {
        // 获取球员id，在消息通知里使用。
        Player * player = [self.players objectAtIndex:indexPath.row];
        number = player.id;
    }else{
        // 选中最后一行"其他球员"，number默认值就是nil
    }
    
    // 这里只是选择球员，假如犯规次数已到，应该在上一个NewActionViewController界面就提示。
    // 犯规次数达到罚球次数时，弹出罚球提示对话框，也应该在NewActionViewController中进行。
    NSNotification * notification;
    notification = [NSNotification notificationWithName:kActionDetermined object:number];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    if (self.modalPresentationStyle == UIModalPresentationFormSheet) {
        [self dismissPresentedForm:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
