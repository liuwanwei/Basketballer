//
//  PlayGameViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayGameViewController.h"
#import "OperateGameViewController.h"
#import "define.h"
#import "GameSetting.h"
#import "MatchManager.h"
#import "TimeoutPromptViewController.h"
#import "ActionRecordViewController.h"
#import "AppDelegate.h"
#import "GameSettingViewController.h"
#import "TimeStopPromptView.h"
#import "StartMatchView.h"

@interface PlayGameViewController() {
    BOOL _gameStart;
    Match * _match;
    CGPoint _touchBeganPoint;
}
@end

@implementation PlayGameViewController

@synthesize operateGameView1 = _operateGameView1;
@synthesize operateGameView2 = _operateGameView2;
@synthesize gameTimeLabel = _gameTimeLabel;
@synthesize gamePeroidLabel = _gamePeroidLabel;
@synthesize gameHostScoreLable = _gameHostScoreLable;
@synthesize gameGuestScoreLable = _gameGuestScoreLable;
@synthesize countDownTimer = _countDownTimer;
@synthesize targetTime = _targetTime;
@synthesize gameState = _gameState;
@synthesize lastTimeoutTime = _lastTimeoutTime;
@synthesize hostTeam = _hostTeam;
@synthesize guestTeam = _guestTeam;
@synthesize gameMode = _gameMode;
@synthesize curPeroid = _curPeroid;
@synthesize soundFileObject = _soundFileObject;
@synthesize soundFileURLRef = _soundFileURLRef;
@synthesize timeoutTargetTime = _timeoutTargetTime;

#pragma 私有函数
- (void)showAlertView:(NSString *)message withCancel:(BOOL)cancel{
    UIAlertView * alertView;
    if(cancel == YES) {
        alertView = [[UIAlertView alloc] initWithTitle:@"确认" message:message delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"保存" , nil];
    }else {
        alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定" , nil];
    }
    [alertView show];
}

/*消息处理函数*/
- (void)handleMessage:(NSNotification *)note {
    if(self.gameState == InPlay){
        [self setLastTimeoutTime];
        [self stopGameCountDown];
        self.gameState = PlayIsSuspended;
        [self showTimeoutPromptView:timeoutMode];
        [self setTitle:@"暂停中"];
    }
}

/*消息处理函数*/
- (void)handleTimroutOverMessage:(NSNotification *)note {
    AudioServicesPlayAlertSound (self.soundFileObject);
    [self setTitle:@"开始计时"];
}

/*消息处理函数*/
- (void)handleAddScoreMessage:(NSNotification *)note {
    ActionManager * actionManager = [ActionManager defaultManager];
    NSInteger hostPoints = actionManager.homeTeamPoints;
    NSInteger guestPoints = actionManager.guestTeamPoints;
    self.gameHostScoreLable.text = [NSString stringWithFormat:@"%d",hostPoints];
    self.gameGuestScoreLable.text = [NSString stringWithFormat:@"%d",guestPoints];
    
    if (_gameMode == kGameModePoints && note != nil) {
        NSInteger winningPoints = [[GameSetting defaultSetting].winningPoints intValue];
        if (hostPoints >= winningPoints || guestPoints >= winningPoints) {
            AudioServicesPlayAlertSound (self.soundFileObject);
            self.gameState = EndOfGame;
            [self setTitle:@"比赛结束"];
            [self stopGame:EndOfGame];
        }
    }
}

/*初始化暂停、犯规显示数据。
 用途：当本节比赛结束时调用。*/
- (void)initTimeoutAndFoulView {
    [_operateGameView1 initTimeoutAndFoulView];
    [_operateGameView2 initTimeoutAndFoulView];
}

- (void)refreshMatchData {
    [_operateGameView1 refreshMatchData];
    [_operateGameView2 refreshMatchData];
    [self handleAddScoreMessage:nil];
}

/*获取单节时长*/
- (NSInteger) getQuarterLength {
    NSInteger quarterLength = 0;
    if(_gameMode == kGameModeTwoHalf) {
        quarterLength = [[GameSetting defaultSetting].halfLength intValue];
    }else if(_gameMode == kGameModeFourQuarter){
        quarterLength = [[GameSetting defaultSetting].quarterLength intValue];
    }
    
    return quarterLength;
}

/*显示菜单项*/
- (void)showMenu {
    UIActionSheet * menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"终止比赛" otherButtonTitles:@"查看比赛操作记录",@"查看当前比赛规则", nil];
    [menu showInView:self.view];

}

/*根据条件显示导航上飞item*/
- (void)showNavBarLeftItem:(BOOL)left withRightItem:(BOOL)right{
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    if (left == YES) {
        UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
        [self.navigationItem setHidesBackButton:YES];
        self.navigationItem.leftBarButtonItem = leftItem;
        
    }else {
        self.navigationItem.leftBarButtonItem = nil;
    }
   
    if (right == YES) {
        UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleBordered target:self action:@selector(showMenu)];
        self.navigationItem.rightBarButtonItem = rightItem;

    }else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

/*设置暂停时的时间*/
- (void) setLastTimeoutTime {
    NSDate * date = [NSDate date];
    self.lastTimeoutTime = date;
}

- (void)initGameCountDownLable {
    NSInteger quarterLength = [self getQuarterLength];
    if (quarterLength != 0) {
        self.gameTimeLabel.text = [NSString stringWithFormat:@"%.2d : %.2d",quarterLength,0];
    }else {
        [self.gameTimeLabel setHidden:YES];
    }
}

- (void)setGamePeriodLabel {
    if (_gameMode == kGameModePoints) {
        self.gamePeroidLabel.hidden = YES;
    }else {
        NSString * prtoidStr;
        switch (_curPeroid) {
            case -1:
            case 0:
                prtoidStr = @"1st";
                break;
            case 1: 
                prtoidStr = @"2nd";
                break;
            case 2:
                prtoidStr = @"3rd";
                break;
            case 3:
                prtoidStr = @"4th";
                break;
                
            default:
                break;
        }
        self.gamePeroidLabel.text = prtoidStr;
    }
}

/*初始化某节比赛结束时间*/
- (void)initGameTargetTime {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    [comps setMinute:comps.minute + [self getQuarterLength]];
    [comps setSecond:comps.second + 1];

    self.targetTime = [calendar dateFromComponents:comps];//把目标时间装载入date
    
    _operateGameView1.gameStartTime = date;
    _operateGameView2.gameStartTime = date;
    ++_curPeroid;
    _operateGameView1.period = _curPeroid;
    _operateGameView2.period = _curPeroid;
}

/*
 显示暂停或比赛单节/半场休息提示VIEW
 */
- (void)showTimeoutPromptView:(NSInteger) mode {
    TimeoutPromptViewController * timeoutPromptViewController = [[TimeoutPromptViewController alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)];
    timeoutPromptViewController.parentController = self;
    timeoutPromptViewController.mode = mode;
    timeoutPromptViewController.backgroundColor = [UIColor blackColor];
    [timeoutPromptViewController startTimeout];
    self.timeoutTargetTime = timeoutPromptViewController.timeoutTargetTime;
    [self.view addSubview:timeoutPromptViewController];
    timeoutPromptViewController.alpha = 0.9;
}

/*
 显示计时停止VIEW
 */
- (void)showTimeStopPromptView {
    TimeStopPromptView * timeStopPromptView = [[TimeStopPromptView alloc] initWithFrame:CGRectMake(0.0, 91.0, 320.0, 369.0)];
    timeStopPromptView.parentController = self;
    timeStopPromptView.backgroundColor = [UIColor blackColor];
    timeStopPromptView.alpha = 0.9;
    [self.view addSubview:timeStopPromptView];
}

/*
 更新某节比赛结束时间。
 1 主动单击“暂停”按钮后，再继续比赛，需要更新。
 */
- (void)updateGameTargetTime {
    NSDate * now = [NSDate date];
    NSTimeInterval exterTime = [now timeIntervalSinceDate:self.lastTimeoutTime];
    
    NSCalendar * targetCalendar = [NSCalendar currentCalendar];
    NSDateComponents * targetComps;
    targetComps = [targetCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self.targetTime];
    
    [targetComps setSecond:targetComps.second + exterTime + 1];
    
    self.targetTime = [targetCalendar dateFromComponents:targetComps];
}

/*
 定时器执行函数：比赛倒计时时间。
 1秒刷新下时间，当倒计时为0时，结束本节或整场的比赛
 */
- (void)updateGameCountDown {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //用来得到具体的时差
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date toDate:self.targetTime options:0];
    NSInteger minute = [comps minute];
    NSInteger second = [comps second];
    if(minute < 0) {
        minute = 0;
    }
    if(second < 0) {
        second = 0;
    }
    self.gameTimeLabel.text = [NSString stringWithFormat:@"%.2d : %.2d",minute,second];
    if(minute <= 0 && second <= 0) {
        [self stopGameCountDown];
        AudioServicesPlayAlertSound (self.soundFileObject);
        if (_gameMode == kGameModeTwoHalf) {
            if (_curPeroid == 0) {
                [self setTitle:@"中场休息"];
                [self showTimeoutPromptView:restMode];
                [self initTimeoutAndFoulView];
                self.gameState = QuarterTime;
            }else {
                [self setTitle:@"比赛结束"];
                self.gameState = EndOfGame;
                [self stopGame:EndOfGame];
            }
        }else {
            if (_curPeroid != 3) {
                [self showTimeoutPromptView:restMode];
                [self initTimeoutAndFoulView];
                self.gameState = QuarterTime;
                if (_curPeroid == 1) {
                    [self setTitle:@"中场休息"];         
                }else {
                    [self setTitle:@"节间休息"];
                }
            }else {
                [self setTitle:@"比赛结束"];
                self.gameState = EndOfGame;
                [self stopGame:EndOfGame];
            }
        }
    }
}

- (void)startGameCountDown {
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateGameCountDown) userInfo:nil repeats:YES];
}

- (void)stopGameCountDown {
    [self.countDownTimer invalidate];
}

- (void)stopGame:(NSInteger) mode {
    [self stopGameCountDown];
    _gameStart = NO;
    AudioServicesDisposeSystemSoundID (self.soundFileObject);
    [AppDelegate delegate].playGameViewController = nil;
    
    if (mode == StoppedPlay) {
        [[MatchManager defaultManager] stopMatch:_match withState:MatchStopped];
    }else if (mode == EndOfGame){
        [[MatchManager defaultManager] stopMatch:_match withState:MatchFinished];
    }
    
    [self showAlertView:@"比赛结束，您要保存比赛数据吗？" withCancel:YES];
}

- (void) initOperateGameView {
    self.operateGameView1 = [[OperateGameViewController alloc] initWithFrame:CGRectMake(0.0,91.0f, 320.0f, 163.0f)];
    self.operateGameView1.team = _hostTeam;
    self.operateGameView1.teamType = HostTeam;
    [self.operateGameView1 initTeam];
    self.operateGameView1.matchMode = _gameMode;
    [self.operateGameView1 setButtonEnabled:NO];
    [self.operateGameView1 initButtonsLayout];
    [self.view addSubview:self.operateGameView1];
    
    self.operateGameView2 =  [[OperateGameViewController alloc] initWithFrame:CGRectMake(0.0,255.0f, 320.0f, 163.0f)];
    self.operateGameView2.team = _guestTeam;
    self.operateGameView2.teamType = GuestTeam;
    self.operateGameView2.matchMode = _gameMode;
    [self.operateGameView2 initTeam];
    [self.operateGameView2 setButtonEnabled:NO];
    [self.operateGameView2 initButtonsLayout];
    [self.view addSubview:self.operateGameView2];
}

/*
 注册消息处理函数
 接受来自OperateGameViewController发来的消息
 */
- (void)registerHandleMessage {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessage:) name:kTimeoutMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTimroutOverMessage:) name:kTimeoutOverMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddScoreMessage:) name:kAddScoreMessage object:nil];
}

- (void)initSoundResource {
    NSURL * tapSound   = [[NSBundle mainBundle] URLForResource: @"sendmsg"
                                                 withExtension: @"caf"];
    self.soundFileURLRef = (__bridge CFURLRef)tapSound;
    AudioServicesCreateSystemSoundID (self.soundFileURLRef,&_soundFileObject);
}

- (void)showActionRecordontroller {
    ActionRecordViewController * actionRecordontroller = [[ActionRecordViewController alloc] initWithNibName:@"ActionRecordViewController" bundle:nil];
    actionRecordontroller.actionRecords = [[ActionManager defaultManager] actionArray];
    [self.navigationController pushViewController:actionRecordontroller animated:YES];
}

/*显示比赛设置界面:非编辑状态*/
- (void)showGameSettingController {
    self.navigationController.navigationBarHidden = NO;
    NSArray * modes = [[GameSetting defaultSetting] gameModeNames];
    
    GameSettingViewController * gameSettingontroller = [[GameSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    gameSettingontroller.viewStyle = UIGameSettingViewStyleShow;
    gameSettingontroller.gameMode = _gameMode;
    if (_gameMode == kGameModeTwoHalf) {
        [gameSettingontroller setTitle:[modes objectAtIndex:0]];
    }else {
        [gameSettingontroller setTitle:[modes objectAtIndex:1]];
    }
    
    [self.navigationController pushViewController:gameSettingontroller animated:YES];
}

/*显示开始计时View。
 比赛开始前显示一次。*/
- (void)showStartMatchView {
    StartMatchView * startMatchView = [[StartMatchView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)];
    startMatchView.parentController = self;
    startMatchView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:startMatchView];
    startMatchView.alpha = 0.9;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
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
    [self setTitle:@"开始计时"];
    [self showStartMatchView];
    [self initOperateGameView];
    [self initGameCountDownLable];
    [self registerHandleMessage];
    [self setGamePeriodLabel];
    [self initSoundResource];
    self.gameState = ReadyToPlay;
    if (_gameMode == kGameModePoints) {
        self.curPeroid = 0;
        [AppDelegate delegate].playGameViewController = nil;
    }else {
        self.curPeroid = -1;
        [AppDelegate delegate].playGameViewController = self;
    }
    
    [self showNavBarLeftItem:YES withRightItem:NO];
    
    //[LocationManager defaultManager].delegate = self;
    //[self startGame:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.operateGameView1 = nil;
    self.operateGameView2 = nil;
    self.gameTimeLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshMatchData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)changeTimeColorWithSuspendedState:(BOOL)suspended{
    if (suspended) {
        _gameTimeLabel.textColor = [UIColor blackColor];
    }else{
        _gameTimeLabel.textColor = [UIColor whiteColor];
    }
}

- (IBAction)startGame:(id)sender {
    if(_gameStart == NO) {
        _match = [[MatchManager defaultManager] newMatchWithMode:self.gameMode
                                                    withHomeTeam:_hostTeam  withGuestTeam:_guestTeam];
        _operateGameView1.match = _match;
        _operateGameView2.match = _match;
        _curPeroid = -1;
        _gameStart = YES;
        [self showNavBarLeftItem:NO withRightItem:YES];
        
        if (_gameMode == kGameModePoints) {
            _operateGameView1.period = 0;
            _operateGameView2.period = 0;
             _curPeroid = 0;
        }
        //[[LocationManager defaultManager] startStandardLocationServcie];
    }
    if(self.gameState == ReadyToPlay || self.gameState == QuarterTime || self.gameState == PlayIsSuspended) {
        if (_gameMode != kGameModePoints) {
            if(self.gameState == ReadyToPlay || self.gameState == QuarterTime) {
                [self initGameTargetTime];
                [self setGamePeriodLabel];
            }else {
                [self updateGameTargetTime];
            }
            [self startGameCountDown];
        }
        [self.operateGameView1 setButtonEnabled:YES];
        [self.operateGameView2 setButtonEnabled:YES];
        self.gameState = InPlay;
        [self setTitle:@"比赛中"];
    }else if(self.gameState == InPlay){
        if (_gameMode != kGameModePoints) {
            [self setLastTimeoutTime];
            [self stopGameCountDown];
            [self showTimeStopPromptView];
        }
        [self.operateGameView1 setButtonEnabled:NO];
        [self.operateGameView2 setButtonEnabled:NO];
        if (sender == nil) {
            self.gameState = PlayIsSuspended;
        }
        [self setTitle:@"暂停中"];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    _touchBeganPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    CGFloat xOffSet = touchPoint.x - _touchBeganPoint.x;
    if (xOffSet < -10) {
        if (_gameStart == YES) {
            [self showActionRecordontroller];
        }
    }
}
#pragma alert delete
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[MatchManager defaultManager] deleteMatch:_match];
    }
    self.hidesBottomBarWhenPushed = NO;   
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma LocationManager delete
- (void)receivedLocation:(CLLocation *) location {
    if (_match != nil) {
        _match.latitude = [NSNumber numberWithDouble:[location coordinate].latitude];
        _match.longitude = [NSNumber numberWithDouble:[location coordinate].longitude];
    }
}

#pragma mark - ActionSheet view delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self stopGame:StoppedPlay];
    }else if (buttonIndex == 1){
        [self showActionRecordontroller];
    }else if (buttonIndex == 2){
        [self showGameSettingController];
    }
}

@end
