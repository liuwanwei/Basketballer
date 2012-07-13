//
//  WEPopoverContentViewController.h
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WEPopoverController.h"

@class OperateGameViewController;


@interface WEPopoverContentViewController : UITableViewController
@property (nonatomic, weak) WEPopoverController * wePopoverController;
@property (nonatomic, weak) OperateGameViewController * opereteGameViewController;

@end
