//
//  MatchManager.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Match.h"

@interface MatchManager : NSObject

@property (nonatomic, strong) NSMutableArray * matchesArray;                // 所有已完成的比赛。
@property (nonatomic, weak) NSManagedObjectContext * managedObjectContext;

+ (MatchManager *)defaultManager;

- (void)loadMatches;
- (Match *)newMatchWithMode:(NSString *)mode;
- (BOOL)deleteMatch:(Match *)match;
- (BOOL)save;

@end
