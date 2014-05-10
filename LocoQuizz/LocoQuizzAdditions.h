//
//  LocoQuizzAdditions.h
//  LocoQuizz
//
//  Created by Ariel Elkin on 28/01/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^FourSquareSearchCompletionBlock)(NSJSONSerialization *json, NSError *error);


@interface LocoQuizzAdditions : NSObject

+(void)fetchVenuesNear:(CLLocationCoordinate2D)currentLocation completionBlock:(FourSquareSearchCompletionBlock)completionBlock;

-(void)displayImageForVenueOfType:(NSString *)venueType;

@end
