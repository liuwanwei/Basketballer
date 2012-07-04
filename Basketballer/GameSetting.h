//
//  GameSetting.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGameMode                       @"GameMode"
#define kGameModeFourQuarter            @"FourQuarter"
#define kGameModeTwoHalf                @"TwoHalf"

#define kGameHalfLength                 @"HalfLength"
#define kGameHalfTimeLength             @"HalfTimeLength"
#define kGameFoulsOverHalfLimit         @"FoulsOverHalfLimit"
#define kGameTimeoutsOverHalfLimit      @"TimeoutsOverHalfLimit"
#define kGameTimeoutLength              @"TimeoutLength"

#define kGameQuarterLength              @"QuarterLength"
#define kGameQuarterTimeLength          @"QuarterTimeLength"
#define kGameFoulsOverQuarterLimit      @"FoulsOverQuarterLimit"
#define kGameTimeoutsOverQuarterLimit   @"TimeoutsOverQuarterLimit"

@interface GameSetting : NSObject

@property (nonatomic, strong) NSMutableDictionary * dictionaryStore;

@property (nonatomic, strong) NSString * mode;

@property (nonatomic, strong) NSNumber * quarterLength;                 // 单节时长。
@property (nonatomic, strong) NSNumber * quarterTimeLength;             // 节间休息时长。
@property (nonatomic, strong) NSNumber * halfTimeLength;                // 中场休息时长。半场、四节共有属性。
@property (nonatomic, strong) NSNumber * foulsOverQuarterLimit;         // 单节犯规罚球次数。
@property (nonatomic, strong) NSNumber * timeoutsOverQuarterLimit;      // 单节暂停次数。
@property (nonatomic, strong) NSNumber * timeoutLength;                 // 暂停时长。

@property (nonatomic, strong) NSNumber * halfLength;                    // 半场时长。
@property (nonatomic, strong) NSNumber * foulsOverHalfLimit;            // 半场犯规罚球次数。
@property (nonatomic, strong) NSNumber * timeoutsOverHalfLimit;         // 半场暂停次数。

+ (GameSetting *) defaultSetting;
+ (NSString *)unitStringForKey:(NSString *)key;

- (NSArray *)choicesForKey:(NSString *)key;

- (id)parameterForKey:(NSString *)key;
- (void) setParameter:(NSString *)parameter forKey:key;

@end
