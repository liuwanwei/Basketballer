//
//  FibaCustomRule.m
//  Basketballer
//
//  Created by sungeo on 14-9-30.
//
//

#import "FibaCustomRule.h"
#import "Rule.h"

@implementation FibaCustomRule

- (instancetype)initWithRuleModel:(Rule *)model{
    if (self = [super init]) {
        self.name = model.name;
        self.periodTimeLength = model.periodTimeLength;
        self.periodRestTimeLength = model.periodRestTimeLength;
        self.halfTimeRestTimeLength = model.halfTimeRestLength;
        self.overTimeLength = model.overTimeLength;
        self.model = model;
    }
    
    return self;
}

+ (FibaCustomRule *)objectFromDictionary:(NSDictionary *)dictionary{
    return nil;
}

// 每个周期有多长时间，单位（秒），包括加时赛时间。
- (NSInteger)timeLengthForPeriod:(MatchPeriod)period{
    if (period >= MatchPeriodFirst && period <= MatchPeriodFourth) {
        return [self.periodTimeLength integerValue] * 60;
    }else if(period >= MatchPeriodOvertime){
        return [self.overTimeLength integerValue] * 60;
    }else{
        return 0;
    }
}

// 每个周期结束后休息多久，包括加时赛休息时间。
- (NSInteger)restTimeLengthAfterPeriod:(MatchPeriod)period{
    if (period == MatchPeriodFirst ||
        period == MatchPeriodThird ||
        period == MatchPeriodFourth || /* 如果有加时赛的话才休息，否则比赛结束。*/
        period >= MatchPeriodOvertime) {
        return [self.periodRestTimeLength integerValue] * 60;
    }else if(period == MatchPeriodSecond){
        return [self.halfTimeRestTimeLength integerValue] * 60;
    }else{
        return 0;
    }
}

@end
