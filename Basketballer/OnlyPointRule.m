//
//  AccountRule.m
//  Basketballer
//
//  Created by maoyu on 12-10-24.
//
//

#import "OnlyPointRule.h"

@implementation OnlyPointRule

- (NSInteger)regularPeriodNumber{
    return 4;
}

- (NSInteger)timeLengthForPeriod:(MatchPeriod)period{
    return 0;
}

- (NSInteger)restTimeLengthAfterPeriod:(MatchPeriod)period{
    return 60;
}

@end
