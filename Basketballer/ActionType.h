//
//  ActionType.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// TODO 库为空时，创建默认的action类型记录。

@interface ActionType : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;

@end
