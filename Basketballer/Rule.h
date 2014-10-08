//
//  Rule.h
//  Basketballer
//
//  Created by sungeo on 14-9-30.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Rule : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * periodTimeLength;
@property (nonatomic, retain) NSNumber * periodRestTimeLength;
@property (nonatomic, retain) NSNumber * halfTimeRestLength;
@property (nonatomic, retain) NSNumber * overTimeLength;

@end
