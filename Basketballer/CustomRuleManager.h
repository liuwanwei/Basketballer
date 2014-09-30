//
//  CustomRuleManager.h
//  Basketballer
//
//  Created by sungeo on 14-9-30.
//
//

#import "BaseManager.h"

@class Rule, FibaCustomRule;

@interface CustomRuleManager : BaseManager

@property (nonatomic, strong) NSMutableArray * rules;

+ (CustomRuleManager *)defaultInstance;

- (void)loadRules;

- (Rule *)customRuleWithFibaRule:(FibaCustomRule *)rule;

@end
