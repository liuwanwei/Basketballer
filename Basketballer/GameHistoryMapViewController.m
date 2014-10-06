//
//  GameHistoriesMapViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameHistoryMapViewController.h"
#import "LocationManager.h"
#import "AppDelegate.h"
#import "MatchManager.h"
#import "MapAnnotation.h"
#import "TeamManager.h"

@interface GameHistoryMapViewController ()

@end

@implementation GameHistoryMapViewController
@synthesize mapView = _mapView;

#pragma  私有函数
- (void)initMapView {
    LocationManager *locationManager = [LocationManager defaultManager];
    [locationManager startStandardLocationServcie];
}

- (void)dismissMyself{
    self.hidesBottomBarWhenPushed = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showLocalMatchs {
    NSArray * matchs = [[MatchManager defaultManager] matchesArray];
    NSInteger size = [matchs count];
    MapAnnotation * ann;
    Match * match;
    Team * team;
    TeamManager * tm = [TeamManager defaultManager];
    CLLocationCoordinate2D coordinate;
    for (NSInteger index = 0; index < size; index++) {
        match = [matchs objectAtIndex:index];
        team = [tm teamWithId:match.homeTeam];
        ann = [[MapAnnotation alloc] init];
        ann.title  = team.name;
        ann.subtitle = [match.homePoints stringValue];
        coordinate.latitude = [match.latitude doubleValue];
        coordinate.longitude = [match.longitude doubleValue];
        ann.coordinate = coordinate;
        [self.mapView addAnnotation:(id)ann];
    }
}

#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"地图模式"];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissMyself)];
    self.navigationItem.leftBarButtonItem = leftItem; 
    
    self.mapView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.mapView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [LocationManager defaultManager].delegate = self;
    
    [self initMapView];
    /*if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"定位" message:@"请开启定位服务" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }*/
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showLocalMatchs];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [LocationManager defaultManager].delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma LocationManager delete
- (void)receivedLocation:(CLLocation *) location {
    /*MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.02;
    theSpan.longitudeDelta = 0.02;
    MKCoordinateRegion theRegion;
    theRegion.center = [location coordinate];
    theRegion.span = theSpan;
    [self.mapView setRegion:theRegion];*/
}

#pragma Map delete
- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation) {
        static NSString *defaultPinID = @"pinID";
        pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:defaultPinID] ;
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.canShowCallout = YES;
        pinView.animatesDrop = NO;
    }
       
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    /*CLLocationCoordinate2D coordinate = userLocation.coordinate;
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.02;
    theSpan.longitudeDelta = 0.02;
    MKCoordinateRegion theRegion;
    theRegion.center = coordinate;
    theRegion.span = theSpan;
    [self.mapView setRegion:theRegion];*/
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    NSString * message = [error description];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"定位" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
@end
