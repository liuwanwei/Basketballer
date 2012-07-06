//
//  Action.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Action : NSManagedObject

@property (nonatomic, retain) NSNumber * match;
@property (nonatomic, retain) NSNumber * team;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * period;

@end
