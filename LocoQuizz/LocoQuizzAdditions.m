//
//  LocoQuizzAdditions.m
//  LocoQuizz
//
//  Created by Ariel Elkin on 28/01/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import "LocoQuizzAdditions.h"

#define kFourSquareClientID @"CPG1OA2FD0OE43PLES4MFOK133GSJADXF3DUMLO4CG0TKOEV"
#define kFourSquareClientSecret @"30UCWAOGHIVF1C3MSUQ1RNPEUBKO20S01DQCWUQ0LEKCNE4D"


@implementation LocoQuizzAdditions

+(void)fetchVenuesNear:(CLLocationCoordinate2D)currentLocation completionBlock:(FourSquareSearchCompletionBlock)completionBlock{
    
    NSLog(@"yo!, searching for %f, %f", currentLocation.latitude, currentLocation.longitude);

    NSString *baseString = @"https://api.foursquare.com/v2/venues/search";
    
    NSString *queryString = [NSString stringWithFormat:@"?ll=%f,%f", currentLocation.latitude, currentLocation.longitude];
    
    NSString *apiKeyString = [NSString stringWithFormat:@"&client_id=%@&client_secret=%@&v=20130126", kFourSquareClientID, kFourSquareClientSecret];
    
    NSString *requestString = [[baseString stringByAppendingString:queryString] stringByAppendingString:apiKeyString];
    
//    NSLog(@"I got: %@", requestString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSError *jsonReadingError = nil;
                               NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:kNilOptions error:&jsonReadingError];
                               
                               completionBlock(json, error);
                           }
     ];
}

-(void)displayImageForVenueOfType:(NSString *)venueType{
    
    NSString *requestString = [NSString stringWithFormat:@"http://www.reddit.com/search.json?q=site:imgur.com+%@", [venueType stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"request string: %@", requestString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSError *jsonReadingError = nil;
                               NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:kNilOptions error:&jsonReadingError];
                               
                               //                               NSLog(@"got: %@", json);
                               NSDictionary *redditResponse = [json valueForKey:@"data"];
                               NSArray *resultList = [redditResponse valueForKey:@"children"];
                               NSDictionary *result = [resultList objectAtIndex:0];
                               NSString *url = [[result valueForKey:@"data"] valueForKey:@"url"];
                               NSLog(@"image at %@", url);
                               
                           }
     ];
    
}


@end


