//
//  CustomRuleManager.m
//  Basketballer
//
//  Created by sungeo on 14-9-30.
//
//

#import "CustomRuleManager.h"
#import "Rule.h"
#import "FibaCustomRule.h"

#define kCustomRuleEntity       @"Rule"

@implementation CustomRuleManager

+ (instancetype)defaultInstance{
    static CustomRuleManager * sInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sInstance == nil) {
            sInstance = [[CustomRuleManager alloc] init];
        }
    });
    
    return sInstance;
}

// 加载已经保存过的自定义规则
- (void)loadRules{
    NSArray * ret = [super loadWithEntity:kCustomRuleEntity];
    
    if (nil == ret) {
        self.rules = [[NSMutableArray alloc] init];
    }else{
        self.rules = [NSMutableArray arrayWithArray:ret];
    }
}

- (Rule *)customRuleWithFibaRule:(FibaCustomRule *)fibaRule{
    if (fibaRule == nil) {
        return nil;
    }
    
    BOOL newRule = NO;
    if (fibaRule.model == nil) {
        newRule = YES;
    }
    
    Rule * rule = nil;
    if (newRule) {
        // 新建规则
        rule = (Rule *)[NSEntityDescription insertNewObjectForEntityForName:kCustomRuleEntity inManagedObjectContext:self.managedObjectContext];        
        rule.id = [BaseManager generateIdForKey:kCustomRuleEntity];
    }else{
        // 修改规则
        rule = fibaRule.model;
    }
    
    rule.name = fibaRule.name;
    rule.periodTimeLength = fibaRule.periodTimeLength;
    rule.periodRestTimeLength = fibaRule.periodRestTimeLength;
    rule.halfTimeRestLength = fibaRule.halfTimeRestTimeLength;
    rule.overTimeLength = fibaRule.overTimeLength;
    
    if (! [self synchroniseToStore]) {
        return nil;
    }
    
    if (newRule) {
        [self.rules addObject:rule];
    }
    
    return rule;
}

- (BOOL)deleteRule:(Rule *)rule{
    if (! [self deleteFromStore:rule synchronized:YES]) {
        return NO;
    }
    
    [self.rules removeObject:rule];
    
    return YES;
}

@end
