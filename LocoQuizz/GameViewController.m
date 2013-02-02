//
//  GameViewController.m
//  LocoQuizz
//
//  Created by Ariel Elkin on 28/01/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import "GameViewController.h"
#import "GameContentFetcher.h"

@interface GameViewController ()

@property int correctAnswersCount;

@property NSMutableDictionary *venuesDict;
@property NSString *currentVenue;

@property IBOutlet UILabel *questionLabel;
@property IBOutlet UIButton *buttonOne;
@property IBOutlet UIButton *buttonTwo;
@property IBOutlet UIButton *buttonThree;
@property IBOutlet UILabel *resultLabel;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self fetchGameContent];
    
}


-(void)fetchGameContent{
    
    //get the base URL string
    NSString *baseString = @"https://api.foursquare.com/v2/venues/search";
    
    //make our query string
    NSString *queryString = [NSString stringWithFormat:@"?ll=%f,%f", self.userLocation.latitude, self.userLocation.longitude];

    //add teh API Keys
    NSString *apiKeyString = [NSString stringWithFormat:@"&client_id=CPG1OA2FD0OE43PLES4MFOK133GSJADXF3DUMLO4CG0TKOEV&client_secret=30UCWAOGHIVF1C3MSUQ1RNPEUBKO20S01DQCWUQ0LEKCNE4D&v=20130126"];
    
    //concatenate all strings:
    NSString *requestString = [[baseString stringByAppendingString:queryString] stringByAppendingString:apiKeyString];
    
    //    NSLog(@"I got: %@", requestString);
    
    //make a NSURLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    
    //Fetch the data!
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSError *jsonReadingError = nil;
                               NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:kNilOptions error:&jsonReadingError];
                               
//                               NSLog(@"got: %@", json);
                               
                               //get the venue data and send it to createVenuesDict
                               NSDictionary *foursquareResponse = [json valueForKey:@"response"];
                               NSArray *venues = [foursquareResponse valueForKey:@"venues"];                               
                               [self createVenuesDict:venues];
                           }
     ];

}


-(void)createVenuesDict:(NSArray *)allVenues{
    
    self.venuesDict = [NSMutableDictionary dictionary];
    
    //Only get the venues' names and categories
    for(NSDictionary *singleVenue in allVenues){
        NSArray *categories = [singleVenue valueForKey:@"categories"];
        if(categories){
//            NSLog(@"%@ - %@", [venue valueForKey:@"name"], [categories valueForKey:@"name"][0]);
            [self.venuesDict setValue:[categories valueForKey:@"name"][0] forKey:[singleVenue valueForKey:@"name"]];
        }
    }
    
    NSLog(@"venues: %@", self.venuesDict);
    
    [self nextQuestion];
    
}


-(void)nextQuestion{
    
    //get all venue names
    NSArray *venueNames = [NSArray arrayWithArray:[self.venuesDict allKeys]];
    
    //define a venue we want to quizz about:
    self.currentVenue = [venueNames objectAtIndex:arc4random()%venueNames.count];
    
    //define correct answer:
    NSString *rightAnswer = [self.venuesDict valueForKey:self.currentVenue];
    
    //define wrong answers
    NSString *wrongChoiceOne = [self.venuesDict valueForKey:[venueNames objectAtIndex:arc4random()%venueNames.count]];
    NSString *wrongChoiceTwo = [self.venuesDict valueForKey:[venueNames objectAtIndex:arc4random()%venueNames.count]];
    
    NSLog(@"%@ is a %@ but not a %@ nor a %@", self.currentVenue, [self.venuesDict valueForKey:self.currentVenue], wrongChoiceOne, wrongChoiceTwo);
    
    //update the UI
    self.questionLabel.text = [NSString stringWithFormat:@"What is %@?", self.currentVenue];
    
    [self.buttonOne setTitle:[NSString stringWithFormat:@"%@", wrongChoiceOne] forState:UIControlStateNormal];
    [self.buttonTwo setTitle:[NSString stringWithFormat:@"%@", wrongChoiceTwo] forState:UIControlStateNormal];
    [self.buttonThree setTitle:[NSString stringWithFormat:@"%@", rightAnswer] forState:UIControlStateNormal];
    
    [self.resultLabel setText:@" "];
}


-(IBAction)userTappedAnswer:(UIButton *)sender{
    
    //what's the actual correct answer?
    NSString *correctAnswer = [self.venuesDict valueForKey:self.currentVenue];
    
    //check the answer
    if ([sender.titleLabel.text isEqualToString:correctAnswer]) {
        NSLog(@"CORRECT!");
        self.correctAnswersCount++;
        [self.resultLabel setText:[NSString stringWithFormat:@"Correct! You have %d points.", self.correctAnswersCount]];
    }
    else {
        NSLog(@"WRONG!");
        [self.resultLabel setText:@"WRONG!"];
    }
    
    //go to the next question!
    [self performSelector:@selector(nextQuestion) withObject:nil afterDelay:1];
    
}



#pragma mark -
#pragma mark Decorations

//It's better to have another class do the networking, so ask GameContentFetcher for the data!

-(void)fetchGameContent_LONG{
    
    [GameContentFetcher fetchVenuesNear:self.userLocation completionBlock:^(NSJSONSerialization *json, NSError *error) {
        //        NSLog(@"JSON: %@", json);
        NSDictionary *response = [json valueForKey:@"response"];
        NSArray *venues = [response valueForKey:@"venues"];
        for(id venue in venues){
            NSArray *categories = [venue valueForKey:@"categories"];
            if(categories){
                NSLog(@"%@ - %@", [venue valueForKey:@"name"], [[categories valueForKey:@"name"] firstObject]);
            }
        }
    }];
    
}

//Maybe display an image? 
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
