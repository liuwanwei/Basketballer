//
//  PlayGameViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"
#import <AudioToolbox/AudioToolbox.h>
#import "LocationManager.h"
#import <MapKit/MapKit.h>
@class  OperateGameViewController;

@interface PlayGameViewController : UIViewController <UIAlertViewDelegate,LocationManagerDelegate,MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel * gameTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel * gamePeroidLabel;
@property (nonatomic, weak) IBOutlet UILabel * gameHostScoreLable;
@property (nonatomic, weak) IBOutlet UILabel * gameGuestScoreLable;
@property (nonatomic, weak) IBOutlet UIBarButtonItem * playBarItem;
@property (nonatomic, weak) IBOutlet UIView * gameNavView;
@property (nonatomic, weak) OperateGameViewController * operateGameView1;
@property (nonatomic, weak) OperateGameViewController * operateGameView2;
@property (nonatomic, weak) NSTimer * countDownTimer;
@property (nonatomic, strong) NSDate * targetTime;
@property (nonatomic, strong) NSDate * lastTimeoutTime;
@property (nonatomic) NSInteger gameState; 
@property (nonatomic, weak) Team * hostTeam;
@property (nonatomic, weak) Team * guestTeam;
@property (nonatomic, weak) NSString * gameMode;
@property (nonatomic) NSInteger curPeroid;
@property (nonatomic, readwrite) CFURLRef soundFileURLRef;
@property (nonatomic, readonly) SystemSoundID soundFileObject;
@property (nonatomic, weak) NSDate * timeoutTargetTime;
@property (nonatomic, weak) IBOutlet MKMapView * mapView;


- (IBAction)startGame:(id)sender;
- (IBAction)stopGame:(id)sender;

@end
