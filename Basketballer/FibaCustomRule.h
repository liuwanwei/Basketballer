//
//  FibaCustomRule.h
//  Basketballer
//
//  Created by sungeo on 14-9-30.
//
//

#import "FibaRule.h"


@class Rule;

@interface FibaCustomRule : FibaRule

// 需要序列化保存到NSDictionary中的属性

@property (nonatomic, strong) NSNumber * periodTimeLength;        // 每节比赛时间
@property (nonatomic, strong) NSNumber * periodRestTimeLength;    // 节间休息时间
@property (nonatomic, strong) NSNumber * halfTimeRestTimeLength;  // 半场休息时间
@property (nonatomic, strong) NSNumber * overTimeLength;          // 加时赛时间

// 规则对应的core data对象
@property (nonatomic, strong) Rule * model;

- (instancetype)initWithRuleModel:(Rule *)model;

+ (FibaCustomRule *)objectFromDictionary:(NSDictionary *)dictionary;

@end
