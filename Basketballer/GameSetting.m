//
//  GameSetting.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameSetting.h"

static GameSetting * gameSettings;

@interface GameSetting (){
    NSURL * _documentURL; 
    NSMutableDictionary * _choicesDictionary;
}

@end

@implementation GameSetting

@synthesize dictionaryStore = _dictionaryStore;
@synthesize mode = _mode;
@synthesize gameModeNames = _gameModeNames;
@synthesize quarterLength = _quarterLength;
@synthesize quarterTimeLength = _quarterTimeLength;
@synthesize halfTimeLength = _halfTimeLength;
@synthesize foulsOverQuarterLimit = _foulsOverQuarterLimit;
@synthesize timeoutsOverQuarterLimit = _timeoutsOverQuarterLimit;
@synthesize timeoutLength = _timeoutLength;
@synthesize halfLength = _halfLength;
@synthesize foulsOverHalfLimit = _foulsOverHalfLimit;
@synthesize timeoutsOverHalfLimit = _timeoutsOverHalfLimit;

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
        }
                
        NSArray * _quarterLengthChoices = [NSArray arrayWithObjects:@"10", @"12", nil];
        NSArray * _quarterTimeLengthChoices = [NSArray arrayWithObjects:@"2", @"3", @"4", @"5", nil];
        NSArray * _halfTimeLengthChoices = [NSArray arrayWithObjects:@"5", @"10", @"15", nil];
        NSArray * _foulsOverQuarterLimitChoices = [NSArray arrayWithObjects:@"5", @"6", nil];
        NSArray * _timeoutsOverQuarterLimitChoices = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
        NSArray * _timeoutLengthChoices = [NSArray arrayWithObjects:@"20", @"40", @"60", @"80", nil];
        NSArray * _halfLengthChoices = [NSArray arrayWithObjects:@"20", @"25", @"30", nil];
        NSArray * _foulsOverHalfLimitChoices = [NSArray arrayWithObjects:@"5", @"6", @"7", @"8", nil];
        NSArray * _timeoutsOverHalfLimitChoices = [NSArray arrayWithObjects:@"2", @"3", @"4", @"5", nil];
        
        _choicesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              _quarterLengthChoices, kGameQuarterLength, 
                              _quarterTimeLengthChoices, kGameQuarterTimeLength, 
                              _halfTimeLengthChoices, kGameHalfTimeLength,
                              _foulsOverQuarterLimitChoices, kGameFoulsOverQuarterLimit,
                              _timeoutsOverQuarterLimitChoices, kGameTimeoutsOverQuarterLimit,
                              _timeoutLengthChoices, kGameTimeoutLength,
                              _halfLengthChoices, kGameHalfLength,
                              _foulsOverHalfLimitChoices, kGameFoulsOverHalfLimit,
                              _timeoutsOverHalfLimitChoices, kGameTimeoutsOverHalfLimit,
                              nil];
    }
    
    return self;
}

- (NSArray *)gameModeNames{
    if (_gameModeNames == nil) {
        // TODO loading from multi language file.
        _gameModeNames = [NSArray arrayWithObjects:@"上下半场", @"打满四节", nil];
    }
    
    return _gameModeNames;
}

- (id)parameterForKey:(NSString *)key{
    id parameter = [self.dictionaryStore objectForKey:key];
    if (nil == parameter) {
        // If parameter not set, make the first choice as the default value.
        NSArray * choices = [self choicesForKey:key];
        [self setParameter:[choices objectAtIndex:0] forKey:key];
        
        return [self.dictionaryStore objectForKey:key];
    }else{
        return parameter;
    }
}

+ (id)unitStringForKey:(NSString *)key{
    if ([key isEqualToString:kGameFoulsOverHalfLimit] ||
        [key isEqualToString:kGameFoulsOverQuarterLimit] ||
        [key isEqualToString:kGameTimeoutsOverHalfLimit] ||
        [key isEqualToString:kGameTimeoutsOverQuarterLimit]) {
        return @" 次";
    }else if ([key isEqualToString:kGameTimeoutLength]){
        return @" 秒";
    }else {
        return @" 分钟";
    }
}

- (NSArray *)choicesForKey:(NSString *)key{
    return [_choicesDictionary objectForKey:key];
}

- (void) setParameter:(NSString *)parameter forKey:key{
    if ([key isEqualToString:kGameMode]) {
        [self.dictionaryStore setObject:parameter forKey:key];
    }else{
        NSNumber * number = [NSNumber numberWithInteger:[parameter integerValue]];
        [self.dictionaryStore setObject:number forKey:key];
    }
    
    [self.dictionaryStore writeToURL:[self documentURL] atomically:YES];
}

// All parameters read from dynamic dictionary, not from interface's property storage.

- (NSString *)mode{
    return (NSString *)[self.dictionaryStore objectForKey:kGameMode];
}

- (NSNumber *)quarterLength{
    return [self parameterForKey:kGameQuarterLength];
}

- (NSNumber *)quarterTimeLength{
    return [self parameterForKey:kGameQuarterTimeLength];
}

- (NSNumber *)halfTimeLength{
    return [self parameterForKey:kGameHalfTimeLength];
}

- (NSNumber *)foulsOverQuarterLimit{
    return [self parameterForKey:kGameFoulsOverQuarterLimit];
}

- (NSNumber *)timeoutsOverQuarterLimit{
    return [self parameterForKey:kGameTimeoutsOverQuarterLimit];
}

- (NSNumber *)timeoutLength{
    return [self parameterForKey:kGameTimeoutLength];
}

- (NSNumber *)halfLength{
    return [self parameterForKey:kGameHalfLength];
}

- (NSNumber *)foulsOverHalfLimit{
    return [self parameterForKey:kGameFoulsOverHalfLimit];
}

- (NSNumber *)timeoutsOverHalfLimit{
    return [self parameterForKey:kGameTimeoutsOverHalfLimit];
}


@end
