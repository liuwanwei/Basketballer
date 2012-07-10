//
//  OperateGameViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OperateGameViewController : UIViewController

@property (nonatomic) NSInteger teamType; 
@property (nonatomic, weak) IBOutlet UIImageView * teamImageView;
@property (nonatomic, weak) IBOutlet UILabel * teamNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * scoreLabel;
@property (nonatomic, weak) IBOutlet UILabel * timeoutLabel;
@property (nonatomic, weak) IBOutlet UILabel * foulLabel;

- (IBAction)editTeamInfo:(id)sender;
- (IBAction)addScore:(id)sender;
- (IBAction)addTimeOver:(id)sender;
- (IBAction)addFoul:(id)sender;

- (void)setButtonEnabled:(BOOL) enabled;

@end
