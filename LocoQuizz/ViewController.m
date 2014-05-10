//
//  ViewController.m
//  LocoQuizz
//
//  Created by Ariel Elkin on 28/01/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import "ViewController.h"
#import "GameViewController.h"

@import CoreLocation;

@interface ViewController() <CLLocationManagerDelegate>
@end

@implementation ViewController {
    CLLocationManager *locationManager;
    CLLocationCoordinate2D myCoordinate;
    IBOutlet UIButton *startGameButton;
}

#pragma mark 1
#pragma mark Init Location Manager

- (void)viewDidLoad {
    [super viewDidLoad];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];

}

#pragma mark 2
#pragma mark Add Location Manager Delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *lastLocation = [locations lastObject];
    myCoordinate = [lastLocation coordinate];
    [locationManager stopUpdatingLocation];
    startGameButton.enabled = YES;

    NSLog(@"location: %f, %f", myCoordinate.latitude, myCoordinate.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"location manager error: %@", error.description);
}


#pragma mark 3
#pragma mark Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Going into game!");
    GameViewController *gameVC = [segue destinationViewController];
    [gameVC setUserLocation:myCoordinate];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
