//
//  BCPlayGameViewController.m
//  Basketballer
//
//  Created by sungeo on 15/3/6.
//
//

#import "BCPlayGameViewController.h"
#import "BCActionTableController.h"
#import "ActionRecordViewController.h"
#import "MatchFinishedDetailsViewController.h"
#import "UIImageView+Additional.h"
#import "Team.h"
#import "SoundManager.h"
#import "MatchUnderWay.h"
#import "ImageManager.h"

#define LocalString(key)  NSLocalizedString(key, nil)

typedef enum {
    AlertViewTagMatchFinish = 0,
    AlertViewTagMatchTimeout = 1,
    AlertViewTagMatchNormal = 2,
    AlertViewTagMatchBegin = 3,
}AlertViewTag;


@interface BCPlayGameViewController ()
@property (nonatomic, strong) BCActionTableController * actionListController;
@property (nonatomic, weak) Team * homeTeam;
@property (nonatomic, weak) ActionManager * actionManager;
@property (nonatomic, strong) MatchUnderWay * match;

@end

@implementation BCPlayGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 中间表格的创建和消息处理独立出来
    self.actionListController = [[BCActionTableController alloc] init];
    self.actionListController.tableView = self.tableView;
    self.actionListController.superViewController = self;
    
    // 隐藏多余的cell
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    
    [self initMatch];
    [self initTeamsInfo];
    [self initSubViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initMatch{
    _match = [MatchUnderWay defaultMatch];
    _match.delegate = self;
    
    [_match initMatchDataWithHomeTeam:self.hostTeam.id andGuestTeam:self.guestTeam.id];
}

- (void)initTeamsInfo{
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

- (void)initSubViews{
    [self resetPeriodCountdownTime:MatchPeriodFirst];
    [self updateCountdownTime];
    [self updateCurrentPeriod];
    
    self.gameHostScoreLable.text = @"0";
    self.gameGuestScoreLable.text = @"0";
}

- (void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Timer control

// 重置小节倒计时定时器
- (void)resetPeriodCountdownTime:(MatchPeriod) period{
    _match.countdownSeconds = [_match.rule timeLengthForPeriod:period];
}

// 更新小节倒计时定时器
- (void)updateCountdownTime{
    int timeLeftSeconds = (int)_match.countdownSeconds;
    int minutesLeft = timeLeftSeconds / 60;
    int secondsLeft = timeLeftSeconds % 60;
    NSString * timeLeftString = [NSString stringWithFormat:@"%.2d:%.2d",minutesLeft, secondsLeft];
    self.gameTimeLabel.text = timeLeftString;
}

// 更新当前节数
- (void)updateCurrentPeriod {
    self.gamePeroidLabel.text = [_match nameForCurrentPeriod];
}

// 暂停时间倒计时
- (void)pauseCountdownTime {
    _match.state = MatchStateTimeoutTemp;
    [self stopTimeCountDown];
}

// 停止时间倒计时
- (void)stopTimeCountDown {
    [self.timeCountDownTimer invalidate];
}

#pragma mark - Game neat time contorl

- (IBAction)controlNeatMatchTime:(id)sender {
    switch (_match.state) {
//        case MatchStatePeriodFinished:
//            // 单节比赛结束后，手动进入节间休息时的处理
//            _match.state = MatchStateQuarterTime;
//            [self showTimeoutPrompt:PromptModeQuarterTime];
//            break;
        case MatchStatePlaying:
            // 暂停比赛时间倒计时
            [self pauseCountdownTime];
            break;
        default:
            // 继续比赛时间倒计时
            [self startGame];
            break;
    }
    
    [self reversePlayButton];
}

- (void)startGame {
    if(! [_match matchStarted]) {
        [_match startNewMatch];
        _match.period ++;
    }
    
    _match.state = MatchStatePlaying;

    // 开始比赛计时
    self.timeCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeCountDown) userInfo:nil repeats:YES];
    
    [self reversePlayButton];
    [[SoundManager defaultManager] playMatchStartSound];
}

// 结束比赛
- (void)stopGame:(NSInteger)mode withWinTeam:(NSNumber *)teamId{
    if (![_match matchStarted]) {
        [self dismissView];
        return;
    }
    
    [self stopTimeCountDown];
//    [_timeoutPromptView stopTimeoutCountdown];
    [_match stopMatchWithState:mode];
    
    if (mode == MatchStateFinished) {
        [self showMatchFinishedDetailsController];
    }else {
        [_match deleteMatch];
        [self dismissView];
    }
}

// 显示比赛结束详情界面
- (void)showMatchFinishedDetailsController {
    MatchFinishedDetailsViewController * controller = [[MatchFinishedDetailsViewController alloc] initWithNibName:@"GameStatisticViewController" bundle:nil];
    controller.match = _match.match;
    
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
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
            
//            NSString * message = [self titleForEndOfPeriod:_match.period];
//            [self showAlertViewWithTitle:LocalString(@"StartCountdown") message:message tag:AlertViewTagMatchTimeout cancelButtonTitle:LocalString(@"No") otherButtonTitle:LocalString(@"Yes")];
        }else {
            // 整场比赛时间到，比赛结束处理
            _match.state = MatchStateFinished;
            [self stopGame:MatchStateFinished withWinTeam:nil];
        }
    }
}

// 对UIAlertView使用上进行一层封装
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message tag:(NSInteger)tag cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle {
    
    UIAlertView * alertView;
    alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle , nil];
    alertView.tag = tag;
    
    [alertView show];
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


- (void)reversePlayButton {
    if (MatchStatePlaying == _match.state) {
        [self.controlButton setBackgroundImage:[UIImage imageNamed:@"game_pause"] forState:UIControlStateNormal];
    }else {
        [self.controlButton setBackgroundImage:[UIImage imageNamed:@"game_start"] forState:UIControlStateNormal];
    }
}

- (IBAction)stopGameClicked:(id)sender{
    // 有节数的话，要显示“结束本节”，否则只显示“结束比赛”
    NSString * otherButton = nil;
    if (_match.state == MatchStatePlaying) {
        otherButton = @"结束本节";
    }
    
    UIActionSheet * ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"结束比赛" otherButtonTitles:otherButton, nil];
    [ac showInView:self.view];
}


// 弹出操作菜单
- (IBAction)leftButtonClicked:(id)sender{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"结束比赛" otherButtonTitles:@"结束本节", @"比赛设置", nil];
    [actionSheet showInView:self.view];
}

// 控制比赛时间
- (IBAction)timeControlButtonClicked:(id)sender{
    
}

// 查看数据
- (IBAction)rightButtonClicked:(id)sender{
    ActionRecordViewController * vc = [[ActionRecordViewController alloc] initWithNibName:@"ActionRecordViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
