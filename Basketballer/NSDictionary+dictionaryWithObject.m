//
//  NSDictionary+dictionaryWithObject.m
//  Basketballer
//
//  Created by sungeo on 14-9-30.
//
//

#import <objc/runtime.h>
#import "NSDictionary+dictionaryWithObject.h"

@implementation NSDictionary (dictionaryWithObject)

+(NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // 只能获取到类（不包括父类）的属性
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        
        id value = [obj valueForKey:key];
        if (value == nil) {
            value = [NSNull null];
        }
        
        [dict setObject:value forKey:key];
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
