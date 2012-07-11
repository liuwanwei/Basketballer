//
//  PlayGameViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  OperateGameViewController;

@interface PlayGameViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel * gameTimeLable;
@property (nonatomic, weak) IBOutlet UILabel * timeoutTimeLabel;
@property (nonatomic, weak) IBOutlet UIBarButtonItem * playBarItem;
@property (nonatomic, strong) OperateGameViewController * operateGameView1;
@property (nonatomic, strong) OperateGameViewController * operateGameView2;
@property (nonatomic, weak) NSTimer * countDownTimer;
@property (nonatomic, weak) NSTimer * timeoutCountDownTimer;
@property (nonatomic, strong) NSDate * timeoutTargetTime;
@property (nonatomic, strong) NSDate * targetTime;
@property (nonatomic, strong) NSDate * lastTimeoutTime;
@property (nonatomic) NSInteger gameState; 

- (IBAction)startGame:(id)sender;
- (IBAction)stopGame:(id)sender;

@end
