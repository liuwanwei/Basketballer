//
//  BCPlayGameViewController.h
//  Basketballer
//
//  Created by sungeo on 15/3/6.
//
//

#import <UIKit/UIKit.h>
#import "Team.h"
#import "TeamStatistics.h"
#import "MatchUnderWay.h"

@interface BCPlayGameViewController : UIViewController<UIActionSheetDelegate, FoulActionDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView * hostImageView;
@property (nonatomic, weak) IBOutlet UIImageView * guestImageView;
@property (nonatomic, weak) IBOutlet UIImageView * guestNoticeCircle;
@property (nonatomic, weak) IBOutlet UILabel * hostNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * guestNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * gameHostScoreLable;
@property (nonatomic, weak) IBOutlet UILabel * gameGuestScoreLable;
@property (nonatomic, weak) IBOutlet UILabel * gameTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel * gamePeroidLabel;
@property (nonatomic, weak) IBOutlet UIButton * controlButton;

@property (nonatomic, weak) IBOutlet UITableView * tableView;


@property (nonatomic, weak) NSTimer * timeCountDownTimer;
@property (nonatomic, weak) Team * hostTeam;
@property (nonatomic, strong) Team * guestTeam;
@property (nonatomic, weak) TeamStatistics * selectedStatistics;


@end
