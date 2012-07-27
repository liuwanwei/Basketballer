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
@synthesize gameNavView = _gameNavView;
@synthesize countDownTimer = _countDownTimer;
@synthesize targetTime = _targetTime;
@synthesize playBarItem = _playBarItem;
@synthesize gameState = _gameState;
@synthesize lastTimeoutTime = _lastTimeoutTime;
@synthesize hostTeam = _hostTeam;
@synthesize guestTeam = _guestTeam;
@synthesize gameMode = _gameMode;
@synthesize curPeroid = _curPeroid;
@synthesize soundFileObject = _soundFileObject;
@synthesize soundFileURLRef = _soundFileURLRef;
@synthesize timeoutTargetTime = _timeoutTargetTime;
@synthesize mapView = _mapView;

#pragma 私有函数
- (void)showAlertView:(NSString *)message withCancel:(BOOL)cancel{
    UIAlertView * alertView;
    if(cancel == YES) {
        alertView = [[UIAlertView alloc] initWithTitle:@"确认" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定" , nil];
    }else {
        alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定" , nil];
    }
    [alertView show];
}

/*消息处理函数*/
- (void)handleMessage:(NSNotification *)note {
    if(self.gameState == playing){
        [self setLastTimeoutTime];
        [self stopGameCountDown];
        [self.operateGameView1 setButtonEnabled:NO];
        [self.operateGameView2 setButtonEnabled:NO];
        [self setPlayBarItemTitle:timeout];
        self.gameState = timeout;
        [self showTimeoutPromptView:timeoutMode];
    }
}

/*消息处理函数*/
- (void)handleTimroutOverMessage:(NSNotification *)note {
    AudioServicesPlayAlertSound (self.soundFileObject);
}

/*消息处理函数*/
- (void)handleAddScoreMessage:(NSNotification *)note {
    ActionManager * actionManager = [ActionManager defaultManager];
    
    self.gameHostScoreLable.text = [NSString stringWithFormat:@"%d",actionManager.homeTeamPoints];
    self.gameGuestScoreLable.text = [NSString stringWithFormat:@"%d",actionManager.guestTeamPoints];
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
    }else {
        quarterLength = [[GameSetting defaultSetting].quarterLength intValue];
    }
    
    return quarterLength;
}


/*初始化导航View*/
- (void)initNavBarItem {
    self.navigationController.navigationBarHidden = YES;
}

/*设置暂停时的时间*/
- (void) setLastTimeoutTime {
    NSDate * date = [NSDate date];
    self.lastTimeoutTime = date;
}

- (void)initGameCountDownLable {
    self.gameTimeLabel.text = [NSString stringWithFormat:@"%.2d : %.2d",[self getQuarterLength],0];
}

- (void)setPlayBarItemTitle:(NSInteger) state {
    if (state == playing) {
        [self.playBarItem setTitle:@"                停止计时                "];
    }else {
        [self.playBarItem setTitle:@"                继续计时                "];
    }
}

- (void)setGamePeriodLabel {
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
    TimeoutPromptViewController * timeoutPromptViewController = [[TimeoutPromptViewController alloc] initWithFrame:CGRectMake(0.0, 91.0, 320.0, 369.0)];
    timeoutPromptViewController.parentController = self;
    timeoutPromptViewController.mode = mode;
    timeoutPromptViewController.backgroundColor = [UIColor blackColor];
    [timeoutPromptViewController startTimeout];
    self.timeoutTargetTime = timeoutPromptViewController.timeoutTargetTime;
    [self.view addSubview:timeoutPromptViewController];
    timeoutPromptViewController.alpha = 0.85;
}

/*
 显示计时停止VIEW
 */
- (void)showTimeStopPromptView {
    TimeStopPromptView * timeStopPromptView = [[TimeStopPromptView alloc] initWithFrame:CGRectMake(0.0, 91.0, 320.0, 369.0)];
    timeStopPromptView.parentController = self;
    timeStopPromptView.backgroundColor = [UIColor blackColor];
    timeStopPromptView.alpha = 0.85;
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
        [self.operateGameView1 setButtonEnabled:NO];
        [self.operateGameView2 setButtonEnabled:NO];
        [self setPlayBarItemTitle:timeout];
        AudioServicesPlayAlertSound (self.soundFileObject);
        if (_gameMode == kGameModeTwoHalf) {
            if (_curPeroid == 0) {
                [self showTimeoutPromptView:restMode];
                [self initTimeoutAndFoulView];
                self.gameState = over_quarter_finish;
            }else {
                self.gameState = finish;
                [self showAlertView:@"比赛结束" withCancel:NO];
            }
        }else {
            if (_curPeroid != 3) {
                [self showTimeoutPromptView:restMode];
                [self initTimeoutAndFoulView];
                self.gameState = over_quarter_finish;
            }else {
                self.gameState = finish;
                [self showAlertView:@"比赛结束" withCancel:NO];
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

- (void) initOperateGameView {
  
    self.operateGameView1 = [[OperateGameViewController alloc] initWithFrame:CGRectMake(0.0,91.0f, 320.0f, 161.0f)];
    self.operateGameView1.team = _hostTeam;
    self.operateGameView1.teamType = host;
    [self.operateGameView1 initTeam];
    [self.operateGameView1 setButtonEnabled:NO];
    [self.view addSubview:self.operateGameView1];

    
    self.operateGameView2 =  [[OperateGameViewController alloc] initWithFrame:CGRectMake(0.0,254.0f, 320.0f, 161.0f)];
    self.operateGameView2.team = _guestTeam;
    self.operateGameView2.teamType = guest;
    [self.operateGameView2 initTeam];
    [self.operateGameView2 setButtonEnabled:NO];
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
    [self setTitle:@"比赛"];
    [self initOperateGameView];
    [self initGameCountDownLable];
    [self registerHandleMessage];
    [self setGamePeriodLabel];
    [self initSoundResource];
    
    self.gameState = prepare;
    self.curPeroid = -1;
    [AppDelegate delegate].playGameViewController = self;
    [LocationManager defaultManager].delegate = self;
    [self startGame:nil];
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
    [self initNavBarItem];
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
        
        [[LocationManager defaultManager] startStandardLocationServcie];
    }
    if(self.gameState == prepare || self.gameState == over_quarter_finish || self.gameState == timeout || self.gameState == stop) {
       
        if(self.gameState == prepare || self.gameState == over_quarter_finish) {
            [self initGameTargetTime];
            [self setGamePeriodLabel];
        }else {
            [self updateGameTargetTime];
        }
        [self startGameCountDown];
        [self.operateGameView1 setButtonEnabled:YES];
        [self.operateGameView2 setButtonEnabled:YES];
        [self setPlayBarItemTitle:playing];
        self.gameState = playing;
    }else if(self.gameState == playing){
        [self setLastTimeoutTime];
        [self stopGameCountDown];
        [self.operateGameView1 setButtonEnabled:NO];
        [self.operateGameView2 setButtonEnabled:NO];
        [self setPlayBarItemTitle:timeout];
        if (sender == nil) {
            self.gameState = timeout;
        }else {
            self.gameState = stop;
        }
        [self showTimeStopPromptView];
    }
}

- (IBAction)stopGame:(id)sender {
    [self showAlertView:@"您要强制结束比赛吗？" withCancel:YES];
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
        ActionRecordViewController * actionRecordontroller = [[ActionRecordViewController alloc] initWithNibName:@"ActionRecordViewController" bundle:nil];
        actionRecordontroller.actionRecords = [[ActionManager defaultManager] actionArray];
        [self.navigationController pushViewController:actionRecordontroller animated:YES];
    }
}

/*显示比赛设置界面:非编辑状态*/
- (IBAction)showGameSettingController {
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

#pragma alert delete
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        [self stopGameCountDown];
        _gameStart = NO;
        AudioServicesDisposeSystemSoundID (self.soundFileObject);
        [AppDelegate delegate].playGameViewController = nil;
    }
    
    if (buttonIndex == 1) {
        [[MatchManager defaultManager] stopMatch:_match withState:MatchStopped];
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        self.hidesBottomBarWhenPushed = NO;
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popViewControllerAnimated:YES];

    }else if (alertView.cancelButtonIndex == -1){
        [[MatchManager defaultManager] stopMatch:_match withState:MatchFinished];
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        self.hidesBottomBarWhenPushed = NO;   
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma LocationManager delete
- (void)receivedLocation:(CLLocation *) location {
    if (_match != nil) {
        _match.latitude = [NSNumber numberWithDouble:[location coordinate].latitude];
        _match.longitude = [NSNumber numberWithDouble:[location coordinate].longitude];
    }
}

@end
