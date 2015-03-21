//
//  BCSettings.m
//  Basketballer
//
//  Created by sungeo on 15/3/21.
//
//

#import "BCSettings.h"
#import <TMCache.h>

static NSString * const kGuestTeamPointsNoticeFlag = @"guestTeamPointsNotice";

@implementation BCSettings

+ (instancetype)defaultInstance{
    static BCSettings * sInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sInstance == nil) {
            sInstance = [[BCSettings alloc] init];
        }
    });
    
    return sInstance;
}

- (BOOL)guestTeamAddScroreNoticeFlag{
    NSNumber * value = (NSNumber *)[[TMDiskCache sharedCache] objectForKey:kGuestTeamPointsNoticeFlag];
    return [value boolValue];
}

- (void)setGuestTeamAddScroreNoticeFlag:(BOOL)guestTeamAddScroreNoticeFlag{
    [[TMDiskCache sharedCache] setObject:@(guestTeamAddScroreNoticeFlag) forKey:kGuestTeamPointsNoticeFlag];
}

@end
