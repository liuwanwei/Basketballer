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
#import <TMCache.h>

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

- (NSString *)cacheKeyWithName:(NSString *)name{
    return [NSString stringWithFormat:@"rule-%@", name];
}


- (FibaCustomRule *)customRuleWithName:(NSString *)name{
    FibaCustomRule * rule = nil;
    
    // 先搜索缓存
    TMMemoryCache * cache = [TMMemoryCache sharedCache];
    NSString * key = [self cacheKeyWithName:name];
    rule = [cache objectForKey:key];
    if (rule) {
        return rule;
    }
    
    // 缓存没有时创建
    for (Rule * ruleModel in self.rules) {
        if ([ruleModel.name isEqualToString:name]) {
            rule = [[FibaCustomRule alloc] initWithRuleModel:ruleModel];
            break;
        }
    }

    // 写入缓存
    if (rule) {
        [cache setObject:rule forKey:key];
    }

    return rule;
}


// TODO: 需要注释，否则长久以后看不懂
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
        // 删除缓存的旧规则对象
        [[TMMemoryCache sharedCache] removeObjectForKey:[self cacheKeyWithName:rule.name]];
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
    
    // 更新缓存
    [[TMMemoryCache sharedCache] setObject:fibaRule forKey:[self cacheKeyWithName:fibaRule.name]];
    
    return rule;
}

- (BOOL)deleteRule:(Rule *)rule{
    if (! [self deleteFromStore:rule synchronized:YES]) {
        return NO;
    }
    
    // 清除缓存，如果有的话
    NSString * key = [self cacheKeyWithName:rule.name];
    [[TMMemoryCache sharedCache] removeObjectForKey:key];
    
    [self.rules removeObject:rule];
    
    return YES;
}

@end
