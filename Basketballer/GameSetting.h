//
//  GameSetting.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMatchModeFiba                  @"FIBA"
#define kMatchModeTpb                   @"TPB" // Three player basketball match
#define kMatchModeAccount               @"Account"
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
