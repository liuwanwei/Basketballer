//
//  EditTeamNameViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TeamNameViewController.h"
#import "TeamInfoViewController.h"
#import "Feature.h"
#import "AppDelegate.h"

@interface TeamNameViewController ()

@end

@implementation TeamNameViewController

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
    self.title = LocalString(@"TeamName");
    CGRect frame = self.teamNameText.frame;
    frame.size.height += 10;
    self.teamNameText.frame = frame;
    self.teamNameText.font = [UIFont systemFontOfSize:17.0f];
    
    [[Feature defaultFeature] initNavleftBarItemWithController:self];
    
    [self initTeamNameText];
    [self.teamNameText becomeFirstResponder];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    NSString * teamName = self.teamNameText.text;
//    teamName = [teamName stringByTrimmingCharactersInSet: 
//                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if (self.parentController) {
//        [self.parentController refreshViewWithTeamName:teamName]; 
//    }
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
