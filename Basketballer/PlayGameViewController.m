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

@interface PlayGameViewController() {
    BOOL _gameStart;
    Match * _match;
    NSInteger _curPeroid;
}
@end

@implementation PlayGameViewController

@synthesize operateGameView1 = _operateGameView1;
@synthesize operateGameView2 = _operateGameView2;
@synthesize gameTimeLable = _gameTimeLable;
@synthesize gameTimeView = _gameTimeView;
@synthesize timeoutTimeLabel = _timeoutTimeLabel;
@synthesize countDownTimer = _countDownTimer;
@synthesize timeoutCountDownTimer = _timeoutCountDownTimer;
@synthesize timeoutTargetTime = _timeoutTargetTime;
@synthesize targetTime = _targetTime;
@synthesize playBarItem = _playBarItem;
@synthesize gameState = _gameState;
@synthesize lastTimeoutTime = _lastTimeoutTime;
@synthesize hostTeam = _hostTeam;
@synthesize guestTeam = _guestTeam;
@synthesize gameMode = _gameMode;

#pragma 私有函数
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

/*设置导航栏是否隐藏*/
- (void) setNavTitleVisble:(BOOL) visible {
    [self.navigationController setNavigationBarHidden:!visible animated:NO];
}

/*设置暂停时的时间*/
- (void) setLastTimeoutTime {
    NSDate * date = [NSDate date];
    self.lastTimeoutTime = date;
}

- (void)initGameCountDownLable {
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.titleView = self.gameTimeView;
    self.gameTimeLable.font = [UIFont fontWithName:@"DB LCD Temp" size:20.0f];
    self.gameTimeLable.text = [NSString stringWithFormat:@"%.2d : %.2d",[self getQuarterLength],0];
}

- (void)initTimeoutDownLable {
    self.timeoutTimeLabel.font = [UIFont fontWithName:@"DB LCD Temp" size:20.0f];
    self.timeoutTimeLabel.text = [NSString stringWithFormat:@"%.2d : %.2d",0,20];
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
    _operateGameView1.period = _curPeroid;
    _operateGameView2.period = _curPeroid;
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

/*初始化暂停结束时间*/
- (void)initTimeoutTargetTime {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    [comps setSecond:comps.second + 21];
    
    self.timeoutTargetTime = [calendar dateFromComponents:comps];//把目标时间装载入date
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
    self.gameTimeLable.text = [NSString stringWithFormat:@"%.2d : %.2d",minute,second];
    if(minute <= 0 && second <= 0) {
        [self stopGameCountDown];
        [self.operateGameView1 setButtonEnabled:NO];
        [self.operateGameView2 setButtonEnabled:NO];
        [self.playBarItem setImage:[UIImage imageNamed:@"play"]];
        self.gameState = over_quarter_finish;
    }
}

- (void)updateTimeoutCountDown {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //用来得到具体的时差
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date toDate:self.timeoutTargetTime options:0];
    NSInteger minute = [comps minute];
    NSInteger second = [comps second];
    self.timeoutTimeLabel.text = [NSString stringWithFormat:@"%.2d : %.2d",minute,second];
    if(minute <= 0 && second <= 0) {
        [self stopTimeoutCountDown];
    }

}

- (void)startGameCountDown {
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateGameCountDown) userInfo:nil repeats:YES];
}

- (void)stopGameCountDown {
    [self.countDownTimer invalidate];
}

- (void)startTimeoutCountDown {
     self.timeoutCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeoutCountDown) userInfo:nil repeats:YES];
}

- (void)stopTimeoutCountDown {
    [self.timeoutCountDownTimer invalidate];
}

- (void) initOperateGameView {
  
    self.operateGameView1 = [[OperateGameViewController alloc] initWithFrame:CGRectMake(7.0,10.0f, 306.0f, 168.0f)];
    self.operateGameView1.team = _hostTeam;
    self.operateGameView1.teamType = host;
    [self.operateGameView1 initTeam];
    [self.operateGameView1 setButtonEnabled:NO];
    [self.view addSubview:self.operateGameView1];

    
    self.operateGameView2 =  [[OperateGameViewController alloc] initWithFrame:CGRectMake(7.0,195.0f, 306.0f, 168.0f)];
    self.operateGameView2.team = _guestTeam;
    self.operateGameView2.teamType = guest;
    [self.operateGameView2 initTeam];
    [self.operateGameView2 setButtonEnabled:NO];
    [self.view addSubview:self.operateGameView2];
}

/*消息处理函数*/
- (void)handleMessage:(NSNotification *)note {
    if(self.gameState == playing){
        [self setLastTimeoutTime];
        [self initTimeoutTargetTime];
        [self startTimeoutCountDown];
        [self stopGameCountDown];
        [self.operateGameView1 setButtonEnabled:NO];
        [self.operateGameView2 setButtonEnabled:NO];
        [self.playBarItem setImage:[UIImage imageNamed:@"play"]];
        self.gameState = timeout;
    }
}

/*
 注册消息处理函数
 接受来自OperateGameViewController发来的消息
 */
- (void)registerHandleMessage {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessage:) name:kTimeoutMessage object:nil];
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
    [self initOperateGameView];
    [self registerHandleMessage];
    self.gameState = prepare;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.operateGameView1 = nil;
    self.operateGameView2 = nil;
    self.gameTimeLable = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavTitleVisble:YES];
    [self initGameCountDownLable];
    [self initTimeoutDownLable];
}

- (void)viewWillDisappear:(BOOL)animated {
#warning 功能未完成
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)startGame:(id)sender {
    if(_gameStart == NO) {
        _match = [[MatchManager defaultManager] newMatchWithMode:self.gameMode
                                                    withHomeTeam:_hostTeam  withGuestTeam:_guestTeam];
        _operateGameView1.match = _match;
        _operateGameView2.match = _match;
        _curPeroid = 0;
        _gameStart = YES;
    }
    if(self.gameState == prepare || self.gameState == over_quarter_finish || self.gameState == timeout) {
       
        if(self.gameState == prepare || self.gameState == over_quarter_finish) {
            [self initGameTargetTime];
        }else {
            [self updateGameTargetTime];
        }
        [self stopTimeoutCountDown];
        [self startGameCountDown];
        [self.operateGameView1 setButtonEnabled:YES];
        [self.operateGameView2 setButtonEnabled:YES];
        [self.playBarItem setImage:[UIImage imageNamed:@"pause"]];
        [self initTimeoutDownLable];
        self.gameState = playing;
    }else if(self.gameState == playing){
        [self setLastTimeoutTime];
        [self stopGameCountDown];
        [self.operateGameView1 setButtonEnabled:NO];
        [self.operateGameView2 setButtonEnabled:NO];
        [self.playBarItem setImage:[UIImage imageNamed:@"play"]];
        self.gameState = timeout;
    }
}

- (IBAction)stopGame:(id)sender {
    [self stopGameCountDown];
    _gameStart = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
