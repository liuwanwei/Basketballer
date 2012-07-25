//
//  GameHistoriesMapViewController.h
//  Basketballer
//
//  Created by maoyu on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocationManager.h"

@interface GameHistoriesMapViewController : UIViewController<LocationManagerDelegate,MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView * mapView;

@end
