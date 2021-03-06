//
//  RalliesViewController.m
//  Devoo
//
//  Created by Sean Crowe on 3/24/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "RalliesViewController.h"
#import "ActivityTableViewCell.h"
#import "RallyContactsTableViewController.h"
#import "webViewController.h"
#import <Mixpanel.h>
#import "AcceptedPeepsTableViewController.h"

@interface RalliesViewController (){
    
    NSMutableArray *selectedActivities;
    NSMutableArray *flippedActivities;
    NSMutableArray *ralliedActivities;
    
    UIButton *rallyFriends;
    UIButton *floatingPlus;
    CGPoint center;
    
    NSMutableArray *userRallies;
    bool rally;
    bool itsAMatch;
    bool shouldWeFlip;
    bool doneLoading;
    bool isActiveRally;
    bool thereAreActiveRallies;
    bool thereAreToday;
    bool thereAreTomorrow;
    bool buttonIsRect;
    int inSectionNum;
    
    
    
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutHeight;

@end
@implementation RalliesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(appHasBecomeActive)
    //                                                 name:UIApplicationWillEnterForegroundNotification
    //                                               object:nil];
    
    self.originalCenter = self.view.center;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    //initialize
    userRallies = [[NSMutableArray alloc] init];
    ralliedActivities = [[NSMutableArray alloc] init];
    inSectionNum = 0;
    
    //added
    _sections = [[NSMutableDictionary alloc] init];
    _sectionToSportTypeMap = [[NSMutableDictionary alloc] init];
    
    
    rally = false;
    thereAreActiveRallies = false;
    thereAreToday = false;
    thereAreTomorrow = false;
    
    
    
    self.title = @"Pick one or more!";
    
    //rally friends
    rallyFriends = [[UIButton alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-40 , self.view.bounds.size.width, 40)];
    [rallyFriends setTitle:@"RALLY FRIENDS" forState:UIControlStateNormal];
    [rallyFriends.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:20.0]];
    rallyFriends.backgroundColor = [UIColor colorWithRed:216/255.0 green:97/255.0 blue:80/255.0 alpha:1]; //d86150
    [rallyFriends addTarget:self action:@selector(rallyFriendsPressed) forControlEvents:UIControlEventTouchUpInside];
    
    //initialize
    selectedActivities = [[NSMutableArray alloc] init];
    flippedActivities = [[NSMutableArray alloc] init];
    
    
    
    //[self loadObjects];
    
    
    
}



- (void)appHasBecomeActive{
    //[self loadObjects];
}

-(void)updateTable{
    [self loadObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //reaload table when you come back from a view
    [self loadObjects];
}

-(void)viewDidAppear:(BOOL)animated{
    //floating plus button Plus-80
    floatingPlus = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 90,self.view.bounds.size.height-15,60, 60)];
    floatingPlus.backgroundColor = [UIColor colorWithRed:216/255.0 green:97/255.0 blue:80/255.0 alpha:1];
    [floatingPlus setTitle:@"+" forState:UIControlStateNormal];
    [floatingPlus.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:50.0]];
    floatingPlus.layer.cornerRadius = floatingPlus.layer.bounds.size.width/2;
    [floatingPlus addTarget:self action:@selector(showCYOViewController) forControlEvents:UIControlEventTouchUpInside];
    floatingPlus.layer.shadowColor = [UIColor blackColor].CGColor;
    floatingPlus.layer.shadowOpacity = 0.8;
    floatingPlus.layer.shadowRadius = 5;
    floatingPlus.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    [self.navigationController.view addSubview:floatingPlus];
    
    center = floatingPlus.center;
    buttonIsRect = false;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:16/255.0 green:165/255.0 blue:192/255.0 alpha:1]; //teal
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [floatingPlus removeFromSuperview];
    //TODO: Animate out
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    //init with coder since we are using storyboards
    self = [super initWithCoder:aCoder];
    if (self) {
        //TODO:
        self.parseClassName = @"Activity";
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
    }
    return self;
}




- (PFQuery *)queryForTable
{
    /////////////////////////////////////////////////
    ///////GET OBJECTS FOR FIRST SECTION/////////////
    /////////////////////////////////////////////////
   
    NSDate *startDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    NSDate *endDate = [calendar dateFromComponents:components];

    
    //startTime
    PFQuery *firstquery = [PFQuery queryWithClassName:self.parseClassName];
    [firstquery whereKey:@"activityStartTime" greaterThanOrEqualTo:startDate];
    [firstquery whereKey:@"activityStartTime" lessThan:endDate];
    [firstquery whereKeyDoesNotExist:@"activityOwner"];
    
    //endTime
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"activityEndTime" greaterThanOrEqualTo:startDate];
    [query whereKey:@"activityEndTime" lessThan:endDate];
    [firstquery whereKeyDoesNotExist:@"activityOwner"];
    
    //user owned activities
    PFQuery *userOwnedActs = [PFQuery queryWithClassName:self.parseClassName];
    [userOwnedActs whereKey:@"activityStartTime" greaterThanOrEqualTo:startDate];
    [userOwnedActs whereKey:@"activityStartTime" lessThan:endDate];
    [userOwnedActs whereKey:@"activityOwner" equalTo:[PFUser currentUser]];
    
    //or query
    PFQuery *orQuery = [PFQuery orQueryWithSubqueries:@[firstquery, query, userOwnedActs]];
    [orQuery orderByAscending:@"activityStartTime"];
    
    return orQuery;
    
}


- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.objects.count == 0) {
        NSLog(@"NO ACTIVITIES ACTIVE");
    }else{
        NSLog(@"ACTIVITIES ACTIVE: %lu", self.objects.count);
        
    }
    
    PFQuery *innerQuery = [PFQuery queryWithClassName:@"Rally"];
    [innerQuery whereKey:@"userObject" equalTo:[PFUser currentUser]];
    [innerQuery includeKey:@"activityObjectsArray"];
    [innerQuery orderByAscending:@"activityStartTime"];
    
    [innerQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        //WE HAVE A LIST OF ALL ACTIVITES FOR TODAY AND TOMORROW ...SELF.OBJECTS
        //WE HAVE A LIST OF RALLIES FOR THE CURRENT USER...OBJECTS
        
        //IF THERE ARE RALLIES FOR THIS USER...THEN GO THROUGH EACH ONE
        //AND GET THE ACTIVITIES FOR THAT RALLY AND SAVE THEM
        if (objects.count > 0) {
            for (PFObject *rallyObj in objects) {
                NSMutableArray *acts = rallyObj[@"activityObjectsArray"];
                [ralliedActivities addObjectsFromArray:acts];
            }
        }
        
        [self.sections removeAllObjects];
        [self.sectionToSportTypeMap removeAllObjects];
        
        NSInteger rowIndex = 0;
        thereAreActiveRallies = false;
        thereAreToday = false;
        thereAreTomorrow = false;
        
        for (PFObject *object in self.objects) {
            //this decides what section the current activity belongs to
            //if the activity is one of our active Rallies, then set section header to 'Rallied Activities'
            
            //assume its not active Rally
            NSString *activityCategory;
            NSString *rallyString = @"Rallied Activities";
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *todayString = [[NSString alloc] init];
            NSString *tomorrowString =[[NSString alloc] init];
            NSString *otherString =[[NSString alloc] init];
            
            isActiveRally = false;
            
            //////
            //go check to see if the current activitiy is an active rally
            //////
            
            for (PFObject *queriedActivity in self.objects) {
                for (PFObject *ralliedActivity in ralliedActivities) {
                    if (ralliedActivity == queriedActivity) {
                        thereAreActiveRallies = true;
                    }
                }
            }
            
            for (PFObject *actObj in ralliedActivities) {
                if (actObj == object) {
                    NSLog(@"active rally");
                    isActiveRally = true;
                    activityCategory = rallyString;
                }
            }
            
            //////
            //let's decide what section it should go in
            //////
            
            if (!isActiveRally){
                NSLog(@"Not a rallied activity");
                
                
                //it can either be in the 'today' OR 'tomorrow' category
                NSDate *startTime = object[@"activityEndTime"];
                NSCalendar *cal = [NSCalendar currentCalendar];
                NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
                NSDate *today = [cal dateFromComponents:components];
                components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:startTime];
                NSDate *otherDate = [cal dateFromComponents:components];
                
                NSDate *tomorrow = [today dateByAddingTimeInterval:1*24*60*60];
                
                if(_selectedTodayFromSegue) {
                    //do stuff
                    NSLog(@"you selected today from segue");
                    todayString = [NSString stringWithFormat:@"Today | %@", [dateFormatter stringFromDate:[NSDate date]]];
                    activityCategory = todayString;
                    thereAreToday = true;
                    
                }else if(_selectedTomorrowFromSegue){
                    NSLog(@"you selected tomorrow from segue");
                    
                    tomorrowString = [NSString stringWithFormat:@"Tomorrow | %@", [dateFormatter stringFromDate:tomorrow]];
                    activityCategory = tomorrowString;
                    thereAreTomorrow = true;
                    
                }else{
                    //you are here b/c the date is not today nor tomorrow but still showed up...must be the weekend!
                    otherString = @"Weekend Events";
                    activityCategory = otherString;
                }
                
            }
            
            
            NSMutableArray *objectsInSection = [self.sections objectForKey:activityCategory];
            if (!objectsInSection) {
                
                objectsInSection = [NSMutableArray array];
                
                //basically, this saying that if the user has active rallies then make sure to put the Rallied Activities
                //section header first (index 0)
                //if there are no active rallies, then put the date section header first.
                if (thereAreActiveRallies) {
                    
                    NSLog(@"there is an active rally out there");
                    
                    int row = (int)self.sectionToSportTypeMap.count;
                    
                    if (todayString == activityCategory) {
                        //you're here because the current activity is today!!
                        NSLog(@"today string is: %@", todayString);
                        
                        if (row == 0) {
                            row++;
                        }
                        
                        [self.sectionToSportTypeMap setObject:todayString forKey:[NSNumber numberWithInt:row++]];
                    }else if (tomorrowString == activityCategory){
                        NSLog(@"tomorrow string is: %@", tomorrowString);
                        
                        if (row == 0) {
                            row++;
                        }
                        
                        [self.sectionToSportTypeMap setObject:tomorrowString forKey:[NSNumber numberWithInt:row++]];
                    }else if(otherString == activityCategory){
                        NSLog(@"other string is: %@", otherString);
                        
                        if (row == 0) {
                            row++;
                        }
                        
                        [self.sectionToSportTypeMap setObject:otherString forKey:[NSNumber numberWithInt:row++]];
                        
                    }else{
                        [self.sectionToSportTypeMap setObject:rallyString forKey:[NSNumber numberWithInt:0]];
                    }
                    
                }else{
                    
                    
                    int row = (int)self.sectionToSportTypeMap.count ;
                    
                    
                    if (todayString == activityCategory) {
                        //you're here because the current activity is today!!
                        NSLog(@"today string is: %@", todayString);
                        [self.sectionToSportTypeMap setObject:todayString forKey:[NSNumber numberWithInt:row++]];
                        
                    }else if (tomorrowString == activityCategory){
                        NSLog(@"tomorrow string is: %@", tomorrowString);
                        [self.sectionToSportTypeMap setObject:tomorrowString forKey:[NSNumber numberWithInt:row++]];
                    }else if(otherString == activityCategory){
                        NSLog(@"other string is: %@", otherString);
                        
                        [self.sectionToSportTypeMap setObject:otherString forKey:[NSNumber numberWithInt:row++]];
                        
                    }
                    
                    
                }
            }
            
            
            
            [objectsInSection addObject:[NSNumber numberWithInt:rowIndex++]];
            [self.sections setObject:objectsInSection forKey:activityCategory];
        }
        
        [self.tableView reloadData];
        
    }];
    
    
    
}


- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sportType = [self sportTypeForSection:indexPath.section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:sportType];
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    return [self.objects objectAtIndex:[rowIndex intValue]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sportType = [self sportTypeForSection:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:sportType];
    return rowIndecesInSection.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sportType = [self sportTypeForSection:section];
    return sportType;
}

#pragma mark - ()

- (NSString *)sportTypeForSection:(NSInteger)section {
    return [self.sectionToSportTypeMap objectForKey:[NSNumber numberWithInt:section]];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:17]];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor colorWithRed:67/255.0 green:161/255.0 blue:187/255.0 alpha:1];
    
    NSString *string =[self sportTypeForSection:section];
    [label setText:string];
    
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]];
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    //BUILD CUSTOM CELL
    ActivityTableViewCell *cell = (ActivityTableViewCell * )[self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[ActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    
    _bottomViewThing.hidden = NO;
    //Get and set image
    PFFile *imageFile = object[@"activityImage"];
    cell.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.backgroundImageView.clipsToBounds = YES;
    cell.backgroundImageView.file = imageFile;
    [cell.backgroundImageView loadInBackground];
    
    
    cell.detailButton.tag = indexPath.row;
    //Build the strings for the labels
    NSString *titleString = [NSString stringWithFormat:@"%@ | %@",object[@"activityType"], object[@"activityName"]];
    
    
    //set the label strings
    cell.typeNameLabel.text = titleString;
    cell.priceLabel.text = object[@"activityCost"];
    cell.timeLabel.text = object[@"activityTime"];
    cell.starButton.selected = [self selectedForIndexPath:indexPath];
    cell.checkMarkImage.hidden = ![self selectedForIndexPath:indexPath];
    cell.specialString = object[@"activitySpecial"];
    
    cell.detailButton.tag = indexPath.row;
    [cell.detailButton addTarget:self action:@selector(rememberWhatWeFlipped:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.hideButton.tag = indexPath.row;
    [cell.hideButton addTarget:self action:@selector(removeWhatWeFlipped:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.webURL.tag = indexPath.row;
    [cell.webURL setTitle:@"Go To Website" forState:UIControlStateNormal];
    if (object[@"urlButtonTitle"]) {
        [cell.webURL setTitle:object[@"urlButtonTitle"] forState:UIControlStateNormal];
    }
    [cell.webURL addTarget:self action:@selector(urlPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if([self shouldWeFlipCell:indexPath]){
        [cell flip];
    }else{
        
    }
    
    
    if (cell.starButton.selected) {
        //teal
        UIColor *teal = [UIColor colorWithRed:67/255.0 green:161/255.0 blue:187/255.0 alpha:1];
        [cell.normalView setBackgroundColor:teal];
        [cell.backgroundImageView.layer setOpacity:0.2];
    }
    
    
    
    //if the current cell is in section 0, then it is an active rally
    //since it's an active rally, we can check to see if there are any responses for it
    if (indexPath.section == 0 && thereAreActiveRallies) {
        
        PFQuery *innerQuery = [PFQuery queryWithClassName:@"Rally"];
        [innerQuery fromLocalDatastore];
        [innerQuery whereKey:@"userObject" equalTo:[PFUser currentUser]];
        [innerQuery whereKey:@"activityObjectsArray" equalTo:object];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Invites"];
        [query fromLocalDatastore];
        [query whereKey:@"rallyObject" matchesQuery:innerQuery];
        [query includeKey:@"contactObject"];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (!error && objects.count > 0) {
                //we've loaded any invites for this activity from the device
                PFQuery *query = [PFQuery queryWithClassName:@"Response"];
                [query whereKey:@"inviteObject" containedIn:objects];
                [query whereKey:@"activityObject" equalTo:object];
                [query whereKey:@"response" equalTo:@"yes"];
                [query includeKey:@"inviteObject"];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable responseObjects, NSError * _Nullable error) {
                    if (!error && responseObjects.count > 0) {
                        //the only thing here using data is getting responses! woot woot toot toot
                        
                        //show ribbon
                        cell.ribbonView.hidden = false;
                        cell.ralliersButton.hidden = false;
                        cell.ralliersButton.titleLabel.adjustsFontSizeToFitWidth = TRUE;
                        
                        
                        //get the contact info for the first invite
                        PFObject *inviteFromResponse = responseObjects[0][@"inviteObject"];
                        PFObject *contactObject = inviteFromResponse[@"contactObject"];
                        
                        
                        NSString *acceptedString;
                        NSString *nameOfFirstAccepted = contactObject[@"contactName"];
                        
                        NSRange whiteSpaceRange = [nameOfFirstAccepted rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
                        if (whiteSpaceRange.location != NSNotFound) {
                            //space is present
                            NSArray* firstLastStrings = [nameOfFirstAccepted componentsSeparatedByString:@" "];
                            NSString* firstName = [firstLastStrings objectAtIndex:0];
                            NSString* lastName = [firstLastStrings objectAtIndex:1];
                            char lastInitialChar = [lastName characterAtIndex:0];
                            NSString* newNameStr = [NSString stringWithFormat:@"%@ %c.", firstName, lastInitialChar];
                            
                            //set string of name
                            nameOfFirstAccepted = newNameStr;
                        }
                        
                        long numberOfAcceptedFriends = responseObjects.count;
                        
                        
                        if (responseObjects.count == 1) {
                            //if only one person accepted "Sean C. is going."
                            acceptedString = [NSString stringWithFormat:@"%@ is down!", nameOfFirstAccepted];
                            
                            
                            
                        }else if (responseObjects.count == 2){
                            //if 2 accepted "Sean C. and 1 other going."
                            acceptedString = [NSString stringWithFormat:@"%@ & 1 other are down!", nameOfFirstAccepted];
                            
                            
                        }else{
                            //if more than 2 accepted "Sean C. and 2 others going.
                            acceptedString = [NSString stringWithFormat:@"%@ & %ld other are down!", nameOfFirstAccepted, numberOfAcceptedFriends-1];
                        }
                        
                        
                        //set text on top of the overlay
                        [cell.ralliersButton setTitle:acceptedString forState:UIControlStateNormal];
                        
                        //we're using a button on top of all uielements on overlay to capture touches
                        cell.ribbonTouchView.tag = indexPath.row;
                        [cell.ribbonTouchView addTarget:self
                                                 action:@selector(ralliersButtonClicked:) forControlEvents:UIControlEventTouchDown];
                        
                    }
                }];
                
            }else{
                PFQuery *innerQuery = [PFQuery queryWithClassName:@"Rally"];
                [innerQuery whereKey:@"userObject" equalTo:[PFUser currentUser]];
                [innerQuery whereKey:@"activityObjectsArray" equalTo:object];
                
                PFQuery *query = [PFQuery queryWithClassName:@"Invites"];
                [query whereKey:@"rallyObject" matchesQuery:innerQuery];
                [query includeKey:@"contactObject"];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    if (!error && objects.count > 0) {
                        //we've loaded any invites for this activity from the device
                        PFQuery *query = [PFQuery queryWithClassName:@"Response"];
                        [query whereKey:@"inviteObject" containedIn:objects];
                        [query whereKey:@"activityObject" equalTo:object];
                        [query whereKey:@"response" equalTo:@"yes"];
                        [query includeKey:@"inviteObject"];
                        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable responseObjects, NSError * _Nullable error) {
                            if (!error && responseObjects.count > 0) {
                                //the only thing here using data is getting responses! woot woot toot toot
                                
                                //show ribbon
                                cell.ribbonView.hidden = false;
                                cell.ralliersButton.hidden = false;
                                cell.ralliersButton.titleLabel.adjustsFontSizeToFitWidth = TRUE;
                                
                                //get the contact info for the first invite
                                PFObject *inviteFromResponse = responseObjects[0][@"inviteObject"];
                                PFObject *contactObject = inviteFromResponse[@"contactObject"];
                                
                                
                                NSString *acceptedString;
                                NSString *nameOfFirstAccepted = contactObject[@"contactName"];
                                
                                NSRange whiteSpaceRange = [nameOfFirstAccepted rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
                                if (whiteSpaceRange.location != NSNotFound) {
                                    //space is present
                                    NSArray* firstLastStrings = [nameOfFirstAccepted componentsSeparatedByString:@" "];
                                    NSString* firstName = [firstLastStrings objectAtIndex:0];
                                    NSString* lastName = [firstLastStrings objectAtIndex:1];
                                    char lastInitialChar = [lastName characterAtIndex:0];
                                    NSString* newNameStr = [NSString stringWithFormat:@"%@ %c.", firstName, lastInitialChar];
                                    
                                    //set string of name
                                    nameOfFirstAccepted = newNameStr;
                                }
                                
                                long numberOfAcceptedFriends = responseObjects.count;
                                
                                
                                if (responseObjects.count == 1) {
                                    //if only one person accepted "Sean C. is going."
                                    acceptedString = [NSString stringWithFormat:@"%@ is down!", nameOfFirstAccepted];
                                    
                                    
                                    
                                }else if (responseObjects.count == 2){
                                    //if 2 accepted "Sean C. and 1 other going."
                                    acceptedString = [NSString stringWithFormat:@"%@ & 1 other are down!", nameOfFirstAccepted];
                                    
                                    
                                }else{
                                    //if more than 2 accepted "Sean C. and 2 others going.
                                    acceptedString = [NSString stringWithFormat:@"%@ & %ld other are down!", nameOfFirstAccepted, numberOfAcceptedFriends-1];
                                }
                                
                                
                                [cell.ralliersButton setTitle:acceptedString forState:UIControlStateNormal];
                                cell.ralliersButton.tag = indexPath.row;
                                [cell.ralliersButton addTarget:self
                                                        action:@selector(ralliersButtonClicked:) forControlEvents:UIControlEventTouchDown];
                                
                            }
                        }];
                    }
                }];
            }
        }];
    }
    
    
    return cell;
    
}

-(bool)selectedForIndexPath:(NSIndexPath *)indexPath{
    
    itsAMatch = false;
    
    for (PFObject *activitySel in selectedActivities) {
        if (activitySel == [self objectAtIndexPath:indexPath]) {
            NSLog(@"EQUALITY!");
            itsAMatch =  true;
            
        }
    }
    
    return itsAMatch;
}

-(void)urlPressed:(UIButton *)button{
    
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    PFObject *act = [self objectAtIndexPath:indexPath];
    NSString *title = act[@"url"];
    [self performSegueWithIdentifier:@"showWeb" sender:title];
    
    
    
    
}

-(bool)shouldWeFlipCell:(NSIndexPath *)indexPath{
    
    shouldWeFlip = false;
    
    
    for (PFObject *activity in flippedActivities) {
        if (activity == [self objectAtIndexPath:indexPath]) {
            shouldWeFlip = true;
        }
    }
    
    return shouldWeFlip;
}

-(void)rememberWhatWeFlipped:(UIButton *)button{
    
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    //TODO: fix
    [flippedActivities addObject:[self objectAtIndexPath:indexPath]];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    PFObject *act = [self objectAtIndexPath:indexPath];
    //TODO:
    [mixpanel track:@"Activity Flipped" properties:@{
                                                     @"actObjectId": act.objectId,
                                                     @"actName": act[@"activityName"]
                                                     }];
    
}

-(void)removeWhatWeFlipped:(UIButton *)button{
    
    
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    [flippedActivities removeObjectIdenticalTo:[self objectAtIndexPath:indexPath]];
    
}

-(void)ralliersButtonClicked:(UIButton*)sender
{
    //show view controller for activity acceptors sender.tag
    [self performSegueWithIdentifier:@"showAccepted" sender:sender];
    floatingPlus.hidden = YES;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ActivityTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell.isFlipped) {
        
        //Toggle the star being filled each tap
        if (cell.starButton.selected == YES) {
            cell.starButton.selected = NO;
            
            //remove from selected array
            [selectedActivities removeObject:[self objectAtIndexPath:indexPath]];
            
            cell.normalView.backgroundColor = [UIColor blackColor];
            [cell.backgroundImageView.layer setOpacity:1];
            cell.checkMarkImage.hidden = YES;
            
        }else{
            //you are here b/c the row is not selected and you are selecting it
            cell.checkMarkImage.hidden = NO;
            
            cell.starButton.selected = YES;
            //add index to array so that we know which events to rally
            [selectedActivities addObject:[self objectAtIndexPath:indexPath]];
            
            
            UIColor *teal = [UIColor colorWithRed:67/255.0 green:161/255.0 blue:187/255.0 alpha:1];
            [cell.normalView setBackgroundColor:teal];
            [cell.backgroundImageView.layer setOpacity:0.2];
            
            //MIXPANEL
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel track:@"Activity Selected"];
        }
        
        [self animateRallyButton];
        
    }
}

#pragma mark - Helper Methods

-(void)animateRallyButton{
    
    
    if (selectedActivities.count == 1) {
        
        if (!buttonIsRect) {
            
            [self changeToSquare];
        }
    }
    
    if (selectedActivities.count == 0) {
        [self changeToCircle];
    }
    
}

-(void)rallyFriendsPressed{
    
    floatingPlus.hidden = YES;
    
    [self performSegueWithIdentifier:@"showContacts" sender:self];
    
    
    //MIXPANEL
    int arrayCount = (int)selectedActivities.count;
    NSNumber *n = [NSNumber numberWithInt:arrayCount];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Rally Friends" properties:@{
                                                  @"Num of Activities": n
                                                  }];
    
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showContacts"]) {
        RallyContactsTableViewController *vc = [segue destinationViewController];
        vc.activitiesArray = [selectedActivities mutableCopy];
        [selectedActivities removeAllObjects];
        
        
    }else if ([segue.identifier isEqualToString:@"showWeb"]) {
        //pass the url
        NSLog(@"sender is: %@", sender);
        NSString *webUrl = sender;
        floatingPlus.hidden = YES;
        webViewController *vc = [segue destinationViewController];
        vc.url = webUrl;
        
        
    }else if ([segue.identifier isEqualToString:@"showAccepted"]) {
        
        AcceptedPeepsTableViewController *vc = [segue destinationViewController];
        UIButton *btn = sender;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[btn tag] inSection:0];
        vc.activityObject = [self objectAtIndexPath:indexPath];
        
    }
    
}

-(void)changeToSquare{
    
    [floatingPlus setTitle:@"" forState:UIControlStateNormal];
    
    //animate the the corner radius
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction     functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSNumber numberWithFloat:floatingPlus.bounds.size.width/2];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.duration = 0.2;
    [floatingPlus.layer setCornerRadius:0.0f];
    [floatingPlus.layer addAnimation:animation forKey:@"cornerRadius"];
    
    //animate the frame
    [UIView animateWithDuration:0.1
                          delay:0.1
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         
                         //SET NEW FRAME SIZE
                         CGRect newFrame =CGRectMake(0,self.view.bounds.size.height+24, self.view.bounds.size.width, 40);
                         [floatingPlus setFrame:newFrame];
                         
                         
                         //REMOVE SELECTOR
                         [floatingPlus removeTarget:nil
                                             action:NULL
                                   forControlEvents:UIControlEventAllEvents];
                         
                         //ADD SELECTOR FOR RALLY FRIENDS
                         [floatingPlus addTarget:self action:@selector(rallyFriendsPressed) forControlEvents:UIControlEventTouchUpInside];
                         
                         
                         
                         //SET FLAG FOR USE WHEN CALLING 'ANIMATERALLYBUTTON;
                         buttonIsRect = true;
                         
                         //LAYOUT
                         [self.view layoutIfNeeded];
                         
                     }
                     completion:^(BOOL finished){
                         
                         
                         NSLog(@"Done!");
                         [floatingPlus setTitle:@"Rally Friends" forState:UIControlStateNormal];
                         [floatingPlus.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:20.0]];
                         
                         
                         
                     }];
    
    
}

-(void)changeToCircle{
    
    [floatingPlus setTitle:@"" forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.1
                          delay:0.1
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         
                         //SET NEW FRAME SIZE
                         CGRect newFrame =CGRectMake(self.view.bounds.size.width - 90,self.view.bounds.size.height-70,60, 60);
                         [floatingPlus setFrame:newFrame];
                         
                         
                         //REMOVE SELECTOR
                         [floatingPlus removeTarget:nil
                                             action:NULL
                                   forControlEvents:UIControlEventAllEvents];
                         
                         //SET THE ORIGINAL CENTER POINT
                         floatingPlus.center = center;
                         
                         //ADD SELECTOR FOR CYO ACTIVITY
                         [floatingPlus addTarget:self action:@selector(showCYOViewController) forControlEvents:UIControlEventTouchUpInside];
                         
                         
                         //ANIMATE THE CORNER RADIUS
                         CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                         animation.timingFunction = [CAMediaTimingFunction     functionWithName:kCAMediaTimingFunctionLinear];
                         animation.fromValue = [NSNumber numberWithFloat:0.0f];
                         animation.toValue = [NSNumber numberWithFloat:floatingPlus.bounds.size.width/2];
                         animation.duration = 0.2;
                         [floatingPlus.layer setCornerRadius:floatingPlus.bounds.size.width/2];
                         [floatingPlus.layer addAnimation:animation forKey:@"cornerRadius"];
                         
                         //SET FLAG FOR USE WHEN CALLING ANIMATERALLYBUTTON
                         buttonIsRect = false;
                         
                         //LAYOUT
                         [self.view layoutIfNeeded];
                         
                     }
                     completion:^(BOOL finished){
                         
                         [floatingPlus setTitle:@"+" forState:UIControlStateNormal];
                         [floatingPlus.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:50.0]];
                         
                     }];
    
}

-(void)showCYOViewController{
    [self performSegueWithIdentifier:@"showCreateYourOwn" sender:self];
}
@end
