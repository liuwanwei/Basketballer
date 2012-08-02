//
//  StartMatchView.h
//  Basketballer
//
//  Created by maoyu on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayGameViewController.h"

@interface StartMatchView : UIView

@property (nonatomic, weak) PlayGameViewController * parentController;

- (IBAction)startGame:(UIButton *)sender;

@end
