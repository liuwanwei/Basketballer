//
//  EditTeamNameViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EditTeamNameViewController.h"
#import "EditTeamInfoViewController.h"

@interface EditTeamNameViewController ()

@end

@implementation EditTeamNameViewController

@synthesize parentController = _parentController;
@synthesize teamNameText = _teamNameText;
@synthesize teamName = _teamName;

#pragma 私有函数
- (void)initTeamNameText {
    self.teamNameText.text = self.teamName;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"球队名称";
    [self initTeamNameText];
    [self.teamNameText becomeFirstResponder];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSString * teamName = self.teamNameText.text;
    teamName = [teamName stringByTrimmingCharactersInSet: 
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.parentController) {
        [self.parentController refreshViewWithTeamName:teamName]; 
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
