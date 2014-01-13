//
//  PlaySoundView.m
//  Basketballer
//
//  Created by maoyu on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlaySoundView.h"
#import "SoundManager.h"

@interface PlaySoundView() {
    NSArray * _musicsArray;
}

@end

@implementation PlaySoundView

- (void)initMusicsArray {
    _musicsArray = [NSArray arrayWithObjects:@"mvp",@"horn",@"attack1",@"attack2", nil];
}

- (id)initWithFrame:(CGRect)frame
{
    NSArray * nib =[[NSBundle mainBundle] loadNibNamed:@"PlaySoundView" owner:self options:nil];
    self = [nib objectAtIndex:0];
    self.frame = frame;
    [self initMusicsArray];
    return self;
}

- (IBAction)playSound:(UIButton *)sender {
    NSString  * fileName = [_musicsArray objectAtIndex:sender.tag];
    [[SoundManager defaultManager] playSoundWithFileName:fileName];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = CGRectMake(0.0, 480, 320.0, 460.0);
        self.alpha = 0.8;
    }];
}
@end
