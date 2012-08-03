//
//  MatchUnderWay.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MatchUnderWay.h"
#import "ActionManager.h"

@implementation MatchUnderWay

#define kMatchId                @"MatchId"
#define kHomeTeamPoints         @"HomeTeamPoints"
#define kHomeTeamFouls          @"HomeTeamFouls"
#define kHomeTeamTimeouts       @"HomeTeamTimeouts"
#define kGuestTeamPoints        @"GuestTeamPoints"
#define KGuestTeamFouls         @"GuestTeamFouls"
#define kGuestTeamTimeouts      @"GuestTeamTimeouts"
#define kMatchPeriod            @"MatchPeriod"
#define kMatchState             @"MatchState"
#define kMatchStateFinishingDate @"MatchStateFinishingDate"

+ (NSURL *)documentURL{
    NSURL * _documentURL;
    NSFileManager * fm = [NSFileManager defaultManager];
    NSArray * paths = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    
    NSURL * path = [paths objectAtIndex:0];
    _documentURL = [path URLByAppendingPathComponent:@"MatchUnderWay.dat" isDirectory:NO];
    
    return _documentURL;
}

+ (void)storeUnfinishedMatch:(NSInteger)matchId withStateFinishingDate:(NSDate *)date{
    ActionManager * am = [ActionManager defaultManager];
    
    NSNumber * match = [NSNumber numberWithInteger:matchId];
    
    NSNumber * homeTeamPoints = [NSNumber numberWithInteger:am.homeTeamPoints];
    NSNumber * homeTeamFouls = [NSNumber numberWithInteger:am.homeTeamFouls];
    NSNumber * homeTeamTimeouts = [NSNumber numberWithInteger:am.homeTeamTimeouts];
    
    NSNumber * guestTeamPoints = [NSNumber numberWithInteger:am.guestTeamPoints];
    NSNumber * guestTeamFouls = [NSNumber numberWithInteger:am.guestTeamFouls];
    NSNumber * guestTeamTimeouts = [NSNumber numberWithInteger:am.guestTeamTimeouts];
    
    NSNumber * period = [NSNumber numberWithInteger:am.period];
    NSNumber * state = [NSNumber numberWithInteger:am.state];
    
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                 match, kMatchId,
                                 
                                 homeTeamPoints, kHomeTeamPoints,
                                 homeTeamFouls, kHomeTeamFouls,
                                 homeTeamTimeouts, kHomeTeamTimeouts,
                                 
                                 guestTeamPoints, kGuestTeamPoints,
                                 guestTeamFouls, KGuestTeamFouls,
                                 guestTeamTimeouts, kGuestTeamTimeouts,
                                 
                                 period, kMatchPeriod,
                                 state, kMatchPeriod,
                                 date, kMatchStateFinishingDate, nil];
    [dictionary writeToURL:[self documentURL] atomically:YES];
}

+ (NSInteger)restoreUnfinishedMatch{
    ActionManager * am = [ActionManager defaultManager];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfURL:[self documentURL]];
    
    am.homeTeamPoints = [[dictionary objectForKey:kHomeTeamPoints] integerValue];
    am.homeTeamFouls = [[dictionary objectForKey:kHomeTeamFouls] integerValue];
    am.homeTeamTimeouts = [[dictionary objectForKey:kHomeTeamTimeouts] integerValue];
    
    am.guestTeamPoints = [[dictionary objectForKey:kGuestTeamPoints] integerValue];
    am.guestTeamFouls = [[dictionary objectForKey:KGuestTeamFouls] integerValue];
    am.guestTeamTimeouts = [[dictionary objectForKey:kGuestTeamTimeouts] integerValue];
    
    am.period = [[dictionary objectForKey:kMatchPeriod] integerValue];
    am.state = [[dictionary objectForKey:kMatchState] integerValue];
    
    // TODO check -- copy to make dictionary releaseable.
    am.matchStateFinishingDate = [[dictionary objectForKey:kMatchStateFinishingDate] copy];
    
    return [[dictionary objectForKey:kMatchId] integerValue];
}

@end
