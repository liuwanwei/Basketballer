//
//  TeamStatistics.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionManager.h"

@interface TeamStatistics : NSObject

@property (nonatomic, weak) NSNumber * teamId;
@property (nonatomic) NSInteger points;
@property (nonatomic) NSInteger fouls;
@property (nonatomic) NSInteger timeouts;

- (void)addStatistic:(ActionType)actionType;
- (void)subtractStatistic:(ActionType)actionType;

- (void)clearData;

@end
