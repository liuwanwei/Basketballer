//
//  OperateGameViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OperateGameViewController.h"
#import "EditTeamInfoViewController.h"
#import "AppDelegate.h"
#import "define.h"

@implementation OperateGameViewController

@synthesize teamType = _teamType;
@synthesize teamImageView = teamImageView;
@synthesize teamNameLabel = _teamNameLabel;
@synthesize scoreLabel = _scoreLabel;
@synthesize timeoutLabel = _timeoutLabel;
@synthesize foulLabel = _foulLabel;

#pragma 私有函数
/*初始化球队图片*/
- (void)initTeamImage {
    if(self.teamType == host) {
        self.teamImageView.image = [UIImage imageNamed:@"host_basketball"];
    }else {
        self.teamImageView.image = [UIImage imageNamed:@"guest_basketball"];
    }
}

/*初始化球队名称*/
- (void)initTeamName {
    if(self.teamType == host) {
        self.teamNameLabel.text = @"主队";
    }else {
        self.teamNameLabel.text = @"客队";
    }
}

#pragma 类成员函数
/*
 设置button可用状态
 比赛开始前、暂停中button不可用
 比赛进行中可用
 注：设置球队按钮除外
 */
- (void)setButtonEnabled:(BOOL) enabled {
    NSInteger size = self.view.subviews.count;
    for (NSInteger index = 0; index < size; index++) {
        if([[self.view.subviews objectAtIndex:index] isKindOfClass:[UIButton class]]) {
            if([[self.view.subviews objectAtIndex:index] tag] != 10) {
                [[self.view.subviews objectAtIndex:index] setEnabled:enabled];
            }
        }
    }
}

#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTeamImage];
    [self initTeamName];
    [self setButtonEnabled:NO];
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

- (IBAction)editTeamInfo:(id)sender {
    EditTeamInfoViewController * editTeamInfoViewController = [[EditTeamInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [[AppDelegate delegate].navigationController pushViewController:editTeamInfoViewController animated:YES];
}

- (IBAction)addScore:(id)sender {
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",[self.scoreLabel.text intValue] + [sender tag]];
}

- (IBAction)addTimeOver:(id)sender {
    self.timeoutLabel.text = [NSString stringWithFormat:@"%d",[self.timeoutLabel.text intValue] + 1];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTimeoutMessage object:nil];
}

- (IBAction)addFoul:(id)sender {
    self.foulLabel.text = [NSString stringWithFormat:@"%d",[self.foulLabel.text intValue] + 1];
}

@end
