//
//  LocationManager.h
//  Basketballer
//
//  Created by maoyu on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@protocol LocationManagerDelegate <NSObject>

- (void)receivedLocation:(NSDictionary *) location;

@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>

+ (LocationManager *)defaultManager;

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) CLGeocoder *reverseGeocoder;
@property (nonatomic, strong) id<LocationManagerDelegate> delegate;

- (void)startStandardLocationServcie;
- (void)stopStandardLocationService;

@end
