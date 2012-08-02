//
//  MapAnnotation.h
//  Basketballer
//
//  Created by maoyu on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface MapAnnotation : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, weak) NSString *title;
@property (nonatomic, weak) NSString *subtitle;
@end
