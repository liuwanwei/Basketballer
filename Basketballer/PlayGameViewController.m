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
#import "GameSettingFormViewController.h"
#import "SoundManager.h"
#import "BaseRule.h"
#import "PlayerManager.h"
#import "TeamManager.h"
#import "MatchFinishedDetailsViewController.h"
#import "Feature.h"
#import "PlaySoundViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PlayerActionViewController.h"
#import "MobClick.h"
#import "ImageManager.h"
#import "UIImageView+Additional.h"
#import "Macro.h"
#import <MBProgressHUD.h>

typedef enum {
    AlertViewTagMatchFinish = 1,
    AlertViewTagMatchTimeout = 2,
    AlertViewTagMatchNormal = 3,
    AlertViewTagMatchBegin = 4,
}AlertViewTag;

#define GuestTeamTag        100
#define MainColor            [UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90]

@interface PlayGameViewController() {
    MatchUnderWay * _match;
    TimeoutPromptView * _timeoutPromptView;
    
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
@synthesize selectedStatistics = _selectedStatistics;
@synthesize gamePeroidButton = _gamePeroidButton;

- (void)pauseCountdownTimeNote:(NSNotification *)note{
    [self pauseCountdownTime];
}

- (void)pauseCountdownTime {
    _match.state = MatchStateTimeoutTemp;
    [_timeoutPromptView updateLayout];
    [self stopTimeCountDown];
    [self updateTitle:LocalString(@"Pausing")];
}

- (void)updateTitle:(NSString *) title {
    [self setTitle:LocalString(@"PlayGameViewTitle")];
}

- (void)resetPeriodCountdownTime:(MatchPeriod) period{
    _match.countdownSeconds = [_match.rule timeLengthForPeriod:period];
}


- (void)updatePoints{
    self.gameHostScoreLable.text = [_match.home.points stringValue];
    self.gameGuestScoreLable.text = [_match.guest.points stringValue];
}

- (void)updateFouls{
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

- (void)updateTimeouts{
    self.hostTimeoutLabel.text = [_match.home.timeouts stringValue];
    self.guestTimeoutLabel.text = [_match.guest.timeouts stringValue];
    
    UIColor * redColor = [UIColor colorWithRed:220/255.0 green:29/255.0 blue:29/255.0 alpha:1.0];
    NSInteger timeoutLimit = [_match.rule timeoutLimitBeforeEndOfPeriod:_match.period];
    if ([_match.home.timeouts integerValue] == timeoutLimit) {
        self.hostTimeoutLabel.textColor = redColor;
    }
    
    if ([_match.guest.timeouts integerValue] == timeoutLimit) {
        self.guestTimeoutLabel.textColor = redColor;
    }
}

// 暂停消息处理函数
- (void)handleMessage:(NSNotification *)note {
    // 比赛进行时，或临时停表时，都能叫暂停
    if(_match.state == MatchStatePlaying ||
       _match.state == MatchStateTimeoutTemp){
        
        [self stopTimeCountDown];
        _match.state = MatchStateTimeout;
        [self showTimeoutPrompt:PromptModeTimeout];
        [self updateTimeouts];
        [self reversePlayButton];
    }
}

// 结束暂停消息处理函数
- (void)handleTimeoutOverMessage:(NSNotification *)note {    
    if (_match.state == MatchStateTimeout) {
        _match.state = MatchStateTimeoutFinished;
    }else if (_match.state == MatchStateQuarterRestTime){
        _match.state = MatchStateQuarterRestTimeFinished;
        if (_match.period == _match.rule.regularPeriodNumber - 1) {
            _match.period = MatchPeriodOvertime;
        }else {
            _match.period ++; 
        }
        [self resetPeriodCountdownTime:_match.period];
        [self updateCountdownTime];
        [self initTimeoutAndFoulView];
        [self updateCurrentPeriod];
    }
    
    [_timeoutPromptView updateLayout];
    [self hideTimeoutPromptView];
    [[SoundManager defaultManager] playHornSound];
    [self updateTitle:LocalString(@"ResumeTimer")];
}

// 得分消息处理函数
- (void)handleAddScoreMessage:(NSNotification *)note {
    [self updatePoints];
}

// 删除操作消息处理函数
- (void)handleDeleteActionMessage:(NSNotification *)note {
    [self updatePoints];
    [self updateFouls];
    [self updateTimeouts];
}

// 犯规消息处理函数
- (void)handleAddFoulMessage:(NSNotification *)note {
    [self updateFouls];
}

// 队员操作消息处理
- (void)handleAddPlayerActionMessage:(NSNotification *)note {
    NSNumber * playerId = nil;
    if (nil != note) {
        playerId = note.object;
    }
    
    [self.navigationController popToViewController:self animated:YES];
    
    [_match addActionForTeam:_selectedTeam.id forPlayer:playerId withAction:_selectActionType];
    [self toastForTeam:_selectedTeam.name forPlayer:playerId withAction:_selectActionType];
}

// Toast方式提示刚刚完成的操作
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
    hud.color = MainColor;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0f];
}

// 初始化暂停、犯规显示数据，当本节比赛结束时调用。*/
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

- (void)updateCountdownTime{
    int timeLeftSeconds = (int)_match.countdownSeconds;
    int minutesLeft = timeLeftSeconds / 60;
    int secondsLeft = timeLeftSeconds % 60;
    NSString * timeLeftString = [NSString stringWithFormat:@"%.2d : %.2d",minutesLeft, secondsLeft];
    self.gameTimeLabel.text = timeLeftString;
}

- (void)updateCurrentPeriod {
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
    [self updateCountdownTime];
    
    if(_match.countdownSeconds <= 0) {
        [self stopTimeCountDown];
        [[SoundManager defaultManager] playHornSound];
        
        if ([_match.rule isGameOver] == NO) {
            // 一节比赛结束，进入节间休息倒计时
            _match.state = MatchStatePeriodFinished;
            [self reversePlayButton];
            
            NSString * message = [self titleForEndOfPeriod:_match.period];
            [self showAlertViewWithTitle:LocalString(@"StartCountdown") message:message tag:AlertViewTagMatchTimeout cancelButtonTitle:LocalString(@"No") otherButtonTitle:LocalString(@"Yes")];
        }else {
            // 整场比赛时间到，比赛结束处理
            [self updateTitle:LocalString(@"Finish")];
            _match.state = MatchStateFinished;
            [self stopGame:MatchStateFinished withWinTeam:nil];
        }
    }
}

- (void)stopTimeCountDown {
    [self.timeCountDownTimer invalidate];
}

// 关闭比赛界面
- (void)dismissView{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.hidesBottomBarWhenPushed = NO;   
    self.navigationController.navigationBarHidden = NO;
    [AppDelegate delegate].playGameViewController = nil;
    [[AppDelegate delegate] dismissModelViewController];
    [LocationManager defaultManager].delegate = nil;
}

// 显示暂停或节间休息子界面
- (void)showTimeoutPrompt:(NSInteger) mode {
    if (_timeoutPromptView == nil) {
         _timeoutPromptView = [[TimeoutPromptView alloc] initWithFrame:CGRectZero];
    }
    
    // 如果使用AutoLayout，必须指定它在父窗口中的位置，需要在添加到父窗口后，手工写constraints
    _timeoutPromptView.frame = CGRectMake(0.0, 0.0, ([UIScreen mainScreen].bounds.size.width), 144.0);
    _timeoutPromptView.mode = mode;
    [_timeoutPromptView updateLayout];
    [self.view addSubview:_timeoutPromptView];
    [self.view bringSubviewToFront:self.controlButton];
    
    if (mode == PromptModeTimeout || mode == PromptModeQuarterTime) {
        [_timeoutPromptView startTimeoutCountdown];
        [[SoundManager defaultManager] playHornSound];
    }
}

// 隐藏暂停或节间休息子界面
- (void)hideTimeoutPromptView {
    if (nil != _timeoutPromptView) {
        [_timeoutPromptView stopTimeoutCountdown];
        [_timeoutPromptView removeFromSuperview];
    }
}

// 显示比赛设置界面
- (IBAction)showGameSettingView:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    
    GameSettingFormViewController * controller = [[GameSettingFormViewController alloc] init];
    controller.ruleInUse = _match.rule;
    [self.navigationController pushViewController:controller animated:YES];
}

// 结束比赛按下处理
- (void)stopGame:(NSInteger)mode withWinTeam:(NSNumber *)teamId{
    if (![_match matchStarted]) {
        [self dismissView];
        return;
    }
    
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


// 进入比赛数据记录界面
- (IBAction)showActionRecord:(id)sender {
    ActionRecordViewController * actionRecordontroller = [[ActionRecordViewController alloc] initWithNibName:@"ActionRecordViewController" bundle:nil];
    [self.navigationController pushViewController:actionRecordontroller animated:YES];    
}

// 进入背景音乐选择界面
- (IBAction)showMusicView:(id)sender{
    self.navigationController.navigationBarHidden = NO;
    PlaySoundViewController * playSoundViewController = [[PlaySoundViewController alloc] initWithNibName:@"PlaySoundViewController" bundle:nil];
    
    [self.navigationController pushViewController:playSoundViewController animated:YES];
}

/*
 注册消息处理函数
 */
- (void)registerNotificationHandler {
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleMessage:) name:kAddTimeoutMessage object:nil];
    
    [nc addObserver:self selector:@selector(handleAddScoreMessage:) name:kAddScoreMessage object:nil];
    
    [nc addObserver:self selector:@selector(handleDeleteActionMessage:) name:kDeleteActionMessage object:nil];
    
    [nc addObserver:self selector:@selector(handleAddFoulMessage:) name:kAddFoulMessage object:nil];
    
    [nc addObserver:self selector:@selector(handleAddPlayerActionMessage:) name:kActionDetermined object:nil];
    
    [nc addObserver:self selector:@selector(handleTimeoutOverMessage:) name:TimeoutPromptViewTimeOver object:nil];    
    [nc addObserver:self selector:@selector(startGameNote:) name:TimeoutPromptViewStartGame object:nil];
    [nc addObserver:self selector:@selector(pauseCountdownTimeNote:) name:TimeoutPromptViewPauseGame object:nil];
}

- (void)swip:(UISwipeGestureRecognizer *)swip {
    [self showActionRecord:nil];
}

- (void)addSwipeGesture {
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer  alloc] initWithTarget:self action:@selector(swip:)];
    swip.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swip];
}

// 显示比赛结束详情界面
- (void)showMatchFinishedDetailsController {
    MatchFinishedDetailsViewController * controller = [[MatchFinishedDetailsViewController alloc]
                                                       initWithNibName:@"GameStatisticViewController" bundle:nil];
    controller.match = _match.match;
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:controller animated:YES];
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
        _match.state == MatchStateQuarterRestTime) {
        [self showAlertViewWithTitle:LocalString(@"Alert") message:LocalString(@"AlreadyTimeouted") tag:0 cancelButtonTitle:LocalString(@"Ok") otherButtonTitle:nil];
        
    }else if (_match.state == MatchStatePeriodFinished ||
              _match.state == MatchStateQuarterRestTimeFinished) {
        [self showAlertViewWithTitle:LocalString(@"Alert") message:LocalString(@"AlreadyPaused") tag:0 cancelButtonTitle:LocalString(@"Ok") otherButtonTitle:nil];
        
    }else if ([teamStatistics.timeouts intValue] <
              [_match.rule timeoutLimitBeforeEndOfPeriod:_match.period]) {
        result = YES;
    }else {
        [self showAlertViewWithTitle:LocalString(@"Alert") message:LocalString(@"NoTimeout") tag:0 cancelButtonTitle:LocalString(@"Ok") otherButtonTitle:nil];
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

    }else {
        if ([kMatchModeTpb isEqualToString:_match.matchMode]) {
            [self.timeoutView setHidden:YES];
        }
        [self resetPeriodCountdownTime:MatchPeriodFirst];
        [self updateCountdownTime];
        [self updateCurrentPeriod];
        [_gamePeroidButton setHidden:YES];
    }
    
    self.gameHostScoreLable.text = @"0";
    self.gameGuestScoreLable.text = @"0";
//    [self.settingButton setTitle:LocalString(@"Setting") forState:UIControlStateNormal];
//    [self.foulLabel setText:LocalString(@"Foul")];
//    [self.timeoutLabel setText:LocalString(@"Timeout")];

    NSMutableArray * controls = [@[] mutableCopy];
    for (UIView * subView in self.view.subviews) {
        for (UIView * subsubView in subView.subviews) {
            if (subsubView.tag > 0) {
                [controls addObject:subsubView];
            }
        }
    }

    // 定制控制按钮的外观
    for (UIView * controlView in controls) {
        if ([controlView isKindOfClass:[UIButton class]]) {
            UIButton * controlButton = (UIButton *)controlView;
            
            [controlButton setTitleColor:MainColor forState:UIControlStateNormal];
       
            // 给控制按钮加阴影效果的代码，只在iPad下打开，避免界面过于空虚
            if (isPad) {
//                [controlButton setBackgroundColor:[UIColor lightTextColor]];
//                controlButton.layer.cornerRadius = 12;
//                controlButton.clipsToBounds = YES;
                controlButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            }else{
                if (controlButton.tag < GuestTeamTag) {
                    controlButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                }else{
                    controlButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                }
            }
        }
    }
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
    
    [self initTeam];
    [self initView];
    
    [self registerNotificationHandler];
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

- (void)startGameNote:(NSNotification *)note{
    [self startGame];
}

- (void)startGame {
    if(! [_match matchStarted]) {
        [_match startNewMatch];
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


- (IBAction)changePeriod:(UIButton *)sender {
    _match.period = _match.period == MatchPeriodFourth ? MatchPeriodFirst : _match.period % _match.rule.regularPeriodNumber + 1;
   
    [_gamePeroidButton setTitle:[_match nameForCurrentPeriod] forState:UIControlStateNormal];
}

// 添加操作
- (IBAction)addAction:(UIButton *)sender {
    // 未开始比赛，提醒是否开始比赛
    if (_match.state == MatchStatePrepare) {
        [self showAlertViewWithTitle:LocalString(@"BeginMatchPrompt")
                             message:LocalString(@"MatchUnbeginPrompt")
                                 tag:AlertViewTagMatchBegin
                   cancelButtonTitle:LocalString(@"No")
                    otherButtonTitle:LocalString(@"Yes")];
        return;
    }
    
    GameSetting * gameSetting = [GameSetting defaultSetting];
    NSInteger tag = sender.tag;
    BOOL playerStatisticsOn = NO;
    
    // UIButton tag 主队分别为1、2、3、4、5；客队为101、102、103、104、105
    if (tag > GuestTeamTag) {
        // 客队
        playerStatisticsOn = gameSetting.enableGuestTeamPlayerStatistics;
        _selectedTeam = self.guestTeam;
        _selectActionType = (ActionType)(tag - GuestTeamTag);
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
        
        playerList.title = LocalString(@"SelectPlayer");
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:playerList animated:YES];
        
    }else {
        [_match addActionForTeam:_selectedTeam.id forPlayer:nil withAction:_selectActionType];
        [self toastForTeam:_selectedTeam.name forPlayer:nil withAction:_selectActionType];
    }
}

// 计时器操作，开始或停止计时
- (IBAction)controlNeatMatchTime:(id)sender {
    switch (_match.state) {
        case MatchStatePeriodFinished:
            // 单节比赛结束后，手动进入节间休息时的处理
            _match.state = MatchStateQuarterRestTime;
            [self showTimeoutPrompt:PromptModeQuarterTime];
            break;
        case MatchStatePlaying:
            // 暂停比赛时间倒计时
            [self pauseCountdownTime];
            break;
        default:
            // 继续比赛时间倒计时
            [self hideTimeoutPromptView];
            [self startGame];
            break;
    }
    
    [self reversePlayButton];
}

- (IBAction)stopGameClicked:(id)sender{
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
        if ([_match matchStarted]) {
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
        // 结束本节，时间退到1秒，updateTimeCountDown会将其减到0
        _match.countdownSeconds = 1;
        [self updateTimeCountDown];
    }
}

// 对UIAlertView使用上进行一层封装
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message tag:(NSInteger)tag cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle {
    
    UIAlertView * alertView;
    alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle , nil];
    alertView.tag = tag;
    
    [alertView show];
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
        // 单节时间到，提示是否并进入节间休息
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            // 确认的话，进入节间休息，否则停留在MatchStatePeriodFinished状态
            _match.state = MatchStateQuarterRestTime;
            [self showTimeoutPrompt:PromptModeQuarterTime];
        }
        
    }else if (alertView.tag == AlertViewTagMatchBegin) {
        // 开始比赛
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            if (_match.state == MatchStateQuarterRestTime){
                _match.state = MatchStateQuarterRestTimeFinished;
                if (_match.period == _match.rule.regularPeriodNumber - 1) {
                    _match.period = MatchPeriodOvertime;
                }else {
                    _match.period ++;
                }
                [self resetPeriodCountdownTime:_match.period];
                [self updateCountdownTime];
                [self initTimeoutAndFoulView];
                [self updateCurrentPeriod];
            }

            [self hideTimeoutPromptView];
            [self startGame];
        }
    }
}

#pragma mark - Foul action delegate

- (void)FoulsBeyondLimitForTeam:(NSNumber *)teamId {
    [self showAlertViewWithTitle:LocalString(@"Alert") message:LocalString(@"TeamFoulExceedPrompt") tag:AlertViewTagMatchNormal cancelButtonTitle:nil otherButtonTitle:LocalString(@"Ok")];
}

- (void)FoulsBeyondLimitForPlayer:(NSNumber *)playerId {
    Player * player = [[PlayerManager defaultManager] playerWithId:playerId];
    NSString * message = [NSString stringWithFormat:LocalString(@"PlayerFoulExceedPrompt"), 
                          [player.number integerValue],player.name];
    
    [self showAlertViewWithTitle:LocalString(@"Alert") message:message tag:AlertViewTagMatchNormal cancelButtonTitle:nil otherButtonTitle:LocalString(@"Ok")];
}

// 某个球队达到了赢球比分，历史中的一种玩法，现在已经废除
- (void)attainWinningPointsForTeam:(NSNumber *)teamId {
    [[SoundManager defaultManager] playHornSound];
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
