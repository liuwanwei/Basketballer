//
//  GameHistoriesMapViewController.m
//  Basketballer
//
//  Created by maoyu on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameHistoriesMapViewController.h"
#import "LocationManager.h"
#import "AppDelegate.h"

@interface GameHistoriesMapViewController ()

@end

@implementation GameHistoriesMapViewController
@synthesize mapView = _mapView;

#pragma  私有函数
- (void)initMapView {
    LocationManager *locationManager = [LocationManager defaultManager];
    [locationManager startStandardLocationServcie];
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.02;
    theSpan.longitudeDelta = 0.02;
    MKCoordinateRegion theRegion;
    theRegion.center = [[locationManager.locationManager location] coordinate];
    theRegion.span = theSpan;
    [self.mapView setRegion:theRegion];
}

- (void)dismissMyself{
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    [delegate dismissModelViewController];
}

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
    [self initMapView];
    [self setTitle:@"地图模式"];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissMyself)];
    self.navigationItem.leftBarButtonItem = leftItem; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
