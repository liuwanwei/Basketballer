//
//  PlayGameViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayGameViewController.h"
#import "OperateGameView.h"
#import "GameSetting.h"
#import "MatchManager.h"
#import "TimeoutPromptView.h"
#import "ActionRecordViewController.h"
#import "AppDelegate.h"
#import "TimeStopPromptView.h"
#import "StartMatchView.h"
#import "NewActionViewController.h"
#import "MatchSettingViewController.h"
#import "SoundManager.h"
#import "BaseRule.h"
#import "PlayerFoulStatisticViewController.h"
#import "PlayerManager.h"
#import "TeamManager.h"
#import "PlaySoundView.h"
#import "MatchFinishedDetailsViewController.h"
#import "Feature.h"
#import "PlaySoundViewController.h"
#import <QuartzCore/QuartzCore.h>

typedef enum {
    AlertViewTagMatchFinish = 0,
    AlertViewTagMatchTimeout = 1,
    AlertViewTagMatchNormal = 2
}AlertViewTag;

@interface PlayGameViewController() {
    ActionManager * _actionManager;
    MatchUnderWay * _match;
    NewActionViewController * _actionViewController;
    TimeoutPromptView * _timeoutPromptView;
    PlaySoundView * _playSoundView;
    
    NSArray * _actionSheetButtonTitlesForRelease;
    NSArray * _actionSheetButtonTitlesForDebug;
    NSArray * __weak _actionSheetButtonTitles;
}
@end

@implementation PlayGameViewController

@synthesize operateGameView1 = _operateGameView1;
@synthesize operateGameView2 = _operateGameView2;
@synthesize backgroundView = _backgroundView;
@synthesize gameTimeLabel = _gameTimeLabel;
@synthesize gamePeroidLabel = _gamePeroidLabel;
@synthesize gameHostScoreLable = _gameHostScoreLable;
@synthesize gameGuestScoreLable = _gameGuestScoreLable;
@synthesize timeCountDownTimer = _timeCountDownTimer;
@synthesize hostTeam = _hostTeam;
@synthesize guestTeam = _guestTeam;
@synthesize testSwitch = _testSwitch;
@synthesize selectedStatistics = _selectedStatistics;
@synthesize promptView = _promptView;
@synthesize gameStart = _gameStart;
@synthesize gamePeroidButton = _gamePeroidButton;

#pragma 私有函数
- (void)showAlertViewWithTitle:(NSString *) title withMessage:(NSString *)message withCancel:(BOOL)cancel withAlertViewTag:(NSInteger)alertViewTag{
    UIAlertView * alertView;
    if(cancel == YES) {
        NSString *otherButtonTitle;
        if (alertViewTag == AlertViewTagMatchFinish) {
            otherButtonTitle = LocalString(@"Save");
        }else {
            otherButtonTitle = LocalString(@"Yes");
        }
        alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:LocalString(@"No") otherButtonTitles:otherButtonTitle , nil];
    }else {
        alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:LocalString(@"Ok") , nil];
        
    }
    alertView.tag = alertViewTag;
    [alertView show];
}

- (void)showPropmtView:(BOOL)show {
    [self.promptView setHidden:!show];
}

- (void)initActionSheetButtonTitles {
    _actionSheetButtonTitlesForRelease = [NSArray arrayWithObjects:
                                          LocalString(@"AbandonGame"),
                                          LocalString(@"Cancel"),nil];
    _actionSheetButtonTitlesForDebug = [NSArray arrayWithObjects:
                                        LocalString(@"AbandonGame"),
                                        LocalString(@"Cancel"),@"结束本节",nil];
    if (_testSwitch == YES) {
        _actionSheetButtonTitles = _actionSheetButtonTitlesForDebug;
    }else {
        _actionSheetButtonTitles = _actionSheetButtonTitlesForRelease;
    }
    
}

- (void)showNewActionViewForTeam:(Team *)team withTeamStatistics:(TeamStatistics *)statistics {
    if (_actionViewController == nil) {
        _actionViewController = [[NewActionViewController alloc] initWithStyle:UITableViewStyleGrouped];
    }
    
    _actionViewController.team = team;
    _actionViewController.statistics = statistics;
    self.selectedStatistics = statistics;
    [self.navigationController pushViewController:_actionViewController animated:YES];
}

- (void)showPlayerFoulStatisticViewControllerForTeam:(Team *)team {
  
    PlayerFoulStatisticViewController * playerFoulStatisticViewController = [[PlayerFoulStatisticViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [playerFoulStatisticViewController initWithTeamId:team.id];
    playerFoulStatisticViewController.actionsInMatch = [[ActionManager defaultManager] actionsForMatch:[_match.match.id integerValue]];
    [self.navigationController pushViewController:playerFoulStatisticViewController animated:YES];
}

- (void)pauseCountdownTime {
    _match.state = MatchStateTimeoutTemp;
    [_timeoutPromptView updateLayout];
    [self makeUpperBoardDimmer];
    [self stopTimeCountDown];
    [self updateTitle:LocalString(@"Pausing")];
}

- (void)updateTitle:(NSString *) title {
    //[self setTitle:title];
    [self setTitle:LocalString(@"PlayGameViewTitle")];
}

- (void)resetCountdownTime:(MatchPeriod) period{
    _match.countdownSeconds = [_match.rule timeLengthForPeriod:period];
}

/*消息处理函数*/
- (void)handleMessage:(NSNotification *)note {
    if(_match.state == MatchStatePlaying || _match.state == MatchStateTimeoutTemp){
        [self stopTimeCountDown];
        _match.state = MatchStateTimeout;
        [self showTimeoutPromptView:PromptModeTimeout];
        [self updateTitle:LocalString(@"TimeoutState")];
        
        [_timeoutPromptView updateLayout];
        [self makeUpperBoardDimmer];
    }
}

/*消息处理函数*/
- (void)handleTimeoutOverMessage:(NSNotification *)note {    
    if (_match.state == MatchStateTimeout) {
        _match.state = MatchStateTimeoutFinished;
    }else if (_match.state == MatchStateQuarterTime){
        _match.state = MatchStateQuarterTimeFinished;
        if (_match.period == _match.rule.regularPeriodNumber - 1) {
            _match.period = MatchPeriodOvertime;
        }else {
            _match.period ++; 
        }
        [self resetCountdownTime:_match.period];
        [self updateTimeCountDownLable];
        [self initTimeoutAndFoulView];
        [self updatePeriodLabel];
    }
    
    [_timeoutPromptView updateLayout];
    [[SoundManager defaultManager] playSound];
    [self updateTitle:LocalString(@"ResumeTimer")];
}

/*消息处理函数*/
- (void)handleAddScoreMessage:(NSNotification *)note {
    NSNumber * hostPoints = _match.home.points;
    NSNumber * guestPoints = _match.guest.points;
    self.gameHostScoreLable.text = [hostPoints stringValue];
    self.gameGuestScoreLable.text = [guestPoints stringValue];    
}

/*消息处理函数*/
- (void)handleDeleteActionMessage:(NSNotification *)note {
    [_operateGameView1 refreshMatchData];
    [_operateGameView2 refreshMatchData];
    NSNumber * hostPoints = _match.home.points;
    NSNumber * guestPoints = _match.guest.points;
    self.gameHostScoreLable.text = [hostPoints stringValue];
    self.gameGuestScoreLable.text = [guestPoints stringValue];

}

- (void)makeUpperBoardDimmer{
    self.backgroundView.alpha = 0.6;
}

- (void)makeUpperBoardNormal{
    self.backgroundView.alpha = 0.8;
}

/*初始化暂停、犯规显示数据。
 用途：当本节比赛结束时调用。*/
- (void)initTimeoutAndFoulView {
    [_operateGameView1 initTimeoutAndFoulView];
    [_operateGameView2 initTimeoutAndFoulView];
}

/*显示菜单项*/
- (void)showMenu {
    UIActionSheet * menu;
    if (_testSwitch == YES) {
        menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[_actionSheetButtonTitles objectAtIndex:1] destructiveButtonTitle:[_actionSheetButtonTitles objectAtIndex:0]  otherButtonTitles:[_actionSheetButtonTitles objectAtIndex:2] , nil];
    }else {
        menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[_actionSheetButtonTitles objectAtIndex:1] destructiveButtonTitle:[_actionSheetButtonTitles objectAtIndex:0]  otherButtonTitles:nil, nil];
    }

    [menu showInView:self.view];
}

- (void)enterSettingView{
    [self showGameSettingController];
}

/*根据条件显示导航上的item*/
- (void)showNavBarLeftItem:(BOOL)left withRightItem:(BOOL)right{
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * item;
   /*item = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"Finish")
                            style:UIBarButtonItemStyleBordered target:self action:@selector(showMenu)];
//    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleDone target:self action:@selector(showMenu)];
    self.navigationItem.leftBarButtonItem = item;*/
    
    // TODO 用齿轮或扳手图片代替。
    item = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"Setting")
                        style:UIBarButtonItemStyleBordered target:self action:@selector(enterSettingView)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)updateTimeCountDownLable{
    NSInteger timeLeftSeconds = _match.countdownSeconds;
    NSInteger minutesLeft = timeLeftSeconds / 60;
    NSInteger secondsLeft = timeLeftSeconds % 60;
    NSString * timeLeftString = [NSString stringWithFormat:@"%.2d : %.2d",minutesLeft, secondsLeft];
    self.gameTimeLabel.text = timeLeftString;
}

- (void)updatePeriodLabel {
    self.gamePeroidLabel.text = [_match nameForCurrentPeriod];
}

- (NSString *)titleForEndOfPeriod:(MatchPeriod)period{
    NSString * result = nil;
    switch (period) {
        case MatchPeriodFirst:
            result = LocalString(@"Period1End");
            break;
        case MatchPeriodSecond:
            result = LocalString(@"Period2End");
            break;
        case MatchPeriodThird:
            result = LocalString(@"Period3End");
            break;
        case MatchPeriodFourth:
            result = LocalString(@"Period4End");
            break;
        case MatchPeriodOvertime:
            result = LocalString(@"OvertimeEnd");
            break;
        default:
            break;
    }
    return result;
}

/*
 定时器执行函数：比赛倒计时时间。
 1秒刷新下时间，当倒计时为0时，结束本节或整场的比赛
 */
- (void)updateTimeCountDown {
    [self updateTimeCountDownLable];
    
    if(_match.countdownSeconds <= 0) {
        [self stopTimeCountDown];
        [[SoundManager defaultManager] playSound];
        if ([_match.rule isGameOver] == NO) {
            [self showTimeoutPromptView:PromptModeRest];
            _match.state = MatchStatePeriodFinished;
            [_timeoutPromptView updateLayout];
            [self updateTitle:LocalString(@"Countdown")];
            NSString * title;
            title =  LocalString(@"StartCountdown");            
            // 节间休息倒计时。
            NSString * message = [self titleForEndOfPeriod:_match.period]; 
            [self showAlertViewWithTitle:title withMessage:message withCancel:YES withAlertViewTag:AlertViewTagMatchTimeout];
        }else {
            [self updateTitle:LocalString(@"Finish")];
            _match.state = MatchStateFinished;
            [self stopGame:MatchStateFinished withWinTeam:nil];
        }
    }
    
    _match.countdownSeconds --;
}

- (void)startTimeCountDown {
    self.timeCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeCountDown) userInfo:nil repeats:YES];
}

- (void)stopTimeCountDown {
    [self.timeCountDownTimer invalidate];
}

- (void)dismissView{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:_operateGameView1];
    [[NSNotificationCenter defaultCenter] removeObserver:_operateGameView2];
    
    self.hidesBottomBarWhenPushed = NO;   
    self.navigationController.navigationBarHidden = NO;
    [AppDelegate delegate].playGameViewController = nil;
    [[AppDelegate delegate] dismissModelViewController];
    [LocationManager defaultManager].delegate = nil;
}

- (void)stopGame:(NSInteger)mode withWinTeam:(NSNumber *)teamId{
    if (_gameStart == NO) {
        [self dismissView];
        return;
    }
    
    _gameStart = NO;
    [self stopTimeCountDown];
    [_timeoutPromptView stopTimeoutCountdown];
    [_match stopMatchWithState:mode];
    
    if (mode == MatchStateFinished) {
        [self showMatchFinishedDetailsController];
    }else {
        [_match deleteMatch];
        [self dismissView];
        /*NSString * message = LocalString(@"SaveMatchPrompt");
        [self showAlertViewWithTitle:LocalString(@"AbandonGame") withMessage:message withCancel:YES withAlertViewTag:AlertViewTagMatchFinish];*/
    }
}

/*
 显示暂停或比赛单节/半场休息提示VIEW
 */
- (void)showTimeoutPromptView:(NSInteger) mode {
    if (_timeoutPromptView == nil) {
         _timeoutPromptView = [[TimeoutPromptView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 65.0)];
    }
    _timeoutPromptView.mode = mode;
    [_timeoutPromptView updateLayout];
    [self.view addSubview:_timeoutPromptView];
    if (mode == PromptModeTimeout) {
        [_timeoutPromptView startTimeoutCountdown];
        [[SoundManager defaultManager] playSound];
    }
    
    [self makeUpperBoardDimmer];
}

/*显示开始计时View。
 比赛开始前显示一次。*/
- (void)showStartMatchView {
    StartMatchView * startMatchView = [[StartMatchView alloc] initWithFrame:CGRectMake(0.0, 395.0, 320.0, 65.0)];
    startMatchView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:startMatchView];
    startMatchView.alpha = 0.8;
}

- (void)initOperateGameView {
    self.operateGameView1 = [[OperateGameView alloc] initWithFrame:CGRectMake(5.0,
        85.0f, 310.0f, 85.0f)];
    [self.operateGameView1 initContentWithTeam:_hostTeam];
    [self.view addSubview:self.operateGameView1];
    
    self.operateGameView2 =  [[OperateGameView alloc] initWithFrame:CGRectMake(5.0,205.0f, 310.0f, 85.0f)];
    [self.operateGameView2 initContentWithTeam:_guestTeam];
    
    if ([_match.matchMode isEqualToString:kMatchModeAccount]) {
        [self.operateGameView1 hideFoulsAndTimeoutView];
        [self.operateGameView2 hideFoulsAndTimeoutView];
    }
    [self.view addSubview:self.operateGameView2];
}

- (void)showPlaySoundView {
    [UIView animateWithDuration:0.5f animations:^{
        [self.view bringSubviewToFront:_playSoundView];
        _playSoundView.frame = CGRectMake(0.0, 20.0, 320.0, 460.0);
        _playSoundView.alpha = 0.8;
    }];
}

- (void)initPlaySoundView {
    _playSoundView = [[PlaySoundView alloc] initWithFrame:CGRectMake(0.0, 480.0, 320.0, 460.0)];
    _playSoundView.backgroundColor = [UIColor blackColor];
    _playSoundView.alpha = 0.0;
    [[UIApplication sharedApplication].keyWindow addSubview:_playSoundView];
}

- (IBAction)showPlaySoundController:(id)sender {
    PlaySoundViewController * playSoundViewController = [[PlaySoundViewController alloc] initWithNibName:@"PlaySoundViewController" bundle:nil];
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:playSoundViewController];
    [[Feature defaultFeature] customNavigationBar:nav.navigationBar];
    [self presentModalViewController:nav animated:YES];
}

/*
 注册消息处理函数
 */
- (void)registerHandleMessage {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessage:) name:kAddTimeoutMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTimeoutOverMessage:) name:kTimeoutOverMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddScoreMessage:) name:kAddScoreMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeleteActionMessage:) name:kDeleteActionMessage object:nil];
}

- (void)showActionRecordontroller {
    ActionRecordViewController * actionRecordontroller = [[ActionRecordViewController alloc] initWithNibName:@"ActionRecordViewController" bundle:nil];
    [self.navigationController pushViewController:actionRecordontroller animated:YES];
}

/*显示比赛设置界面:非编辑状态*/
- (void)showGameSettingController {
    self.navigationController.navigationBarHidden = NO;

    MatchSettingViewController * controller = [[MatchSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)swip:(UISwipeGestureRecognizer *)swip {
    if (_gameStart == YES) {
        [self showActionRecordontroller];
    }
}

- (void)addSwipeGesture {
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(swip:)];
    swip.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swip];
}

// 显示比赛结束详情界面
- (void)showMatchFinishedDetailsController {
    MatchFinishedDetailsViewController * controller = [[MatchFinishedDetailsViewController alloc] initWithNibName:@"GameDetailsViewController" bundle:nil];
    
    controller.match = _match.match;
    [controller reloadActionsInMatch];
    
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [[Feature defaultFeature] customNavigationBar:nav.navigationBar];
    
    [self presentModalViewController:nav animated:YES];
}

/*类成员函数*/
- (void)initWithHostTeam:(Team *)hostTeam andGuestTeam:(Team *)guestTeam {
    _match = [MatchUnderWay defaultMatch];
    _match.delegate = self;
    
    self.hostTeam = hostTeam;
    self.guestTeam = guestTeam;
    [_match initMatchDataWithHomeTeam:hostTeam.id andGuestTeam:guestTeam.id];
}

#pragma 事件函数
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
    _testSwitch = NO;
    [self showPropmtView:NO];

    //TODO if else 判断的办法比较笨，可以建一个的基类，让两个界面继承自基类，各自做自己的事情
    if (![_match.matchMode isEqualToString:kMatchModeAccount]) {
        [self showTimeoutPromptView:PromptModeNormal];
        [self resetCountdownTime:MatchPeriodFirst];
        [self updateTimeCountDownLable];
        [self updatePeriodLabel];
        [self makeUpperBoardDimmer];
        [_gamePeroidButton setHidden:YES];
    }else {
        [_gameTimeLabel setHidden:YES];
        [_gamePeroidLabel setHidden:YES];
        [self startGame:nil];
    }
    
    [self registerHandleMessage];
    [self updateTitle:LocalString(@"Match")];
    [self initOperateGameView];
    [self addSwipeGesture];
    [self showNavBarLeftItem:YES withRightItem:NO];
    
    if (IOS_7) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
        
    [LocationManager defaultManager].delegate = self;
    [AppDelegate delegate].playGameViewController = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.operateGameView1 = nil;
    self.operateGameView2 = nil;
    self.gameTimeLabel = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)startGame:(id)sender {
    if(_gameStart == NO) {
        [_match startNewMatch];
        _operateGameView1.statistics = _match.home;
        _operateGameView2.statistics = _match.guest;
                
        _gameStart = YES;
        _match.period ++;
        [self.operateGameView1 setButtonEnabled:YES];
        [self.operateGameView2 setButtonEnabled:YES];
        //[[LocationManager defaultManager] startStandardLocationServcie];
        [self showPropmtView:YES];
    }
    
    _match.state = MatchStatePlaying;
    if (![_match.matchMode isEqualToString:kMatchModeAccount]) {
        [self startTimeCountDown];
        [_timeoutPromptView updateLayout];
    }
    
    [self updateTitle:LocalString(@"Playing")];
    [self makeUpperBoardNormal];
    [[SoundManager defaultManager] playMatchStartSound];
}

- (IBAction)showActionRecordController:(id)sender {
    [self swip:nil];
}

- (IBAction)changePeriod:(UIButton *)sender {
    _match.period = _match.period == MatchPeriodFourth ? MatchPeriodFirst : _match.period % _match.rule.regularPeriodNumber + 1;
   
    [_gamePeroidButton setTitle:[_match nameForCurrentPeriod] forState:UIControlStateNormal];
}

#pragma alert delete
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AlertViewTagMatchFinish) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [_match deleteMatch];
        }
        
        [self dismissView];
    }else if (alertView.tag == AlertViewTagMatchTimeout){
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            _match.state = MatchStateQuarterTime;
            [_timeoutPromptView updateLayout];
            [_timeoutPromptView startTimeoutCountdown];
        }
    }
}

#pragma mark - ActionSheet view delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self stopGame:MatchStateStopped withWinTeam:nil];
    }else if (buttonIndex == actionSheet.firstOtherButtonIndex){
        _match.countdownSeconds = 4;;
    }
}

#pragma FoulActionDelegate
- (void)FoulsBeyondLimitForTeam:(NSNumber *)teamId {
    [self showAlertViewWithTitle:LocalString(@"Alert") 
                    withMessage:LocalString(@"TeamFoulExceedPrompt") 
                    withCancel:NO withAlertViewTag:AlertViewTagMatchNormal];
}

- (void)FoulsBeyondLimitForPlayer:(NSNumber *)playerId {
    Player * player = [[PlayerManager defaultManager] playerWithId:playerId];
    NSString * message = [NSString stringWithFormat:LocalString(@"PlayerFoulExceedPrompt"), 
                          [player.number integerValue],player.name];
    [self showAlertViewWithTitle:LocalString(@"Alert") withMessage:message withCancel:NO withAlertViewTag:AlertViewTagMatchNormal];
}

- (void)attainWinningPointsForTeam:(NSNumber *)teamId {
    [[SoundManager defaultManager] playSound];
    [self stopGame:MatchStateFinished withWinTeam:teamId];
}

#pragma LocationManager delete
- (void)receivedLocation:(NSDictionary *) locations {
    if (_match.match != nil) {
        CLLocation * location = [locations objectForKey:@"location"];
        NSArray * placemarks = [locations objectForKey:@"placemarks"];
        CLPlacemark * placemark = [placemarks objectAtIndex:0];
        _match.match.latitude = [NSNumber numberWithDouble:[location coordinate].latitude];
        _match.match.longitude = [NSNumber numberWithDouble:[location coordinate].longitude];
        NSString * address = placemark.locality;
        address = [address stringByAppendingString:@" "];
        if (placemark.subLocality != nil && [placemark.subLocality length] > 0) {
            address = [address stringByAppendingString:placemark.subLocality];
            address = [address stringByAppendingString:@" "];
        }
        
        if (placemark.thoroughfare != nil && [placemark.thoroughfare length] > 0) {
            address = [address stringByAppendingString:placemark.thoroughfare];
        }
                
        _match.match.court =  address;
    }
}
@end
