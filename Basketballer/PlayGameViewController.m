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
#import "GameSettingFormViewController.h"
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
#import "PlayerActionViewController.h"
#import "MobClick.h"
#import "ImageManager.h"
#import "UIImageView+Additional.h"
#import <MBProgressHUD.h>

typedef enum {
    AlertViewTagMatchFinish = 0,
    AlertViewTagMatchTimeout = 1,
    AlertViewTagMatchNormal = 2,
    AlertViewTagMatchBegin = 3,
}AlertViewTag;

#define kTeamTag    100

@interface PlayGameViewController() {
    ActionManager * _actionManager;
    MatchUnderWay * _match;
//    NewActionViewController * _actionViewController;
    TimeoutPromptView * _timeoutPromptView;
    
//    NSNumber * _selectTeamId;
    Team * _selectedTeam;
    ActionType _selectActionType;
}
@end

@implementation PlayGameViewController

@synthesize gameTimeLabel = _gameTimeLabel;
@synthesize gamePeroidLabel = _gamePeroidLabel;
@synthesize gameHostScoreLable = _gameHostScoreLable;
@synthesize gameGuestScoreLable = _gameGuestScoreLable;
@synthesize timeCountDownTimer = _timeCountDownTimer;
@synthesize hostTeam = _hostTeam;
@synthesize guestTeam = _guestTeam;
@synthesize testSwitch = _testSwitch;
@synthesize selectedStatistics = _selectedStatistics;
@synthesize gameStart = _gameStart;
@synthesize gamePeroidButton = _gamePeroidButton;

#pragma 私有函数
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(NSInteger)tag cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle {
    
    UIAlertView * alertView;
    alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle , nil];
    alertView.tag = tag;
    
    [alertView show];
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
        self.hostTimeoutLabel.text = [_match.home.timeouts stringValue];
        self.guestTimeoutLabel.text = [_match.guest.timeouts stringValue];
        [self reversePlayButton];
        
        UIColor * redColor = [UIColor colorWithRed:220/255.0 green:29/255.0 blue:29/255.0 alpha:1.0];
        NSInteger timeoutLimit = [_match.rule timeoutLimitBeforeEndOfPeriod:_match.period];
        if ([_match.home.timeouts integerValue] == timeoutLimit) {
            self.hostTimeoutLabel.textColor = redColor;
        }
        if ([_match.guest.timeouts integerValue] == timeoutLimit) {
            self.guestTimeoutLabel.textColor = redColor;
        }
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
    [self hideTimeoutPromptView];
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
    self.gameHostScoreLable.text = [_match.home.points stringValue];
    self.gameGuestScoreLable.text = [_match.guest.points stringValue];
    self.hostFoulLabel.text = [_match.home.fouls stringValue];
    self.guestFoulLabel.text = [_match.guest.fouls stringValue];
    self.hostTimeoutLabel.text = [_match.home.timeouts stringValue];
    self.guestTimeoutLabel.text = [_match.guest.timeouts stringValue];
}

- (void)handleAddFoulMessage:(NSNotification *)note {
    self.hostFoulLabel.text = [_match.home.fouls stringValue];
    self.guestFoulLabel.text = [_match.guest.fouls stringValue];
    
    UIColor * redColor = [UIColor colorWithRed:220/255.0 green:29/255.0 blue:29/255.0 alpha:1.0];
    if ([_match.home.fouls integerValue] > [_match.rule foulLimitForTeam]) {
        self.hostFoulLabel.textColor = redColor;
    }
    if ([_match.guest.fouls integerValue] > [_match.rule foulLimitForTeam]) {
        self.guestFoulLabel.textColor = redColor;
    }
}

- (void)handleAddPlayerActionMessage:(NSNotification *)note {
    NSNumber * playerId = nil;
    if (nil != note) {
        playerId = note.object;
    }
    
    UIViewController * viewController = (UIViewController *)[[AppDelegate delegate] playGameViewController];
    [self.navigationController popToViewController:viewController animated:YES];
    
    [_match addActionForTeam:_selectedTeam.id forPlayer:playerId withAction:_selectActionType];
    [self toastForTeam:_selectedTeam.name forPlayer:playerId withAction:_selectActionType];
}

- (void)toastForTeam:(NSString *)teamName forPlayer:(NSNumber *)playerId withAction:(ActionType)actionType{
    NSString * msg = nil;
    if (playerId != nil) {
        msg = [[PlayerManager defaultManager] playerWithId:playerId].name;
    }else{
        msg = teamName;
    }
    
    msg = [msg stringByAppendingString:@" "];
    msg = [msg stringByAppendingString:[ActionManager descriptionForActionType:actionType]];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0f];
}

/*初始化暂停、犯规显示数据。
 用途：当本节比赛结束时调用。*/
- (void)initTimeoutAndFoulView {
    self.hostFoulLabel.text = @"0";
    self.guestFoulLabel.text = @"0";
    self.hostTimeoutLabel.text = @"0";
    self.guestTimeoutLabel.text = @"0";
    
    UIColor * grayColor = [UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1.0];
    self.hostFoulLabel.textColor = grayColor;
    self.guestFoulLabel.textColor = grayColor;
    self.hostTimeoutLabel.textColor = grayColor;
    self.guestTimeoutLabel.textColor = grayColor;
}

- (void)enterSettingView{
    [self showGameSettingController];
}

- (void)updateTimeCountDownLable{
    int timeLeftSeconds = (int)_match.countdownSeconds;
    int minutesLeft = timeLeftSeconds / 60;
    int secondsLeft = timeLeftSeconds % 60;
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
    _match.countdownSeconds --;
    [self updateTimeCountDownLable];
    
    if(_match.countdownSeconds <= 0) {
        [self stopTimeCountDown];
        [[SoundManager defaultManager] playSound];
        if ([_match.rule isGameOver] == NO) {
            _match.state = MatchStatePeriodFinished;
            [self reversePlayButton];
    
            // 节间休息倒计时。
            NSString * message = [self titleForEndOfPeriod:_match.period];
            [self showAlertViewWithTitle:LocalString(@"StartCountdown") message:message delegate:self tag:AlertViewTagMatchTimeout cancelButtonTitle:LocalString(@"No") otherButtonTitle:LocalString(@"Yes")];
        }else {
            // 比赛结束处理
            [self updateTitle:LocalString(@"Finish")];
            _match.state = MatchStateFinished;
            [self stopGame:MatchStateFinished withWinTeam:nil];
        }
    }
}

- (void)stopTimeCountDown {
    [self.timeCountDownTimer invalidate];
}

- (void)dismissView{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    }
}

/*
 显示暂停或比赛单节/半场休息提示view
 */
- (void)showTimeoutPromptView:(NSInteger) mode {
    if (_timeoutPromptView == nil) {
         _timeoutPromptView = [[TimeoutPromptView alloc] initWithFrame:CGRectZero];
    }
    _timeoutPromptView.frame = CGRectMake(0.0, 0.0, 320.0, 144.0);
    _timeoutPromptView.mode = mode;
    [_timeoutPromptView updateLayout];
    [self.view addSubview:_timeoutPromptView];
    [self.view bringSubviewToFront:self.controlButton];
    if (mode == PromptModeTimeout || mode == PromptModeRest) {
        [_timeoutPromptView startTimeoutCountdown];
        [[SoundManager defaultManager] playSound];
    }
}

- (void)hideTimeoutPromptView {
    if (nil != _timeoutPromptView) {
        [_timeoutPromptView stopTimeoutCountdown];
        [_timeoutPromptView removeFromSuperview];
    }
}

/*显示开始计时View。
 比赛开始前显示一次。*/
- (void)showStartMatchView {
    StartMatchView * startMatchView = [[StartMatchView alloc] initWithFrame:CGRectMake(0.0, 395.0, 320.0, 65.0)];
    startMatchView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:startMatchView];
    startMatchView.alpha = 0.8;
}

- (IBAction)showPlaySoundController:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    PlaySoundViewController * playSoundViewController = [[PlaySoundViewController alloc] initWithNibName:@"PlaySoundViewController" bundle:nil];
    
    [self.navigationController pushViewController:playSoundViewController animated:YES];
}

/*
 注册消息处理函数
 */
- (void)registerHandleMessage {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessage:) name:kAddTimeoutMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTimeoutOverMessage:) name:kTimeoutOverMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddScoreMessage:) name:kAddScoreMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeleteActionMessage:) name:kDeleteActionMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddFoulMessage:) name:kAddFoulMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddPlayerActionMessage:) name:kActionDetermined object:nil];
}

/*显示比赛设置界面:非编辑状态*/
- (void)showGameSettingController {
    self.navigationController.navigationBarHidden = NO;
    
    GameSettingFormViewController * controller = [[GameSettingFormViewController alloc] init];

//    GameSettingViewController * controller = [[GameSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.ruleInUse = _match.rule;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)swip:(UISwipeGestureRecognizer *)swip {
    ActionRecordViewController * actionRecordontroller = [[ActionRecordViewController alloc] initWithNibName:@"ActionRecordViewController" bundle:nil];
    [self.navigationController pushViewController:actionRecordontroller animated:YES];
}

- (void)addSwipeGesture {
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(swip:)];
    swip.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swip];
}

// 显示比赛结束详情界面
- (void)showMatchFinishedDetailsController {
    MatchFinishedDetailsViewController * controller = [[MatchFinishedDetailsViewController alloc] initWithNibName:@"GameStatisticViewController" bundle:nil];
    
    controller.match = _match.match;
    [controller reloadActionsInMatch];
    
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
    
//    [self presentModalViewController:nav animated:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)initTeam {
    [self.hostImageView makeCircle];
    self.hostImageView.layer.borderWidth = 2;
    self.hostImageView.layer.borderColor = [[UIColor colorWithRed:221 green:221 blue:221 alpha:1.0] CGColor];
    self.hostImageView.image = [[ImageManager defaultInstance] imageForName:self.hostTeam.profileURL];
    self.hostNameLabel.text = self.hostTeam.name;
    
    [self.guestImageView makeCircle];
    self.guestImageView.layer.borderWidth = 2;
    self.guestImageView.layer.borderColor = [[UIColor colorWithRed:221 green:221 blue:221 alpha:1.0] CGColor];
    self.guestImageView.image = [[ImageManager defaultInstance] imageForName:self.guestTeam.profileURL];
    self.guestNameLabel.text = self.guestTeam.name;
}

- (BOOL)timeoutEnableWithTeamStatistics:(TeamStatistics *)teamStatistics {
    BOOL result = NO;
    if (_match.state == MatchStateTimeout ||
        _match.state == MatchStateTimeoutFinished ||
        _match.state == MatchStateQuarterTime) {
        [self showAlertViewWithTitle:LocalString(@"Alert") message:LocalString(@"AlreadyTimeouted") delegate:nil tag:0 cancelButtonTitle:LocalString(@"Ok") otherButtonTitle:nil];
    }else if (_match.state == MatchStatePeriodFinished ||
              _match.state == MatchStateQuarterTimeFinished) {
        [self showAlertViewWithTitle:LocalString(@"Alert") message:LocalString(@"AlreadyPaused") delegate:nil tag:0 cancelButtonTitle:LocalString(@"Ok") otherButtonTitle:nil];
    }else if ([teamStatistics.timeouts intValue] <
              [_match.rule timeoutLimitBeforeEndOfPeriod:_match.period]) {
        result = YES;
    }else {
        [self showAlertViewWithTitle:LocalString(@"Alert") message:LocalString(@"NoTimeout") delegate:nil tag:0 cancelButtonTitle:LocalString(@"Ok") otherButtonTitle:nil];
    }

    return result;
}

- (void)reversePlayButton {
    if (MatchStatePlaying == _match.state) {
        [self.controlButton setBackgroundImage:[UIImage imageNamed:@"game_pause"] forState:UIControlStateNormal];
    }else {
        [self.controlButton setBackgroundImage:[UIImage imageNamed:@"game_start"] forState:UIControlStateNormal];
    }
}

- (void)initView {
    if ([_match.matchMode isEqualToString:kMatchModePoints]) {
        [_gameTimeLabel setHidden:YES];
        [self.foulView setHidden:YES];
        [self.timeoutView setHidden:YES];
        [self.controlButton setHidden:YES];
        [self.gamePeroidButton setHidden:NO];
        [self.gamePeroidLabel setHidden:YES];
        [self startGame];
//        self.teamBackgroundImageView.image = [UIImage imageNamed:@"game_easy_background"];
    }else {
        if ([kMatchModeTpb isEqualToString:_match.matchMode]) {
            [self.timeoutView setHidden:YES];
        }
        [self resetCountdownTime:MatchPeriodFirst];
        [self updateTimeCountDownLable];
        [self updatePeriodLabel];
        [_gamePeroidButton setHidden:YES];
    }
    
    self.gameHostScoreLable.text = @"0";
    self.gameGuestScoreLable.text = @"0";
    [self.settingButton setTitle:LocalString(@"Setting") forState:UIControlStateNormal];
    [self.soundButton setTitle:LocalString(@"SoundEffect") forState:UIControlStateNormal];
    [self.foulLabel setText:LocalString(@"Foul")];
    [self.timeoutLabel setText:LocalString(@"Timeout")];
}

- (NSString *)pageName {
    NSString * pageName = @"PlatGame_";
    pageName = [pageName stringByAppendingString:_match.matchMode];
    return pageName;
}

#pragma 类成员变量
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

#pragma mark - View controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回比赛" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    _testSwitch = NO;
    
    [self initTeam];
    [self initView];
    
    [self registerHandleMessage];
    [self addSwipeGesture];
    
    [LocationManager defaultManager].delegate = self;
    [AppDelegate delegate].playGameViewController = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[self pageName]];
    self.navigationController.navigationBarHidden = YES;
    
    [MobClick beginLogPageView:_match.matchMode];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [MobClick endLogPageView:[self pageName]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)startGame {
    if(_gameStart == NO) {
        [_match startNewMatch];
        _gameStart = YES;
        _match.period ++;
    }
    
    _match.state = MatchStatePlaying;
    if (![_match.matchMode isEqualToString:kMatchModePoints]) {
        // 开始比赛计时
        self.timeCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeCountDown) userInfo:nil repeats:YES];
        [_timeoutPromptView updateLayout];
    }
    
    [self reversePlayButton];
    [[SoundManager defaultManager] playMatchStartSound];
}

- (IBAction)showActionRecordController:(id)sender {
    [self swip:nil];
}

- (IBAction)changePeriod:(UIButton *)sender {
    _match.period = _match.period == MatchPeriodFourth ? MatchPeriodFirst : _match.period % _match.rule.regularPeriodNumber + 1;
   
    [_gamePeroidButton setTitle:[_match nameForCurrentPeriod] forState:UIControlStateNormal];
}

- (IBAction)addAction:(UIButton *)sender {
    // 未开始比赛，提醒是否开始比赛
    if (_match.state == MatchStatePrepare) {
        [self showAlertViewWithTitle:LocalString(@"BeginMatchPrompt") message:LocalString(@"MatchUnbeginPrompt") delegate:self tag:AlertViewTagMatchBegin cancelButtonTitle:LocalString(@"No") otherButtonTitle:LocalString(@"Yes")];
        return;
    }
    
    GameSetting * gameSetting = [GameSetting defaultSetting];
    NSInteger tag = sender.tag;
    BOOL playerStatisticsOn = NO;
    
    // UIButton tag 主队分别为1、2、3、4、5；客队为101、102、103、104、105
    if (tag > kTeamTag) {
        // 客队
        playerStatisticsOn = gameSetting.enableGuestTeamPlayerStatistics;
        _selectedTeam = self.guestTeam;
        _selectActionType = (ActionType)(tag - kTeamTag);
        self.selectedStatistics = _match.guest;
        
    }else {
        // 主队
        playerStatisticsOn = gameSetting.enableHomeTeamPlayerStatistics;
        _selectedTeam = self.hostTeam;
        _selectActionType = (ActionType)tag;
        self.selectedStatistics = _match.home;
    }
    
    // 检查是否还有剩余暂停次数
    if (ActionTypeTimeoutRegular == _selectActionType &&
        ![self timeoutEnableWithTeamStatistics:self.selectedStatistics]) {
        return;
    }
    
    // 球员开关打开时，记得分和犯规需要进入球员列表。
    if (playerStatisticsOn && ActionTypeTimeoutRegular != _selectActionType) {
        NSArray * players = [[PlayerManager defaultManager] playersForTeam:_selectedTeam.id];
        PlayerActionViewController * playerList = [[PlayerActionViewController alloc] initWithStyle:UITableViewStylePlain];
        playerList.players = players;
        playerList.teamId = _selectedTeam.id;
        playerList.actionType = _selectActionType;
        
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:playerList animated:YES];
        
    }else {
        [_match addActionForTeam:_selectedTeam.id forPlayer:nil withAction:_selectActionType];
        [self toastForTeam:_selectedTeam.name forPlayer:nil withAction:_selectActionType];
    }
}

- (IBAction)showSettingController:(id)sender {
    [self showGameSettingController];
}

// 计时器操作，开始或停止计时
- (IBAction)controlGame:(id)sender {
    if (_match.state == MatchStateTimeout ||
        _match.state == MatchStateQuarterTime) {
        [self showAlertViewWithTitle:LocalString(LocalString(@"Alert")) message:LocalString(@"BreakTimeout") delegate:self tag:AlertViewTagMatchBegin cancelButtonTitle:LocalString(@"Cancel") otherButtonTitle:LocalString(@"Ok")];
        
        return;
    }
    
    switch (_match.state) {
        case MatchStatePeriodFinished:
            _match.state = MatchStateQuarterTime;
            [self showTimeoutPromptView:PromptModeRest];
            break;
        case MatchStatePlaying:
            [self pauseCountdownTime];
            break;
        default:
            [self hideTimeoutPromptView];
            [self startGame];
            break;
    }
    
    [self reversePlayButton];
}

- (IBAction)operationMenuClicked:(id)sender{
    // 有节数的话，要显示“结束本节”，否则只显示“结束比赛”
    NSString * otherButton = nil;
    if (_match.state == MatchStatePlaying && ![_match.matchMode isEqualToString:kMatchModePoints]) {
        otherButton = @"结束本节";
    }
    
    UIActionSheet * ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"结束比赛" otherButtonTitles:otherButton, nil];
    [ac showInView:self.view];
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        // 结束比赛
        if (YES == self.gameStart) {
            // 比赛已经开始，结束前提示是否保存比赛
            UIAlertView * alertView;
            alertView = [[UIAlertView alloc] initWithTitle:LocalString(@"FinishMatch")
                                                   message:LocalString(@"SaveMatchPrompt")
                                                  delegate:self
                                         cancelButtonTitle:LocalString(@"Cancel")
                                         otherButtonTitles:LocalString(@"Save"),LocalString(@"Abandon") , nil];
            alertView.tag = AlertViewTagMatchFinish;
            [alertView show];
            
        }else {
            [self stopGame:MatchStateStopped withWinTeam:nil];
        }

    }else if(buttonIndex == actionSheet.firstOtherButtonIndex){
        // 结束本节
        _match.countdownSeconds = 1;
        [self updateTimeCountDown];
    }
}

#pragma mark - Alert  view delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AlertViewTagMatchFinish) {
        // 真的结束比赛
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            // 保存比赛
            [self stopGame:MatchStateFinished withWinTeam:nil];
        }else if(buttonIndex == alertView.firstOtherButtonIndex + 1){
            // 不保存比赛
            [self stopGame:MatchStateStopped withWinTeam:nil];
        }
        
    }else if (alertView.tag == AlertViewTagMatchTimeout){
        //
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            _match.state = MatchStateQuarterTime;
            [self showTimeoutPromptView:PromptModeRest];
        }
        
    }else if (alertView.tag == AlertViewTagMatchBegin) {
        // 开始比赛
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            if (_match.state == MatchStateQuarterTime){
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

            [self hideTimeoutPromptView];
            [self startGame];
        }
    }
}

#pragma mark - Foul action delegate

- (void)FoulsBeyondLimitForTeam:(NSNumber *)teamId {
    [self showAlertViewWithTitle:LocalString(@"Alert") message:LocalString(@"TeamFoulExceedPrompt") delegate:self tag:AlertViewTagMatchNormal cancelButtonTitle:nil otherButtonTitle:LocalString(@"Ok")];
}

- (void)FoulsBeyondLimitForPlayer:(NSNumber *)playerId {
    Player * player = [[PlayerManager defaultManager] playerWithId:playerId];
    NSString * message = [NSString stringWithFormat:LocalString(@"PlayerFoulExceedPrompt"), 
                          [player.number integerValue],player.name];
    
    [self showAlertViewWithTitle:LocalString(@"Alert") message:message delegate:self tag:AlertViewTagMatchNormal cancelButtonTitle:nil otherButtonTitle:LocalString(@"Ok")];
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
