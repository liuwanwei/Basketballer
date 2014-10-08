//
//  NSDictionary+dictionaryWithObject.h
//  Basketballer    将NSObject序列化为NSDictionary对象，属性名字作为Key
//
//  Created by sungeo on 14-9-30.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (dictionaryWithObject)

+(NSDictionary *) dictionaryWithPropertiesOfObject:(id) obj;

@end
