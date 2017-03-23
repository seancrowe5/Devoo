//
//  activityFeedPFQTViewController.m
//  Devoo
//
//  Created by Sean Crowe on 2/6/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "RalliedActivitiesViewController.h"
#import "RallyContactsTableViewController.h"
#import "webViewController.h"
#import <Mixpanel.h>
#import "AcceptedPeepsTableViewController.h"
#import "SCCollectionReusableView.h"




@interface RalliedActivitiesViewController (){
    
    //new
    NSMutableArray *allUsersRallies;
    NSMutableArray *allUsersActs;
    NSMutableArray *actResponsesArray;
    NSMutableDictionary *actResponsesDict;
    NSMutableDictionary *actNumInvitesDict;
    NSMutableDictionary *selContactForAct;
    NSMutableDictionary *activityResponsesDict;


    

    NSMutableArray *blurredCell;
    NSMutableArray *selectedActivities;
    NSMutableArray *flippedActivities;
    NSMutableArray *ralliedActivities;
    NSMutableArray *responseObjectsArray;


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
    
    int yes;
    int no;
    int idk;
    
    NSDate *today;
    
    
    
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutHeight;

@end
@implementation RalliedActivitiesViewController


- (id)initWithCoder:(NSCoder *)aCoder
{
    NSLog(@"INIT WITH CODER");
    
    //init with coder since we are using storyboards
    self = [super initWithCoder:aCoder];
    if (self) {
        //TODO:
        actResponsesArray = [[NSMutableArray alloc] init];
        actResponsesDict = [[NSMutableDictionary alloc] init];
        actNumInvitesDict = [[NSMutableDictionary alloc] init];
        activityResponsesDict = [[NSMutableDictionary alloc] init];
        selContactForAct = [[NSMutableDictionary alloc] init];
        blurredCell = [[NSMutableArray alloc] init];

        self.parseClassName = @"Activity";
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        today = [[NSDate alloc] init];
        today = [NSDate date];
        //today = [today dateByAddingTimeInterval:4*24*60*60]; //set the 'today' for the activities bell feed
    }
    return self;
}

- (PFQuery *)queryForTable
{
    
    NSLog(@"QUERY FOR TABLE");
    
    allUsersActs = [[NSMutableArray alloc] init];
    allUsersRallies = [[NSMutableArray alloc] init];
    
    PFQuery *queryd = [PFQuery queryWithClassName:@"Rally"];
    [queryd whereKey:@"userObject" equalTo:[PFUser currentUser]];
    [queryd includeKey:@"activityObjectsArray"];
    [queryd orderByAscending:@"activityStartTime"];
    
    allUsersRallies = [[queryd findObjects] mutableCopy];
    
    for (PFObject *rallyobj in allUsersRallies) {
        
        NSArray *act = rallyobj[@"activityObjectsArray"];
        [allUsersActs addObjectsFromArray:act];
        
    }
    

    /////////////////////////////////////////////////
    ///////GET OBJECTS FOR FIRST SECTION/////////////
    /////////////////////////////////////////////////
    
    //startTime
    PFQuery *firstquery = [PFQuery queryWithClassName:self.parseClassName];
    [firstquery whereKey:@"activityStartTime" greaterThanOrEqualTo:today];
    [firstquery whereKeyDoesNotExist:@"activityOwner"];
    
    //endTime
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"activityEndTime" greaterThanOrEqualTo:today];
    [firstquery whereKeyDoesNotExist:@"activityOwner"];
    
    //user owned activities
    PFQuery *userOwnedActs = [PFQuery queryWithClassName:self.parseClassName];
    [userOwnedActs whereKey:@"activityStartTime" greaterThanOrEqualTo:today];
    [userOwnedActs whereKey:@"activityOwner" equalTo:[PFUser currentUser]];
    
    //or query
    PFQuery *orQuery = [PFQuery orQueryWithSubqueries:@[firstquery, query, userOwnedActs]];
    [orQuery orderByAscending:@"activityStartTime"];
    [orQuery fromLocalDatastore];
    
    return orQuery;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VIEW DID LOAD");
    
    
    //check user defaults to see if we've shown them the location permission page before
    BOOL userShownPerm = [[NSUserDefaults standardUserDefaults] boolForKey:@"shownPermission"];
    
    //if we haven't
    if (!userShownPerm) {
        //then show it!
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"locationPermission"];
        [self.navigationController presentViewController:ivc animated:YES completion:nil];
        
    }

    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];

    
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
    
    
    
    self.title = @"Your Rallies";
    
    //initialize
    selectedActivities = [[NSMutableArray alloc] init];
    flippedActivities = [[NSMutableArray alloc] init];
    
    

}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"VIEW WILL APPEAR");
    
    [super viewWillAppear:animated];
    //reaload table when you come back from a view
    //[self loadObjects];
}

- (void)appHasBecomeActive{
    NSLog(@"APP HAS BECOME ACTIVE");

    //[self loadObjects];
}

-(void)updateTable{
    NSLog(@"UPDATE TABLE");

    [self loadObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"VIEW DID APPEAR");

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:16/255.0 green:165/255.0 blue:192/255.0 alpha:1]; //teal

}


- (void)objectsDidLoad:(NSError *)error {
    NSLog(@"OBJECTSE DID LOAD");

    [super objectsDidLoad:error];
    
    //new way testing
    int rowIndex = 0;
    
    //clear out dictionary each time data loads
    [activityResponsesDict removeAllObjects];
    
    //loop through each activity
    for (PFObject *activityObject in self.objects) {
        //loop through each rallyArray
        for (PFObject *userRally in allUsersRallies) {
            //get the activities for this rally
            NSArray *ralliesActs = userRally[@"activityObjectsArray"];
            //loop through each activity in this rally
            for (PFObject *activity in ralliesActs) {
                //see if the current outside activity exists in this array
                if (activityObject == activity) {
                    
                    //declare the array's for response types
                    NSMutableArray *yesArray = [[NSMutableArray alloc] init];
                    NSMutableArray *noArray = [[NSMutableArray alloc] init];
                    NSMutableArray *idkArray = [[NSMutableArray alloc] init];

                    //declare array to store this activities responses in
                    //this makes sure it's cleared out with every activity we loop through
                    NSMutableArray *activityResponesArray = [[NSMutableArray alloc] init];
                    
                    PFQuery *query = [PFQuery queryWithClassName:@"Invites"];
                    [query fromLocalDatastore];
                    [query whereKey:@"rallyObject" equalTo:userRally];
                    [query includeKey:@"contactObject"];
                    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                        
                        if (!error && objects.count > 0) {
                            //we found some responses for THIS activity
                            NSMutableArray *allInvities = [[NSMutableArray alloc] init];
                            allInvities = [objects mutableCopy];
                            for (PFObject *invite in allInvities) {
                                int i = 0;
                                //get response object
                                PFQuery *query = [PFQuery queryWithClassName:@"Response"];
                                [query whereKey:@"inviteObject" equalTo:invite];
                                PFObject *resObject = [[PFObject alloc] initWithClassName:@"Response"];
                                resObject = [query getFirstObject];
                                
                                if(resObject){
                                    if ([resObject[@"response"] isEqualToString:@"yes"]) {
                                        [yesArray addObject:invite];
                                    }else if ([resObject[@"response"] isEqualToString:@"no"]) {
                                        [noArray addObject:invite];
                                    }
                                }else{
                                    [idkArray addObject:invite];
                                }

                                i++;
                            }//end for allInvites
                            
                            //we're now done looping through each invite from this rally
                            //let's store the yes/no/idk array's in the parent activityResponsesArray
                            [activityResponesArray insertObject:yesArray atIndex:0];
                            [activityResponesArray insertObject:noArray atIndex:1];
                            [activityResponesArray insertObject:idkArray atIndex:2];
                        }
                        
                        //before we move on to the next activity in the loop
                        //let's add the activity Response aRray to the dictionary for later use
                        [activityResponsesDict setValue:activityResponesArray forKey:activityObject.objectId];
                        [self.tableView reloadData];
                    }];
                }
            }//end loop through rallied activitie
        }
        rowIndex++;
    }
    
    [self.tableView reloadData];
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"NUMBER SECTIONS IN TABLE");

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"NUMBER OR ROWS IN SECTION:");

//    NSString *sportType = [self sportTypeForSection:section];
//    NSArray *rowIndecesInSection = [self.sections objectForKey:sportType];
    return self.objects.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSLog(@"TITLE FOR HEADER IN SECTION");
//
//    //NSString *sportType = [self sportTypeForSection:section];
//    return @"here";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    //get the current activity object so we can get the right data from the dictionary
    PFObject *currentAct = [self.objects objectAtIndex:indexPath.row];
    
    //get the activity responses array from the activityresponsedict dictionary
    NSArray *responseTypesArray =  [activityResponsesDict valueForKey:currentAct.objectId];
    
    int numRows=0;
    
    for (NSArray *responses in responseTypesArray) {
        NSInteger numResponses = responses.count;
        
        if (numResponses > 0 && numResponses < 5) {
            numRows++;
        }
        
        if (numResponses > 4  && numResponses < 8) {
            numRows+=2;
            
        }
    }
    
    //default size with no rows is 420...for each row add 50 pts
    
    return 435.0 + (numRows * 50.0);
}

#pragma mark - ()

//- (NSString *)sportTypeForSection:(NSInteger)section {
//    NSLog(@"SPORT TYPE FOR SECTION");
//
//    return @"";
//}

//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
//    [label setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:17]];
//    label.backgroundColor = [UIColor whiteColor];
//    label.textColor = [UIColor colorWithRed:67/255.0 green:161/255.0 blue:187/255.0 alpha:1];
//    
//    NSString *string =[self sportTypeForSection:section];
//    [label setText:string];
//    
//    [view addSubview:label];
//    [view setBackgroundColor:[UIColor whiteColor]];
//    return view;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{

    self.tableView.backgroundColor = [UIColor blackColor];
    
    //BUILD CUSTOM CELL
    RallyTableViewCell *cell = (RallyTableViewCell * )[self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[RallyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    
    _bottomViewThing.hidden = NO;
    //Get and set image
    PFFile *imageFile = object[@"activityImage"];
    cell.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.backgroundImageView.clipsToBounds = YES;
    
    if (imageFile) {
        cell.backgroundImageView.file = imageFile;
        [cell.backgroundImageView loadInBackground];
    }else{
        cell.backgroundImageView.image = [UIImage imageNamed:@"background-default"];
    }
    
    
    //cell.detailButton.tag = indexPath.row;
    //Build the strings for the labels
    NSString *titleString = [NSString stringWithFormat:@"%@",object[@"activityName"]];
    
    
    //set the label strings
    cell.typeNameLabel.text = titleString;
    cell.priceLabel.text = object[@"activityCost"];
    cell.timeLabel.text = object[@"activityTime"];
    [cell.rallyButton setTitle:object[@"urlButtonTitle"] forState:UIControlStateNormal];
    cell.specialLabel.text = object[@"activitySpecial"];
    
    cell.startChatButton.tag = indexPath.row;
    [cell.startChatButton addTarget:self
                             action:@selector(rallyFriendsPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    
    //DISTANCE//
    if (object[@"venueLocationPoint"]) {
        PFGeoPoint *activityPoint = object[@"venueLocationPoint"];
        PFGeoPoint *userPoint  = [PFUser currentUser][@"recentLocation"];
        
        double distanceDouble  = [userPoint distanceInMilesTo:activityPoint];
        int distanceInt = (int)distanceDouble;
        NSNumber *intNumber = [NSNumber numberWithInteger:distanceInt];
        NSString *milesString = [NSString stringWithFormat:@"%@ mi", intNumber];
        cell.locationLabel.text = milesString;
        cell.locationLabel.hidden = false;
        

    }else{
        cell.locationLabel.text = @"";
        cell.locationLabel.hidden = true;
    }
    
    //end distance//

    [cell.infoButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.infoButton.tag = indexPath.row;
    
    if ([self blurredImageForCellAt:object]) {
        //supposed to be blured
        cell.blurEffectView.alpha = 1.0;
        cell.specialLabel.alpha = 1.0;
        cell.rallyButton.alpha = 1.0;
        
        cell.typeNameLabel.alpha = 0.0;
        cell.priceLabel.alpha = 0.0;
        cell.timeLabel.alpha = 0.0;
        NSLog(@"you are so fucking good dooooood");
        
    }
    return cell;
    
}


-(bool)blurredImageForCellAt:(PFObject *)activityObject{

    //check to see if the index we are currently building is in the blurredArray
    
    for (NSString *actObj in blurredCell) {
        if ([activityObject.objectId isEqualToString:actObj]) {
            
            //it is supposed to be blurred!
            return true;
        }
    }
    
    
    return false;
}


-(void)infoButtonPressed:(UIButton *)sender{
    //ui changes happen in the custom cell headers
    //track which cells to keep bulurred here though
    NSLog(@"you are trying to add a blurrrrr");
    //check if in there already
    
    PFObject *actObject = self.objects[sender.tag];
    bool blurred = false;
   
    for (NSString *actObj in blurredCell) {
        if ([actObject.objectId isEqualToString:actObj]) {
            //already exists...so take it out
            [blurredCell removeObjectIdenticalTo:actObject.objectId];
            blurred = true;
        }
    }
    
    if (!blurred) {
        [blurredCell addObject:actObject.objectId];
    }
    
    NSLog(@"blurred cell is: %@", blurredCell);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"DID SELECT ROW AT INDEX PATH");

    
    RallyTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
//    if (!cell.isFlipped) {
//        
//        //Toggle the star being filled each tap
//        if (cell.starButton.selected == YES) {
//            
//            //remove from selected array
//            [selectedActivities removeObject:[self objectAtIndexPath:indexPath]];
//            
//            cell.normalView.backgroundColor = [UIColor blackColor];
//            [cell.backgroundImageView.layer setOpacity:1];
//            
//        }else{
//            //you are here b/c the row is not selected and you are selecting it
//            
//            //add index to array so that we know which events to rally
//            [selectedActivities addObject:[self objectAtIndexPath:indexPath]];
//                        
//            //MIXPANEL
//            Mixpanel *mixpanel = [Mixpanel sharedInstance];
//            [mixpanel track:@"Activity Selected"];
//        }
//        
//        
//    }
}

#pragma mark - Helper Methods


-(void)rallyFriendsPressed:(UIButton *)sender{
    NSLog(@"RALLY FRIENDS BUTTON PRESSED:");

    //get activity object based on the button tag
    PFObject *act = [self.objects objectAtIndex:sender.tag];
    
    //get selected invites array for this activity
    NSArray *invitesArray = [selContactForAct objectForKey:act.objectId];
    NSMutableArray *numbersArray = [[NSMutableArray alloc] init];
    
    if (invitesArray) {
        NSLog(@"exists");
        for (PFObject *invite in invitesArray) {
            NSLog(@"invites is:%@", invite);
            PFObject *contact = invite[@"contactObject"];
            NSString *phone = contact[@"contactPhone"];
            
            [numbersArray addObject:phone];
            
        }
        
        
        
    }
    
    [self showSMS:numbersArray];
    
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
        //NSLog(@"sender is: %@", sender);
        NSString *webUrl = sender;
        webViewController *vc = [segue destinationViewController];
        vc.url = webUrl;
        
        
    }else if ([segue.identifier isEqualToString:@"bellToChat"]) {
        
        AcceptedPeepsTableViewController *vc = [segue destinationViewController];
        UIButton *btn = sender;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[btn tag] inSection:0];
        vc.activityObject = [self objectAtIndexPath:indexPath];
        
    }
    
}


- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{

    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

#pragma mark - Collection Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 3;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    SCCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"sectionHeader" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        headerView.headerLabel.text = @"Accepted";
    }
    
    if (indexPath.section == 1) {
        headerView.headerLabel.text = @"Declined";
    }
    
    if (indexPath.section == 2) {
        headerView.headerLabel.text = @"Unanswered";
    }
    
    return headerView;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    //get the current activity object so we can get the right data from the dictionary
    PFObject *currentAct = [self.objects objectAtIndex:[(AFIndexedCollectionView *)collectionView indexPath].row];
    
    //get the activity responses array from the activityresponsedict dictionary
    NSArray *responseTypesArray =  [activityResponsesDict valueForKey:currentAct.objectId];
    
    //get responesArray from activityResponsesArray[index]
    NSArray *responseArray = responseTypesArray[section];
    
    //return count of responseArray
    return responseArray.count;

}


-(bool)selectedContactatIndex:(NSIndexPath *)indexpPath activityObject:(PFObject *)activity inviteObject:(PFObject *)inviteObj {
    
    //get the appropriate array of responses based on the activity object passed
    NSArray *invitesArray = [selContactForAct valueForKey:activity.objectId];
   
    
    for (PFObject *invite in invitesArray) {
        if (invite == inviteObj) {
            //Wooooooooo
            return true;
        }
    }
    
    
    return false;
    
}


-(UICollectionViewCell *)collectionView:(AFIndexedCollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    //ui
    cell.initialView.layer.cornerRadius = 20.0;

    //get the current activity object so we can get the right data from the dictionary
    PFObject *currentAct = [self.objects objectAtIndex:[(AFIndexedCollectionView *)collectionView indexPath].row];
    
    //get the activity responses array from the activityresponsedict dictionary
    NSArray *responseTypesArray =  [activityResponsesDict valueForKey:currentAct.objectId];
    
    //get responesArray from activityResponsesArray[index]
    NSArray *responseArray = responseTypesArray[indexPath.section];
    
    //get invite object from array
    PFObject *inviteObject = responseArray[indexPath.row];
    
    
    if([self selectedContactatIndex:indexPath activityObject:currentAct inviteObject:inviteObject]){
        NSLog(@"FUCK YES SEAN YOU ROCK");
        
        //cell is selected
        cell.initialView.backgroundColor = [UIColor colorWithRed:67/255.0 green:161/255.0 blue:187/255.0 alpha:1]; //teal
        cell.nameLabel.textColor = [UIColor colorWithRed:67/255.0 green:161/255.0 blue:187/255.0 alpha:1];
        cell.initialView.tag = 1; //set to 1 as selected
    }
    
    
    
    
    //get contact object from intive
    PFObject *contactObject = inviteObject[@"contactObject"];

    //get the name from contact object
    NSString *name = contactObject[@"contactName"];
    
    // Create array of words in string...
    NSArray *words = [name componentsSeparatedByString:@" "];
    
    // Create array to hold first letter of each word...
    NSMutableArray *firstLetters = [NSMutableArray arrayWithCapacity:[words count]];
    
    // Iterate through words and add first letter of each word to firstLetters array...
    for (NSString *word in words) {
        if ([word length] == 0) continue;
        [firstLetters addObject:[word substringToIndex:1]];
    }
    
    // Join the initials letter error into a single string...
    NSString *acronym = [[firstLetters componentsJoinedByString:@""] uppercaseString];
    
    cell.initialLabel.text = acronym;
    
    
    //add built string to the intialLabel text
    
    //set label to name
    cell.nameLabel.text = name;
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(RallyTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    NSInteger index = cell.collectionView.indexPath.row;
    
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
    
    
    
}


-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(RallyTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat horizontalOffset = cell.collectionView.contentOffset.x;
    NSInteger index = cell.collectionView.indexPath.row;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  
    //make new rallytableview cell object
    //set the content view
    RallyTableViewCell *parentCell = (RallyTableViewCell *)collectionView.superview.superview;
    UICollectionView *curCollectionView =  parentCell.collectionView;

    //get cell selected
    SCCollectionViewCell *cell = (SCCollectionViewCell *)[curCollectionView cellForItemAtIndexPath:indexPath];
    
    NSLog(@"You selected a contact: %@", cell);
    NSLog(@"You selected a contact: %@", cell.nameLabel.text);


    //create array to hold the selected object
    NSMutableArray *invitesArray = [[NSMutableArray alloc] init];
    
    //get the selected activity
    PFObject *currentAct = [self.objects objectAtIndex:[(AFIndexedCollectionView *)collectionView indexPath].row];
    
    //get the invite object
    NSArray *responseTypesArray =  [activityResponsesDict valueForKey:currentAct.objectId];
    NSArray *responseArray = responseTypesArray[indexPath.section];
    PFObject *inviteObject = responseArray[indexPath.row];

    //get color of the view...will determine if selected..i know thats lame
    bool isSelected = false;
    
    
    //if cell is NOT already selected
    if(cell.initialView.tag == 0){
        //change tag to 1 indicating selcected
        cell.initialView.tag = 1;
        
        //change the cell from gray to blue to show selection
        UIColor *teal = [UIColor colorWithRed:67/255.0 green:161/255.0 blue:187/255.0 alpha:1];
        [cell.initialView setBackgroundColor:teal];
        cell.nameLabel.textColor = teal;
        //pop the cell to show selection
        
        //check the dictionary selContactForAct activity of the cell we selected the contact on
        if([selContactForAct valueForKey:currentAct.objectId] != nil) {
            //if activity has already been registered
            //get the array from the key/value
            invitesArray = [selContactForAct valueForKey:currentAct.objectId];
            
            //add invite object to the existing array
            [invitesArray addObject:inviteObject];
        }
        else {
            //if the activity does not exist in the dictionary
            //add object to empty array
            [invitesArray addObject:inviteObject];
        }
        
        //add array to dictionary
        [selContactForAct setValue:invitesArray forKey:currentAct.objectId];
    
        NSLog(@"dicationary is :%@", selContactForAct);
        
    }else{
        //change tag to 0 indicatirng not selcted
        cell.initialView.tag = 0;
        
        //change cell from blue to gray
        cell.nameLabel.textColor = [UIColor lightGrayColor];
        cell.initialView.backgroundColor = [UIColor lightGrayColor];
        
        //get the selected contacts array from the dictionary
        NSMutableArray *invitesArrr = [selContactForAct objectForKey:currentAct.objectId];
        
        //remove the selected contact from array
        [invitesArrr removeObjectIdenticalTo:inviteObject];
        
        //save array to dictionary again w/o the contact
        [selContactForAct setValue:invitesArrr forKey:currentAct.objectId];
        NSLog(@"dicationary is now :%@", selContactForAct);

        
    }
    
   
    
}

//- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths{
//    NSLog(@"Reload");
//    [self.tableView reloadData];
//    
//}

#pragma mark - messages

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSMS:(NSArray *)numbers{
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    //
    NSArray *recipents = numbers;
    NSString *message = [NSString stringWithFormat:@"Just sent the file to your email. Please check!"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

@end
