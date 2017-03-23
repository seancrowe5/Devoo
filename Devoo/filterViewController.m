//
//  filterViewController.m
//  Devoo
//
//  Created by Sean Crowe on 3/22/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "filterViewController.h"
#import "activityFeedPFQTViewController.h"
#import <Mixpanel.h>

@interface filterViewController (){
    NSMutableArray *tagArray;
    NSMutableArray *catsSelected;
    bool randomSelected;
    bool recentSelected;


}

@end

@implementation filterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.title = @"What kinda activity?";
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    tagArray = [[NSMutableArray alloc] init];
    catsSelected = [[NSMutableArray alloc] init];
    
    randomSelected = false;
    recentSelected = false;
    
    
    //next button
    [_findNextButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    _findNextButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    _findNextButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    _findNextButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    [_findNextButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0)];
    
    // the space between the image and text
    CGFloat spacing = 6.0;
    
    //dinner
    CGSize imageSize = _dinner.imageView.image.size;
    _dinner.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    CGSize titleSize = [_dinner.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _dinner.titleLabel.font}];
    _dinner.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    //drinks
    imageSize = _drink.imageView.image.size;
    _drink.titleEdgeInsets = UIEdgeInsetsMake(
                                               0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    titleSize = [_drink.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _drink.titleLabel.font}];
    _drink.imageEdgeInsets = UIEdgeInsetsMake(
                                               - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    //sports
    imageSize = _sports.imageView.image.size;
    _sports.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    titleSize = [_sports.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _sports.titleLabel.font}];
    _sports.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    //entertainment
    imageSize = _entertainment.imageView.image.size;
    _entertainment.titleEdgeInsets = UIEdgeInsetsMake(
                                               0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    titleSize = [_entertainment.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _entertainment.titleLabel.font}];
    _entertainment.imageEdgeInsets = UIEdgeInsetsMake(
                                               - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    //cinema
    imageSize = _movies.imageView.image.size;
    _movies.titleEdgeInsets = UIEdgeInsetsMake(
                                                      0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    titleSize = [_movies.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _movies.titleLabel.font}];
    _movies.imageEdgeInsets = UIEdgeInsetsMake(
                                                      - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    //music
    imageSize = _music.imageView.image.size;
    _music.titleEdgeInsets = UIEdgeInsetsMake(
                                               0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    titleSize = [_music.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _music.titleLabel.font}];
    _music.imageEdgeInsets = UIEdgeInsetsMake(
                                               - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    //Arts
    UIImage *image = [[UIImage imageNamed:@"Art"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [_arts setImage:image forState:UIControlStateNormal];
    imageSize = _music.imageView.image.size;
    _arts.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    titleSize = [_arts.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _arts.titleLabel.font}];
    _arts.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    //experiences
    imageSize = _experiences.imageView.image.size;
    _experiences.titleEdgeInsets = UIEdgeInsetsMake(
                                             0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    titleSize = [_experiences.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _experiences.titleLabel.font}];
    _experiences.imageEdgeInsets = UIEdgeInsetsMake(
                                             - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    //deals
    imageSize = _deals.imageView.image.size;
    _deals.titleEdgeInsets = UIEdgeInsetsMake(
                                                    0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    titleSize = [_deals.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _deals.titleLabel.font}];
    _deals.imageEdgeInsets = UIEdgeInsetsMake(
                                                    - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    //new
    imageSize = _recent.imageView.image.size;
    _recent.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    titleSize = [_recent.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _recent.titleLabel.font}];
    _recent.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    //random
    imageSize = _random.imageView.image.size;
    _random.titleEdgeInsets = UIEdgeInsetsMake(
                                               0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    titleSize = [_random.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _random.titleLabel.font}];
    _random.imageEdgeInsets = UIEdgeInsetsMake(
                                               - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    

    
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //set dates here
    activityFeedPFQTViewController *vc = segue.destinationViewController;
    
    if (_selectedToday) {
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:now];
        [components setHour:23];
        [components setMinute:59];
        [components setSecond:59];
        NSDate *endOfToday = [calendar dateFromComponents:components];
        
        //set start/end time
        vc.startDateFromSegue = [NSDate date]; //now
        vc.endDateFromSegue = endOfToday;
        vc.selectedTodayFromSegue = true;
        vc.selectedTags = tagArray;
        vc.randomSelected = randomSelected;
        vc.recentSelected = recentSelected;
        
    }else if (_selectedTomorrow){
        NSDate *tomorrow = [[NSDate date] dateByAddingTimeInterval:1*24*60*60];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:tomorrow];
        [components setHour:0];
        [components setMinute:0];
        [components setSecond:0];
        NSDate *startOfTomorrow = [calendar dateFromComponents:components];
        
        
        [components setHour:23];
        [components setMinute:59];
        [components setSecond:59];
        NSDate *endOfTomrrow = [calendar dateFromComponents:components];
        
        
        vc.startDateFromSegue = startOfTomorrow;
        vc.endDateFromSegue = endOfTomrrow;
        vc.selectedTomorrowFromSegue = true;
        vc.selectedTags = tagArray;
        vc.randomSelected = randomSelected;
        vc.recentSelected = recentSelected;



        
    }else if (_selectedWeekend){
        //if today is Monday@12:00am - friday@11:59am...
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [gregorian setLocale:[NSLocale currentLocale]];
        
        NSDateComponents *nowComponents = [gregorian components:NSCalendarUnitYear | NSCalendarUnitWeekOfYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:today];
        
        [nowComponents setWeekday:6]; //friday
        [nowComponents setHour:12];
        [nowComponents setMinute:0];
        [nowComponents setSecond:0];
        NSDate *theNextFriday = [gregorian dateFromComponents:nowComponents];
        
        [nowComponents setWeekday:1]; //sunday
        [nowComponents setHour:23];
        [nowComponents setMinute:59];
        [nowComponents setSecond:59];
        [nowComponents setWeekOfYear: [nowComponents weekOfYear] + 1]; //Next week
        NSDate *theNextSunday = [gregorian dateFromComponents:nowComponents];
        
        
        //TODO: logic
        //if today is Friday@12:00pm - Sunday@11:59pm
        //show this most recent friday at noon to upcoming sunday at midnight
        
        NSLog(@"sun: %@:", theNextSunday);
        vc.startDateFromSegue = theNextFriday; //noon upcoming friday - midnight sunday
        vc.endDateFromSegue = theNextSunday; //MIDNIGHT SUNDAY OF THIS WEEK
        vc.selectedTags = tagArray;
        vc.randomSelected = randomSelected;
        vc.recentSelected = recentSelected;


    }

    
    
    NSLog(@"ARRAY YOU ARE PASSIING IS: %@", tagArray)
    ;}


- (IBAction)activityButtonPressed:(id)sender {
    
    for (NSString *catTitle in catsSelected) {
        
        NSString *categoryTitle = [NSString stringWithFormat:@"%@ Category Selected", catTitle];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:categoryTitle];
        

        
    }
    
    if (tagArray.count > 0) {
        
      
        [self performSegueWithIdentifier:@"showActivities" sender:self];
    }else{
        //alert
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Check yo' self!"
                                      message:@"Make sure you select a category."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Sounds Good!"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
                                        
                                        
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];


    }
}

- (IBAction)filterSelected:(UIButton *)sender {
    

    if (_nextAnimation.hidden == true) {
        _nextAnimation.hidden = false;
        _nextAnimation.duration = 0.5;
        _nextAnimation.delay    = 0;
        _nextAnimation.type     = CSAnimationTypeSlideUp;
        
        [_nextAnimation startCanvasAnimation];
    }
   

    
    CSAnimationView *animationView;
    
    if (sender.tag == 0) {
        //Grab Dinner
        animationView = _animationView1;
       
    }
    else if (sender.tag == 1) {
        //Drink Up
        animationView = _animationView2;
    }
    else if (sender.tag == 2) {
        //Sports!
        animationView = _animationView3;

    }
    else if (sender.tag == 3) {
        //Entertainment
        animationView = _animationView4;

    }
    else if (sender.tag == 4) {
        //Cinema
        animationView = _animationView5;

    }
    else if (sender.tag == 5) {
        //Great Bands
        animationView = _animationView6;

    }
    else if (sender.tag == 6) {
        //Arts & Culture
        animationView = _animationView7;

    }
    else if (sender.tag == 7) {
        //Experiences
        animationView = _animationView8;

    }
    else if (sender.tag == 8) {
        //Deals
        animationView = _animationView9;

    }
    else if (sender.tag == 9) {
        //New
        animationView = _animationView10;

    }
    else if (sender.tag == 10) {
        //Random
        animationView = _animationView11;

    }

    

    animationView.duration = 0.5;
    animationView.delay    = 0;
    animationView.type     = CSAnimationTypePop;
    
    [animationView startCanvasAnimation];

    if (sender.selected) {
        
        sender.selected = NO;
        [sender setTintColor:[UIColor colorWithRed:172/255.0 green:172/255.0  blue:172/255.0  alpha:1.0]];
        [sender setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        //remove tag to selected array
        //normalize the tag string
        NSString *tagString = [sender.titleLabel.text lowercaseString];
        NSString *stringWithoutChars = [tagString
                                        stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
        NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"! "];
        NSString *strippedString = [[stringWithoutChars componentsSeparatedByCharactersInSet:trim] componentsJoinedByString:@""];
    
        [tagArray removeObject:strippedString];
        
        if ([tagString isEqualToString:@"random"]) {
            randomSelected = NO;
        }
        
        if ([tagString isEqualToString:@"new"]) {
            recentSelected = NO;
        }
        

      
    }else{
        
        //jump
        [catsSelected addObject:sender.titleLabel.text];
        
        //change ui
        sender.selected = YES;
        [sender setTintColor:[UIColor colorWithRed:67/255.0 green:161/255.0 blue:187/255.0 alpha:1]];
        [sender setTitleColor:[UIColor colorWithRed:67/255.0 green:161/255.0 blue:187/255.0 alpha:1] forState:UIControlStateNormal];

        //normalize the tag string
        NSString *tagString = [sender.titleLabel.text lowercaseString];
        NSString *stringWithoutChars = [tagString
                                         stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
        NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"! "];
        NSString *strippedString = [[stringWithoutChars componentsSeparatedByCharactersInSet:trim] componentsJoinedByString:@""];
    
        
        [tagArray addObject:strippedString];
        
        if ([tagString isEqualToString:@"random"]) {
            randomSelected = YES;
        }
        
        if ([tagString isEqualToString:@"new"]) {
            recentSelected = YES;
        }
    
        
    }
    
}


@end
