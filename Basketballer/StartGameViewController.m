//
//  StartGameViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StartGameViewController.h"
#import "TeamListViewController.h"
#import "TeamManager.h"
#import "PlayGameViewController.h"
#import "GameSetting.h"
#import "AppDelegate.h"
#import "Feature.h"
#import "TeamsInGameViewController.h"
#import "RuleDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ActionManager.h"
#import "MatchUnderWay.h"
#import "WellKnownSaying.h"
#import "AccountRuleDetailViewController.h"

@interface StartGameViewController () {
    NSArray * _sectionsTitle;
    Team * _hostTeam;
    Team * _guestTeam;
    NSInteger _curClickRowIndex;
    
    NSString * __weak _gameMode;
    SingleChoiceViewController * _chooseGameModeView;
    
    NSArray * _modeDetailArray;
}
@end

@implementation StartGameViewController
@synthesize inspirationView = _teamsView;
@synthesize label1 = _label1;
@synthesize label2 = _label2;
//@synthesize matchModeCell = _matchModeCell;

#pragma 私有函数

- (UIColor *)blueColor {
    UIColor * color;
    color = [UIColor colorWithRed:0.333333 green:0.608888 blue:0.9511111 alpha:1.0];
    return color;
}

- (UIColor *)greenColor {
    UIColor * color;
    color = [UIColor colorWithRed:0.142222 green:0.795555 blue:0.000000 alpha:1.0];
    return color;
}

- (UIColor *)skyBlue{
    return [UIColor colorWithRed:0.000000 green:0.388235 blue:1.000000 alpha:1.0];
}

- (UIColor *)cellDetailTextColor{
    // RGB(81, 86, 132)
    return [UIColor colorWithRed:0.317647 green:0.337254 blue:0.517647 alpha:1.0];
}

- (void)initLabel {
    _label1.shadowColor = [UIColor lightGrayColor];
    _label1.shadowOffset = CGSizeMake(1.0f, 2.0f);
    _label1.shadowBlur = 1.0f;
    _label1.innerShadowColor = [UIColor grayColor];
    _label1.innerShadowOffset = CGSizeMake(1.0f, 2.0f);
    _label1.textColor = [self blueColor];
    
    _label2.shadowColor = [UIColor lightGrayColor];
    _label2.shadowOffset = CGSizeMake(1.0f, 2.0f);
    _label2.shadowBlur = 1.0f;
    //_label2.innerShadowColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
    _label2.innerShadowColor = [UIColor grayColor];
    _label2.innerShadowOffset = CGSizeMake(1.0f, 2.0f);
    _label2.textColor = [self blueColor];

}

- (void)updateSaying:(NSDictionary *)saying{
    if (saying) {
        UILabel * wordsLabel = (UILabel *)[self.inspirationView viewWithTag:1];
        UILabel * whomLabel = (UILabel *)[self.inspirationView viewWithTag:2];
        UILabel * slash = (UILabel *)[self.inspirationView viewWithTag:3];
        
        NSString * words = [saying objectForKey:kWords];
        wordsLabel.text = words;
        
        NSString * whom = [saying objectForKey:kWhom];
        whomLabel.text = whom;
        
        wordsLabel.hidden = NO;
        whomLabel.hidden = NO;
        slash.hidden = NO;
    }
}

//- (void)newSayingComing:(NSNotification *)notification{
//    NSDictionary * saying = [[WellKnownSaying defaultSaying] lastSaying];
//    if (nil != saying) {
//        [self updateSayingWithWords:saying];
//    }
//}

#pragma 类成员函数

#pragma 事件函数
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sectionsTitle = [NSArray arrayWithObjects:@"主队", @"客队" ,@"竞技规则",nil];
    _gameMode = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:0];  
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    /*[[NSBundle mainBundle] loadNibNamed:@"Inspiration" owner:self options:nil];
    CGRect frame = self.inspirationView.frame;
    frame.size.height = 160;
    self.inspirationView.frame = frame;
    self.tableView.tableFooterView = self.inspirationView;
    
    _modeDetailArray = [NSArray arrayWithObjects:
                      @"We Are Basketball！", 
                      @"无兄弟，不篮球！", nil];*/
    self.tableView.rowHeight = 60;
    
    self.title = NSLocalizedString(@"Start", nil);
//    [[NSNotificationCenter defaultCenter] addObserver:self 
//              selector:@selector(newSayingComing:) name:kNewSayingMessage object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //NSDictionary * saying = [[WellKnownSaying defaultSaying] oneSaying];
    //[self updateSaying:saying];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[GameSetting defaultSetting] gameModes] count];    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;   
}

// 图片圆角化。
- (void)makeRoundedImage:(UIImageView *)image{
    image.layer.masksToBounds = YES;
    image.layer.cornerRadius = 5.0f;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
  
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];        
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    NSInteger index = indexPath.section;
    cell.textLabel.text = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:index];
    cell.textLabel.textColor = [self cellDetailTextColor];
//    cell.detailTextLabel.font = [UIFont systemFontOfSize:16.0]; 
//    cell.detailTextLabel.text = [_modeDetailArray objectAtIndex:index]; 
    if (indexPath.section == 0) {
        cell.imageView.image = [UIImage imageNamed:@"BasketballBlueWhite"];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"BasketballBlueRed"];        
    }
    

        
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameSetting * gs = [GameSetting defaultSetting];
    MatchUnderWay * match = [MatchUnderWay defaultMatch];
    match.matchMode = [gs.gameModes objectAtIndex:indexPath.section];
    
    TeamsInGameViewController * viewController;
    viewController = [[TeamsInGameViewController alloc] initWithNibName:@"TeamsInGameViewController" bundle:nil];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:viewController];
    [[Feature defaultFeature] setNavigationBarBackgroundImage:nav.navigationBar];
    [[AppDelegate delegate] presentModelViewController:nav];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    NSString * title = [[[GameSetting defaultSetting] gameModeNames] objectAtIndex:indexPath.section];
    NSString * mode = [[[GameSetting defaultSetting] gameModes] objectAtIndex:indexPath.section];
    UITableViewController * details;
    
    if ([mode isEqualToString:kMatchModeAccount]) {
        details = [[AccountRuleDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    }else {
        details = [[RuleDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
        ((RuleDetailViewController *)details).rule = [BaseRule ruleWithMode:mode];
    }
    details.hidesBottomBarWhenPushed = YES;
    details.title = title;
    [self.navigationController pushViewController:details animated:YES];    
    
}

@end
