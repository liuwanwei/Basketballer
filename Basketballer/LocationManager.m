//
//  LocationManager.m
//  Basketballer
//
//  Created by maoyu on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LocationManager.h"

static LocationManager * sLocationManager;

@interface LocationManager() {
}
@end

@implementation LocationManager
@synthesize locationManager = _locationManager;
@synthesize delegate = _delegate;

+ (LocationManager *)defaultManager{
    if (nil == sLocationManager) {
        sLocationManager = [[LocationManager alloc] init];
    }
    
    return sLocationManager;
}

- (id)init{
    if (self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = 10;
    }
    
    return self;
}

- (void)startStandardLocationServcie{
    if ([CLLocationManager locationServicesEnabled]) {
         [self.locationManager startUpdatingLocation];
    }
}

- (void)stopStandardLocationService{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSDate * date = newLocation.timestamp;
    NSTimeInterval howRecent = [date timeIntervalSinceNow];
    if (abs(howRecent) < 5) {
        CLLocation * changeLocation = [[CLLocation alloc] initWithLatitude:[newLocation coordinate].latitude - 0.0011 longitude:[newLocation coordinate].longitude + 0.006 ];
        if (_delegate != nil && [_delegate respondsToSelector:@selector(receivedLocation:)]) {
            [_delegate performSelector:@selector(receivedLocation:) withObject:changeLocation];
        }
        [self stopStandardLocationService];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSString * message = [error description];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"定位" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
    [self stopStandardLocationService];
}

@end
