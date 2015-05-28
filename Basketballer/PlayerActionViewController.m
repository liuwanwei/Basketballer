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
#import "PlayerActionCell.h"
#import <NSObject+GLPubSub.h>
#import <EXTScope.h>

static NSString * const CellIdentifier = @"PlayerActionCell";

typedef enum{
    PlayerCellTagNumber = 1,
    PlayerCellTagName = 2,
    PlayerCellTagFoul = 3,
}PlayerCellTag;

@interface PlayerActionViewController (){
}

@end

@implementation PlayerActionViewController
@synthesize actionType = _actionType;
@synthesize playerActionCell = _playerActionCell;

#pragma mark - View controller

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = [ActionManager shortDescriptionForActionType:_actionType];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlayer:)];
    self.navigationItem.rightBarButtonItem = item;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerChanged:) name:kPlayerChangedNotification object:nil];
    
    self.tableView.tableHeaderView = [self headerView];
    
    if (self.modalPresentationStyle == UIModalPresentationFormSheet) {
        UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissPresentedForm:)];
        self.navigationItem.leftBarButtonItem = item;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier ];
    
    @weakify(self);
    [self subscribe:DismissPlayerActionView handler:^(GLEvent * event){
        @strongify(self);
        [self publish:kActionDetermined data:event.data];
        
        if (self.modalPresentationStyle == UIModalPresentationFormSheet) {
            [self dismissPresentedForm:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
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
    PlayerActionCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(indexPath.row == self.players.count){
        [cell customWithActionType:_actionType andPlayer:nil];
        
    }else{
        Player * player = [self.players objectAtIndex:indexPath.row];
        [cell customWithActionType:_actionType andPlayer:player];        
    }

    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    return;
//    
//    Player * player = nil;
//    if (indexPath.row < self.players.count) {
//        // 获取球员id，在消息通知里使用。
//        player = [self.players objectAtIndex:indexPath.row];
//    }else{
//        // 选中最后一行"其他球员"，number默认值就是nil
//    }
//    
//    [self addActionForPlayer:player];
//}
//
//- (void)addActionForPlayer:(Player *)player{
//    // 这里只是选择球员，假如犯规次数已到，应该在上一个NewActionViewController界面就提示。
//    // 犯规次数达到罚球次数时，弹出罚球提示对话框，也应该在NewActionViewController中进行。
//    NSNotification * notification;
//    notification = [NSNotification notificationWithName:kActionDetermined object:player.number];
//    [[NSNotificationCenter defaultCenter] postNotification:notification];
//}



@end
