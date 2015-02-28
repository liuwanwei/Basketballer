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
//    [[AppDelegate delegate].playGameViewController dismissViewControllerAnimated:NO completion:nil];
//    [[AppDelegate delegate].playGameViewController dismissView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initDoneButton {
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title= LocalString(@"Result");
    [self initDoneButton];
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
