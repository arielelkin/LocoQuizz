//
//  ViewController.m
//  LocoQuizz
//
//  Created by Ariel Elkin on 28/01/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import "ViewController.h"
#import "GameViewController.h"

@interface ViewController ()

@property CLLocationManager *locationManager;
@property CLLocationCoordinate2D myCoordinate;

@property IBOutlet UIButton *startGameButton;

@end

@implementation ViewController

#pragma mark 1
#pragma mark Init Location Manager
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager setDelegate:self];
    [self.locationManager startUpdatingLocation];

}

#pragma mark 2
#pragma mark Add Location Manager Delegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *lastLocation = [locations lastObject];
    self.myCoordinate = [lastLocation coordinate];
    NSLog(@"new location: %f, %f", self.myCoordinate.latitude, self.myCoordinate.longitude);
    [self.locationManager stopUpdatingLocation];
    [self.startGameButton setEnabled:YES];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"location manager error: %@", error.description);
}

#pragma mark 3
#pragma mark Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"Going into game!");
    GameViewController *gameVC = [segue destinationViewController];
    [gameVC setUserLocation:self.myCoordinate];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
