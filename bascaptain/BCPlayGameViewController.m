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
#import "PlayerManager.h"
#import "BCPlayerAction.h"
#import "TimeoutPromptView.h"
#import "BCSettings.h"
#import <MBProgressHUD.h>
#import <TMCache.h>

#define LocalString(key)  NSLocalizedString(key, nil)

// UIAlertView tag
typedef enum {
    AlertViewTagMatchFinish = 0,
    AlertViewTagMatchTimeout = 1,
    AlertViewTagMatchNormal = 2,
    AlertViewTagMatchBegin = 3,
    AlertViewTagGuestTeamScore = 4,
    AlertViewTagGuestTeamScoreNotice = 5,
}AlertViewTag;


@interface BCPlayGameViewController ()
@property (nonatomic, strong) BCActionTableController * actionListController;
@property (nonatomic, weak) Team * homeTeam;
@property (nonatomic, weak) ActionManager * actionManager;
@property (nonatomic, strong) MatchUnderWay * match;

@property (nonatomic, strong) TimeoutPromptView * timeoutPromptView;

@end

@implementation BCPlayGameViewController

#pragma mark - View controller events

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
    [self addNotificationHandler];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.actionListController clearRowSelection];
    self.navigationController.navigationBarHidden = YES;
    
    if (NO == [[BCSettings defaultInstance] guestTeamAddScroreNoticeFlag]) {
        self.guestNoticeCircle.hidden = NO;
        [self.view bringSubviewToFront:self.guestNoticeCircle];
        
    }else{
        self.guestNoticeCircle.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeNotificationHandler];
}

- (void)initMatch{
    _match = [MatchUnderWay defaultMatch];
    _match.delegate = self;
    _match.matchMode = kMatchModeFiba;
    
    // 初始化比赛数据
    [_match initMatchDataWithHomeTeam:self.hostTeam.id andGuestTeam:self.guestTeam.id];
    
    // 直接进入比赛
    [self startGame];
}

- (void)initTeamsInfo{
    [self.hostImageView makeCircle];
    self.hostImageView.layer.borderWidth = 1;
    self.hostImageView.layer.borderColor = [[UIColor colorWithRed:221 green:221 blue:221 alpha:1.0] CGColor];
    self.hostImageView.image = [[ImageManager defaultInstance] imageForName:self.hostTeam.profileURL];
    self.hostNameLabel.text = self.hostTeam.name;
    
    [self.guestImageView makeCircle];
    self.guestImageView.layer.borderWidth = 1;
    self.guestImageView.layer.borderColor = [[UIColor colorWithRed:221 green:221 blue:221 alpha:1.0] CGColor];
    self.guestImageView.image = [[ImageManager defaultInstance] imageForName:self.guestTeam.profileURL];
    self.guestNameLabel.text = self.guestTeam.name;
    
    UITapGestureRecognizer * singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addGuestTeamScore:)];
    [singleTap setNumberOfTapsRequired:1];
    [self.guestImageView setUserInteractionEnabled:YES];
    [self.guestImageView addGestureRecognizer:singleTap];
}

- (void)initSubViews{
    [self resetPeriodCountdownTime:MatchPeriodFirst];
    [self updateCountdownTime];
    [self updateCurrentPeriod];
    
    self.gameHostScoreLable.text = @"0";
    self.gameGuestScoreLable.text = @"0";
}

- (void)addNotificationHandler{
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(promptViewTimeOverNote:) name:TimeoutPromptViewTimeOver object:nil];
    [nc addObserver:self selector:@selector(starGameNote:) name:TimeoutPromptViewStartGame object:nil];
    [nc addObserver:self selector:@selector(pauseGameNote:) name:TimeoutPromptViewPauseGame object:nil];
    [nc addObserver:self selector:@selector(addScoreNote:) name:kAddScoreMessage object:nil];
    [nc addObserver:self selector:@selector(addPlayerActionNote:) name:AddPlayerActionNote object:nil];
    [nc addObserver:self selector:@selector(deleteActionNote:) name:kDeleteActionMessage object:nil];
}

- (void)removeNotificationHandler{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Timer control 比赛时间定时器控制

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
- (void)pauseGame {
    _match.state = MatchStateTimeoutTemp;
    [self stopTimeCountDown];
}

// 停止时间倒计时
- (void)stopTimeCountDown {
    [self.timeCountDownTimer invalidate];
}

#pragma mark - Game time button 比赛时间控制按钮消息处理

- (IBAction)gameTimeButtonClicked:(id)sender {
    switch (_match.state) {
        case MatchStatePlaying:
            // 暂停比赛时间倒计时
            [self pauseGame];
            break;
        default:
            // 继续比赛时间倒计时
            [self startGame];
            break;
    }
    
    [self reversePlayButton];
}

- (void)starGameNote:(NSNotification *)note{[self startGame];}
- (void)pauseGameNote:(NSNotification *)note{[self pauseGame];}

- (void)startGame {
    if(! [_match isMatchStart]) {
        // 比赛未开始时，开始比赛并进入第一节
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
    if (![_match isMatchStart]) {
        [self dismissView];
        return;
    }
    
    [self stopTimeCountDown];
    [_match stopMatchWithState:mode];
    
    if (mode != MatchStateFinished) {
        [_match deleteMatch];
    }
    
    [self dismissView];
}

- (void)addScoreNote:(NSNotification *)note{
    [self updatePoints];
}

- (void)addPlayerActionNote:(NSNotification *)note{
    NSDictionary * userInfo = note.userInfo;
    if (userInfo) {
        BCPlayerAction * playerAction = userInfo[AddPlayerActionKey];
        if (playerAction) {
            ActionType actionType = (ActionType)[playerAction.action integerValue];
            [self.match addActionForTeam:playerAction.teamId forPlayer:playerAction.playerId withAction:actionType];
            NSString * message = [self messageForTeam:self.homeTeam.name playerId:playerAction.playerId action:actionType];
            [self showToastPrompt:message];
        }
    }
}

- (void)deleteActionNote:(NSNotification *)note{
    [self updatePoints];
}

// 更新顶部显示的比分
- (void)updatePoints{
    self.gameHostScoreLable.text = [_match.home.points stringValue];
    self.gameGuestScoreLable.text = [_match.guest.points stringValue];
}


// 显示比赛结束详情界面
- (void)showMatchFinishedDetailsController {
    MatchFinishedDetailsViewController * controller = [[MatchFinishedDetailsViewController alloc] initWithNibName:@"GameStatisticViewController" bundle:nil];
    controller.match = _match.match;
    
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}




// 定时器执行函数：比赛倒计时时间。1秒刷新下时间，当倒计时为0时，结束本节或整场的比赛
- (void)updateTimeCountDown {
    _match.countdownSeconds --;
    [self updateCountdownTime];
    
    if(_match.countdownSeconds <= 0) {
        [self stopTimeCountDown];
        [[SoundManager defaultManager] playHornSound];
        
        if ([_match.rule isGameOver]) {
            // 整场比赛时间到，比赛结束处理
            _match.state = MatchStateFinished;
            [self stopGame:MatchStateFinished withWinTeam:nil];
            
        }else {
            // 一节比赛结束
            _match.state = MatchStatePeriodFinished;
            [self reversePlayButton];
            
            // 询问是否进入节间休息倒计时
            [self showAlertViewWithTitle:@"本节比赛结束" message:@"马上进入节间休息？" tag:AlertViewTagMatchTimeout cancelButtonTitle:nil otherButtonTitle:LocalString(@"Yes")];

        }
    }
}

// 对UIAlertView使用进行封装
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message tag:(NSInteger)tag cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle {
    
    UIAlertView * alertView;
    alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle , nil];
    alertView.tag = tag;
    
    [alertView show];
}

//  添加客队得分
- (void)addGuestTeamScore:(id)sender{
    if (NO == [[BCSettings defaultInstance] guestTeamAddScroreNoticeFlag]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"在此添加客队得分" message:@"客队得分包括罚球、两分、三分，如需统计更多客队得分，请到AppStore搜索下载 篮球助手" delegate:self cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
        alertView.tag = AlertViewTagGuestTeamScoreNotice;
        [alertView show];
        return;
        
    }else{
        [self showGuestTeamScoreInput];
    }
}

// 显示客队得分输入界面
- (void)showGuestTeamScoreInput{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"客队得分"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"一分", @"两分", @"三分", nil];
    alertView.tag = AlertViewTagGuestTeamScore;
    [alertView show];
}


#pragma mark - Alert View delegate
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
        // 提示是否进入节间休息的用户反馈处理（发生在单节时间到时）
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            // 确认的话，进入节间休息，否则停留在MatchStatePeriodFinished状态
            _match.state = MatchStateQuarterRestTime;
            [self showTimeoutPrompt:PromptModeQuarterTime];
        }
        
    }else if(alertView.tag == AlertViewTagGuestTeamScore){
        // 添加客队得分
        ActionType type = ActionTypeNone;
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            type = ActionType1Point;
        }else if(buttonIndex == alertView.firstOtherButtonIndex + 1){
            type = ActionType2Points;
        }else if(buttonIndex == alertView.firstOtherButtonIndex + 2){
            type = ActionType3Points;
        }
        
        if (type != ActionTypeNone) {
            [self.match addActionForTeam:self.guestTeam.id forPlayer:nil withAction:type];
            NSString * message = [self messageForTeam:self.guestTeam.name playerId:nil action:type];
            [self showToastPrompt:message];
        }
    }else if(alertView.tag == AlertViewTagGuestTeamScoreNotice){
        [[BCSettings defaultInstance] setGuestTeamAddScroreNoticeFlag:YES];
        self.guestNoticeCircle.hidden = YES;
        [self showGuestTeamScoreInput];
    }
}

// 显示暂停或节间休息子界面
- (void)showTimeoutPrompt:(NSInteger) mode {
    if (_timeoutPromptView == nil) {
        _timeoutPromptView = [[TimeoutPromptView alloc] initWithFrame:CGRectZero];
    }
    
    // 如果使用AutoLayout，必须指定它在父窗口中的位置，需要在添加到父窗口后，手工写constraints
    _timeoutPromptView.frame = CGRectMake(0.0, 0.0, ([UIScreen mainScreen].bounds.size.width), 84.0f);
    _timeoutPromptView.mode = mode;
    [_timeoutPromptView updateLayout];
    [self.view addSubview:_timeoutPromptView];
    [self.view bringSubviewToFront:self.controlButton];
    
    self.controlButton.enabled = NO;
    
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
        self.controlButton.enabled = YES;
    }
}

- (void)promptViewTimeOverNote:(NSNotification *)note{
    if (_match.state == MatchStateQuarterRestTime){
        _match.state = MatchStateQuarterRestTimeFinished;
        if (_match.period == _match.rule.regularPeriodNumber - 1) {
            // 常规比赛时间结束，进入加时赛第一节
            _match.period = MatchPeriodOvertime;
        }else {
            // 进入常规赛下一节
            _match.period ++;
        }
        
        [self resetPeriodCountdownTime:_match.period];
        [self updateCountdownTime];
        [self updateCurrentPeriod];
    }
    
    [_timeoutPromptView updateLayout];
    [self hideTimeoutPromptView];
//    [[SoundManager defaultManager] playHornSound];
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
        [self.controlButton setImage:[UIImage imageNamed:@"game_pause"] forState:UIControlStateNormal];
        [self showToastPrompt:@"开始计时"];
    }else {
        [self.controlButton setImage:[UIImage imageNamed:@"game_start"] forState:UIControlStateNormal];
        [self showToastPrompt:@"暂停计时"];
    }
}

// 合成技术统计提示信息
- (NSString *)messageForTeam:(NSString *)teamName playerId:(NSNumber *)playerId action:(ActionType)action{
    NSString * msg = nil;
    if (playerId != nil) {
        msg = [[PlayerManager defaultManager] playerWithId:playerId].name;
    }else{
        msg = teamName;
    }
    
    msg = [msg stringByAppendingString:@" "];
    msg = [msg stringByAppendingString:[ActionManager descriptionForActionType:action]];
    
    return msg;
}

// 屏幕中间显示定制的提示文字
- (void)showToastPrompt:(NSString *)message{
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.color = [UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90];
    hud.margin = 10.0f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:0.8];
}

- (IBAction)leftButtonClicked:(id)sender{
    // 有节数的话，要显示“结束本节”，否则只显示“结束比赛”
    NSString * otherButton = nil;
    if (_match.state == MatchStatePlaying) {
        otherButton = @"结束本节";
    }
    
    UIActionSheet * ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"结束比赛" otherButtonTitles:otherButton, nil];
    [ac showInView:self.view];
}

// 查看比赛数据
- (IBAction)rightButtonClicked:(id)sender{
    ActionRecordViewController * vc = [[ActionRecordViewController alloc] initWithNibName:@"ActionRecordViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        // 结束比赛
        if ([_match isMatchStart]) {
            // 比赛未正常结束时，由用户选择是否保存比赛数据
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

        
    }else if(actionSheet.firstOtherButtonIndex == buttonIndex){
        // 结束本节，时间退到1秒，updateTimeCountDown会将其减到0
        _match.countdownSeconds = 1;
        [self updateTimeCountDown];

    }else if(actionSheet.firstOtherButtonIndex + 1 == buttonIndex){
        // TODO: 比赛设置
    }
}

@end
