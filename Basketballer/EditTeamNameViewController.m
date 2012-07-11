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
    self.title = @"球队名称";
    [self.teamNameText becomeFirstResponder];
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
