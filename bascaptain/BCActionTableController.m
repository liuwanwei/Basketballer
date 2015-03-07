//
//  BDActionTableController.m
//  比赛界面中的技术统计项展示
//
//  Created by sungeo on 15/3/6.
//
//

#import "BCActionTableController.h"
#import "BCMultiActionView.h"
#import "PlayerActionViewController.h"
#import "ActionManager.h"
#import <Masonry.h>

// 每行对应的序号
typedef enum {
    BCActionIndexOnePoints = 0,
    BCActionIndexTwoPoints,
    BCActionIndexThreePoints,
    BCActionIndexRebounds,
    BCActionIndexAssists,
    BCActionIndexSteals,
    BCActionIndexMisses,
    BCActionIndexFouls,
}BCActionIndex;

@interface BCActionTableController()
@property (nonatomic, strong) NSArray * rowDescriptions;
@property (nonatomic, strong) NSArray * actionTypes;
@end

@implementation BCActionTableController

- (id)init{
    if (self = [super init]) {
        self.rowDescriptions = @[@[@"罚球", @(YES), @"得分", @"未进"],
                             @[@"两分", @(YES), @"得分", @"未进"],
                             @[@"三分", @(YES), @"得分", @"未进"],
                             @[@"篮板", @(YES), @"后场", @"前场"],
                             @[@"助攻", @(NO)],
                             @[@"抢断", @(NO)],
                             @[@"失误", @(NO)],
                             @[@"犯规", @(NO)],
                             ];
        self.actionTypes = @[@[@(ActionType1Point), @(ActionType1PointMissed)],
                             @[@(ActionType2Points), @(ActionType2PointMissed)],
                             @[@(ActionType3Points), @(ActionType3PointMissed)],
                             @[@(ActionTypeReboundBackField), @(ActionTypeReboundForeField)],
                             @[@(ActionTypeAssist)],
                             @[@(ActionTypeSteal)],
                             @[@(ActionTypeMiss)],
                             @[@(ActionTypeFoul)]
                             ];
    }
    
    return self;
}

- (void)setTableView:(UITableView *)tableView{
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}

#pragma mark Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = nil;
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.textLabel.text = self.rowDescriptions[indexPath.row][0];
    
    if ([self.rowDescriptions[indexPath.row][1] boolValue]) {
        // 需要增加右侧双控按钮
        BCMultiActionView * view = [[BCMultiActionView alloc] initInView:cell.contentView];
        [view setLeftText:self.rowDescriptions[indexPath.row][2] rightText:self.rowDescriptions[indexPath.row][3]];
        
        [view.buttonLeft addTarget:self action:@selector(leftItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        view.buttonLeft.tag = [self.actionTypes[indexPath.row][0] integerValue];
        [view.buttonRight addTarget:self action:@selector(rightItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        view.buttonRight.tag = [self.actionTypes[indexPath.row][1] integerValue];
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)leftItemClicked:(id)sender{
    NSInteger tag = ((UIButton *)sender).tag;
    NSLog(@"left: %d", (int)tag);
    [self addAction:@(tag)];
}

- (void)rightItemClicked:(id)sender{
    NSInteger tag = ((UIButton *)sender).tag;
    NSLog(@"right: %d", (int)tag);
    [self addAction:@(tag)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self.rowDescriptions[indexPath.row][1] boolValue]) {
        NSNumber * actionType = self.actionTypes[indexPath.row][0];
        [self addAction:actionType];
    }
}

- (void)addAction:(NSNumber *)actionType{
    PlayerActionViewController * vc = [[PlayerActionViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.superViewController.navigationController pushViewController:vc animated:YES];
}

@end
