//
//  MatchUnderWay.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MatchUnderWay : NSObject


+ (void)storeUnfinishedMatch:(NSInteger)matchId withStateFinishingDate:(NSDate *)date;
+ (NSInteger)restoreUnfinishedMatch;// -1代表没有进行中比赛。加载后清空缓存。

@end
