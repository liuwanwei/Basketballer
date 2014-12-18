//
//  Team.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Team : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profileURL;
@property (nonatomic, retain) NSNumber * userDeleted;

@end
