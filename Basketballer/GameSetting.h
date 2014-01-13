//
//  GameSetting.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// 比赛模式定义。
#define kMatchModeAmateur25             @"Amateur-25"           // 业余：上下半场各25分钟模式。
#define kMatchModeAmateur20             @"Amateur-20"           // 业余：上下半场各20分钟模式。
#define kMatchModeAmateur15             @"Amateur-15"           // 业余：上下半场各15分钟模式。
#define kMatchModeAmateurSimple15       @"AmateurSimple-15"     // 业余：只有一节15分钟模式。
#define kMatchModeFiba                  @"FIBA"                 // FIBA 标准模式。
#define kMatchModeTpb                   @"TPB"                  // FIBA Three player basketball match
#define kMatchModeAccount               @"Account"              // 简单计分模式。


#define kPlayerStatistics               @"PlayerStatistics"
#define kAutoPromptSound                @"AutoPromptSound"

@interface GameSetting : NSObject

// 比赛规则设定通过dictionary保存到文件中。
@property (nonatomic, strong) NSMutableDictionary * dictionaryStore;

// 注意：需要设置、选择比赛模式的界面都要使用这个数组中的内容。
@property (nonatomic, readonly) NSArray * gameModes;
@property (nonatomic, readonly) NSArray * gameModeNames;                  
  

@property (nonatomic) BOOL enablePlayerStatistics;              // 是否开启球员技术统计。
@property (nonatomic) BOOL enableAutoPromptSound;               // 是否开启自动提示声音。

+ (GameSetting *) defaultSetting;

- (id)parameterForKey:(NSString *)key;

- (NSString *)gameModeForName:(NSString *)gameModeName;
- (NSString *)nameForMode:(NSString *)mode;

@end
