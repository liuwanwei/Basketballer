//
//  Player.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Player : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * team;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * profileURL;
@property (nonatomic, retain) NSString * name;

@end
