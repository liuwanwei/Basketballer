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
#define kGameModePoints                 @"Points"

#define kGameHalfLength                 @"HalfLength"
#define kGameHalfTimeLength             @"HalfTimeLength"
#define kGameFoulsOverHalfLimit         @"FoulsOverHalfLimit"
#define kGameTimeoutsOverHalfLimit      @"TimeoutsOverHalfLimit"
#define kGameTimeoutLength              @"TimeoutLength"

#define kGameQuarterLength              @"QuarterLength"
#define kGameQuarterTimeLength          @"QuarterTimeLength"
#define kGameFoulsOverQuarterLimit      @"FoulsOverQuarterLimit"
#define kGameTimeoutsOverQuarterLimit   @"TimeoutsOverQuarterLimit"

#define kGameWinningPoint               @"WinningPoints"
#define kGameFoulsOverWinningPointLimit @"FoulsOverWinningPoints"

@interface GameSetting : NSObject

// 比赛规则设定通过dictionary保存到文件中。
@property (nonatomic, strong) NSMutableDictionary * dictionaryStore;

// 注意：需要设置、选择比赛模式的界面都要使用这个数组中的内容。
// 目前有 “上下半场” 和 “打满四节” 两种模式字符串用于界面显示，数据库内保存kGameModeTwoHalf、kGameModeFourQuarter。
@property (nonatomic, readonly) NSArray * gameModes;
@property (nonatomic, readonly) NSArray * gameModeNames;                  
                                                                    

// 下面是用户通过“设置”界面配置好的比赛参数，分为“四节制参数”，“上下半场制参数”，“公有参数”三个部分。

// 四节制。
@property (nonatomic, strong) NSNumber * quarterLength;                 // 单节时长，单位：分钟。
@property (nonatomic, strong) NSNumber * quarterTimeLength;             // 节间休息时长，单位：分钟。
@property (nonatomic, strong) NSNumber * foulsOverQuarterLimit;         // 单节犯规罚球次数。
@property (nonatomic, strong) NSNumber * timeoutsOverQuarterLimit;      // 单节暂停次数。

// 上下半场制。
@property (nonatomic, strong) NSNumber * halfLength;                    // 半场时长：单位：分钟。
@property (nonatomic, strong) NSNumber * foulsOverHalfLimit;            // 半场犯规罚球次数。
@property (nonatomic, strong) NSNumber * timeoutsOverHalfLimit;         // 半场暂停次数。

// 公有。
@property (nonatomic, strong) NSNumber * halfTimeLength;                // 中场休息时长。单位：分钟。
@property (nonatomic, strong) NSNumber * timeoutLength;                 // 暂停时长，单位：秒。

@property (nonatomic, strong) NSNumber * winningPoints;                 // 获得胜利的分数。
@property (nonatomic, strong) NSNumber * foulsOverWinningPointsLimit;    // 犯规罚球次数。

+ (GameSetting *) defaultSetting;
+ (NSString *)unitStringForKey:(NSString *)key;

- (NSArray *)choicesForKey:(NSString *)key;

- (id)parameterForKey:(NSString *)key;
- (void) setParameter:(NSString *)parameter forKey:key;

- (NSString *)gameModeForName:(NSString *)gameModeName;

@end
