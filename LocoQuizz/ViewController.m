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

//This View Controller welcomes the user, and fetches his current location.
//Once the location is fetched, it enables the startGameButton thus letting
//the user go into GameViewController and start the game. 

@interface ViewController() <CLLocationManagerDelegate>
@end

@implementation ViewController {
    CLLocationManager *locationManager;
    CLLocationCoordinate2D myCoordinate;
    IBOutlet UIButton *startGameButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];

}

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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Going into game!");
    GameViewController *gameVC = [segue destinationViewController];
    [gameVC setUserLocation:myCoordinate];
    
}

@end
