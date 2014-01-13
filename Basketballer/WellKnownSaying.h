//
//  WellKnownSaying.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// "who"必须跟web service返回的json字段名相同。
#define kWhom       @"who"
#define kWords      @"words"
#define kDate       @"date"

#define kNewSayingMessage       @"NewSayingComming"

@interface WellKnownSaying : NSObject <NSURLConnectionDataDelegate>

@property (strong) NSMutableArray * allSayings;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSMutableData * responseData;

+ (WellKnownSaying *)defaultSaying;

- (NSDictionary *)oneSaying;

- (NSDictionary *)lastSaying;

- (void)requestSaying;


@end
