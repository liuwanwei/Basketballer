//
//  Team.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// TODO id==0 留给默认主队，id==1留给默认客队。所以一开始就要在表中创建默认的主客队记录。

@interface Team : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profileURL;

@end
