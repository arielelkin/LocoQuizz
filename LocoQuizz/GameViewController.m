//
//  GameViewController.m
//  LocoQuizz
//
//  Created by Ariel Elkin on 28/01/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import "GameViewController.h"

@implementation GameViewController {

    IBOutlet UILabel *questionLabel;
    IBOutlet UIButton *buttonOne;
    IBOutlet UIButton *buttonTwo;
    IBOutlet UIButton *buttonThree;
    IBOutlet UILabel *resultLabel;

    int correctAnswersCount;

    NSMutableDictionary *venuesDict;
    NSString *currentVenue;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self fetchGameContent];
}


-(void)fetchGameContent {

    //get the base URL string
    NSString *baseString = @"https://api.foursquare.com/v2/venues/search";

    //make our query string
    NSString *queryString = [NSString stringWithFormat:@"?ll=%f,%f", self.userLocation.latitude, self.userLocation.longitude];

    //add the API Keys
    NSString *apiKeyString = [NSString stringWithFormat:@"&client_id=CPG1OA2FD0OE43PLES4MFOK133GSJADXF3DUMLO4CG0TKOEV&client_secret=30UCWAOGHIVF1C3MSUQ1RNPEUBKO20S01DQCWUQ0LEKCNE4D&v=20130126"];

    //concatenate all strings:
    NSString *requestString = [[baseString stringByAppendingString:queryString] stringByAppendingString:apiKeyString];

    //make a NSURLRequest
    NSURL *venuesRequestURL = [NSURL URLWithString:requestString];

    //Fetch the data!
    NSURLSessionDataTask *venueDataFetcher = [[NSURLSession sharedSession] dataTaskWithURL:venuesRequestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error == nil) {

            NSError *jsonReadingError = nil;
            NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonReadingError];

            if (jsonReadingError) NSLog(@"Problems reading JSON: %@", jsonReadingError.description);

            //get the venue data and send it to createVenuesDict
            NSDictionary *foursquareResponse = [json valueForKey:@"response"];
            NSArray *venues = [foursquareResponse valueForKey:@"venues"];

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self createVenuesDict:venues];
            }];

        }
    }];

    [venueDataFetcher resume];
}


-(void)createVenuesDict:(NSArray *)allVenues {

    venuesDict = [NSMutableDictionary dictionary];

    //Only get the venues' names and categories
    for(NSDictionary *singleVenue in allVenues){
        NSArray *categories = [singleVenue valueForKey:@"categories"];
        if(categories.count > 0){
            [venuesDict setValue:[categories valueForKey:@"name"][0] forKey:[singleVenue valueForKey:@"name"]];
        }
    }
    [self nextQuestion];
}


-(void)nextQuestion {

    //get all venue names
    NSArray *venueNames = [NSArray arrayWithArray:[venuesDict allKeys]];

    //define a venue we want to quizz about:
    currentVenue = [venueNames objectAtIndex:arc4random()%venueNames.count];

    //define correct answer:
    NSString *rightAnswer = [venuesDict valueForKey:currentVenue];

    //define wrong answers
    NSString *wrongChoiceOne = [venuesDict valueForKey:[venueNames objectAtIndex:arc4random()%venueNames.count]];
    NSString *wrongChoiceTwo = [venuesDict valueForKey:[venueNames objectAtIndex:arc4random()%venueNames.count]];

    NSLog(@"%@ is a %@ but not a %@ nor a %@", currentVenue, [venuesDict valueForKey:currentVenue], wrongChoiceOne, wrongChoiceTwo);

    //update the UI
    questionLabel.text = [NSString stringWithFormat:@"What is %@?", currentVenue];

    [buttonOne setTitle:[NSString stringWithFormat:@"%@", wrongChoiceOne] forState:UIControlStateNormal];
    [buttonTwo setTitle:[NSString stringWithFormat:@"%@", wrongChoiceTwo] forState:UIControlStateNormal];
    [buttonThree setTitle:[NSString stringWithFormat:@"%@", rightAnswer] forState:UIControlStateNormal];

    [resultLabel setText:@" "];
}


-(IBAction)userTappedAnswer:(UIButton *)sender {

    //what's the actual correct answer?
    NSString *correctAnswer = [venuesDict valueForKey:currentVenue];

    //check the answer
    if ([sender.titleLabel.text isEqualToString:correctAnswer]) {
        NSLog(@"CORRECT!");
        correctAnswersCount++;
        [resultLabel setText:[NSString stringWithFormat:@"Correct! You have %d points.", correctAnswersCount]];
    }
    else {
        NSLog(@"WRONG!");
        [resultLabel setText:@"WRONG!"];
    }
    
    //go to the next question!
    [self performSelector:@selector(nextQuestion) withObject:nil afterDelay:1];
}

@end
