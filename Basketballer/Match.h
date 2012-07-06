//
//  Match.h
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Match : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) NSNumber * homeTeam;
@property (nonatomic, retain) NSNumber * guestTeam;
@property (nonatomic, retain) NSNumber * homePoints;
@property (nonatomic, retain) NSNumber * guestPoints;
@property (nonatomic, retain) NSDate * date;

@end
