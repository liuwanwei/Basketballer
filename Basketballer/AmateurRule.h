//
//  AmateurRule.h
//  Basketballer
//  业余篮球规则，以上下半场为主要特征。
//
//  Created by sungeo on 14-1-13.
//
//

#import "FibaRule.h"

@interface AmateurRule : BaseRule

// 单个比赛单元长度，单位：秒。
@property (nonatomic, assign) NSInteger periodLength;


- (id)initWithMode:(NSString *)mode;

@end
