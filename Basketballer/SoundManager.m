//
//  SoundManager.m
//  Basketballer
//
//  Created by maoyu on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"
#import <AVFoundation/AVFoundation.h>
#import "GameSetting.h"

static SoundManager * sSoundManager;
#define kSystemSoundID 1013

@interface SoundManager() {
    AVAudioPlayer * _audioPlayer;
}
@end


@implementation SoundManager : NSObject
@synthesize soundFileObject = _soundFileObject;
@synthesize soundFileURLRef = _soundFileURLRef;
@synthesize soundsArray = _soundsArray;
@synthesize backgroundArray = _backgroundArray;

+ (SoundManager *)defaultManager{
    if (nil == sSoundManager) {
        sSoundManager = [[SoundManager alloc] init];
    }

    return sSoundManager;
}

- (id)init{
    if (self = [super init]) {
        /*NSURL * tapSound   = [[NSBundle mainBundle] URLForResource: @"sendmsg"
                                                     withExtension: @"caf"];
        self.soundFileURLRef = (__bridge CFURLRef)tapSound;
        AudioServicesCreateSystemSoundID (self.soundFileURLRef, &_soundFileObject);*/
        
        _soundsArray = [[NSArray alloc] initWithObjects:@"进攻号角",@"We'll Rock You",@"MVP, MVP", nil];
        
        _backgroundArray = [[NSArray alloc] initWithObjects:@"Background1",@"Background2",@"Background3",@"Background4", nil];
    }
    
    return self;
}

- (void)playHornSound {
     //AudioServicesPlayAlertSound (self.soundFileObject);
    if ([GameSetting defaultSetting].enableAutoPromptSound == YES) {
        [self playSoundWithFileName:@"horn"];
    }

    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void)playMatchStartSound {
    if ([GameSetting defaultSetting].enableAutoPromptSound == YES) {
        AudioServicesPlaySystemSound (kSystemSoundID);
    }
}

- (void)playSoundWithFileName:(NSString *)fileName {
    [self stop];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource: fileName
                                           withExtension: @"mp3"];
    NSError  *error;  
    _audioPlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];  
    _audioPlayer.numberOfLoops  = 0;  
    if  (_audioPlayer == nil)  
        NSLog(@"播放失败");  
    else  
        [_audioPlayer  play];  
}

- (void)stop{
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
}

@end
