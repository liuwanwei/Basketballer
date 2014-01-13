//
//  MatchFinishedDetailsViewController.m
//  Basketballer
//
//  Created by maoyu on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MatchFinishedDetailsViewController.h"
#import "Feature.h"
#import "AppDelegate.h"
#import "PlayGameViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MatchFinishedDetailsViewController ()

@end

@implementation MatchFinishedDetailsViewController

- (void)back {
    [[AppDelegate delegate].playGameViewController dismissModalViewControllerAnimated:NO];
    [[AppDelegate delegate].playGameViewController dismissView];
}

- (void)initUIButton {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 54)];
    UIButton * button;
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.frame = CGRectMake(10, 15, 300, 44);
    [button setTitle:LocalString(@"Done") forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    [button setBackgroundImage:[UIImage imageNamed:@"TabBarBg"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    self.tableView.tableFooterView = view;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title= LocalString(@"Result");
    [self initUIButton];
    [[Feature defaultFeature] initNavleftBarItemWithController:self withAction:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
