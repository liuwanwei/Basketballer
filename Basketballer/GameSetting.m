//
//  GameSetting.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameSetting.h"
#import "AppDelegate.h"

static GameSetting * gameSettings;

@interface GameSetting (){
    NSURL * _documentURL; 
//    NSMutableDictionary * _choicesDictionary;
}

@end

@implementation GameSetting

@synthesize dictionaryStore = _dictionaryStore;
@synthesize gameModes = _gameModes;
@synthesize gameModeNames = _gameModeNames;

+ (GameSetting *)defaultSetting{
    if (gameSettings == nil) {
        gameSettings = [[GameSetting alloc] init];
    }
    
    return gameSettings;
}

- (NSURL *)documentURL{
    if (nil == _documentURL) {
        NSFileManager * fm = [NSFileManager defaultManager];
        NSArray * paths = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        
        NSURL * path = [paths objectAtIndex:0];
        _documentURL = [path URLByAppendingPathComponent:@"GameSettings.dat" isDirectory:NO];
    }    
    
    return _documentURL;
}

- (id) init{
    if (self = [super init]) {
        NSURL * url = [self documentURL];
        _dictionaryStore = [[NSMutableDictionary alloc] initWithContentsOfURL:url];        
        if (nil == _dictionaryStore) {
            _dictionaryStore = [[NSMutableDictionary alloc] init];
            [_dictionaryStore setObject:@(YES) forKey:kHomeTeamPlayerStatistics];
            [_dictionaryStore setObject:@(YES) forKey:kGuestTeamPlayerStatistics];
            [self syncToStore];
            
        }
    }
    
    return self;
}

- (NSArray *)gameModes{
    if (_gameModes == nil) {
        _gameModes = [NSArray arrayWithObjects:kMatchModeFiba, kMatchModeTpb,kMatchModePoints, nil];
    }
    
    return _gameModes;
}

- (NSArray *)gameModeNames{
    if (_gameModeNames == nil) {
        _gameModeNames = [NSArray arrayWithObjects:
                          LocalString(@"Fiba5PlayerMode"),
                          LocalString(@"Fiba3PlayerMode"),
                          LocalString(@"SimpleAccountPlayerMode"),
                          nil];
    }
    
    return _gameModeNames;
}

- (void)syncToStore{
    [self.dictionaryStore writeToURL:[self documentURL] atomically:YES];
}

- (id)parameterForKey:(NSString *)key{
    return [self.dictionaryStore objectForKey:key];
}

- (BOOL)enableHomeTeamPlayerStatistics{
    NSNumber * enabled = [self parameterForKey:kHomeTeamPlayerStatistics];
    return [enabled boolValue];
}

- (BOOL)enableGuestTeamPlayerStatistics{
    NSNumber * enabled = [self parameterForKey:kGuestTeamPlayerStatistics];
    return [enabled boolValue];
}

- (BOOL)enableAutoPromptSound{
    NSNumber * enabled = [self parameterForKey:kAutoPromptSound];
    return [enabled boolValue];
}

- (void)setEnableHomeTeamPlayerStatistics:(BOOL)enablePlayerStatistics{
    NSNumber * number = [NSNumber numberWithBool:enablePlayerStatistics];
    [self.dictionaryStore setObject:number forKey:kHomeTeamPlayerStatistics];
    [self syncToStore];
}

- (void)setEnableGuestTeamPlayerStatistics:(BOOL)enablePlayerStatistics{
    NSNumber * number = [NSNumber numberWithBool:enablePlayerStatistics];
    [self.dictionaryStore setObject:number forKey:kGuestTeamPlayerStatistics];
    [self syncToStore];
}


- (void)setEnableAutoPromptSound:(BOOL)enableAutoPromptSound{
    NSNumber * number = [NSNumber numberWithBool:enableAutoPromptSound];
    [self.dictionaryStore setObject:number forKey:kAutoPromptSound];
    [self syncToStore];
}

- (NSString *)gameModeForName:(NSString *)gameModeName{
    NSArray * names = [self gameModeNames];
    for (int i = 0; i < names.count; i++) {
        if ([[names objectAtIndex:i] isEqualToString:gameModeName]) {
            return [self.gameModes objectAtIndex:i];
        }
    }
    
    return nil;
}

- (NSString *)nameForMode:(NSString *)mode{
    NSArray * modes = self.gameModes;
    for(int i = 0; i < modes.count; i ++){
        if ([[modes objectAtIndex:i] isEqualToString:mode]) {
            return [self.gameModeNames objectAtIndex:i];
        }
    }
    
    return nil;
}


@end
