//
//  activityFeedPFQTViewController.h
//  Devoo
//
//  Created by Sean Crowe on 2/6/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h>
#import <APAddressBook.h>
#import <APContact.h>
#import <QuartzCore/QuartzCore.h>

@interface activityFeedPFQTViewController : PFQueryTableViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

- (IBAction)feebackButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *bottomViewThing;
- (IBAction)showEmail:(id)sender;

- (void)ralliersOnEvent:(NSArray *)accepted;
@property CGPoint originalCenter;


//added
@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToSportTypeMap;

@property (strong, nonatomic) NSDate *endDateFromSegue;
@property (strong, nonatomic) NSDate *startDateFromSegue;

@property bool selectedTodayFromSegue;
@property bool selectedTomorrowFromSegue;
@property bool randomSelected;
@property bool recentSelected;


@property (strong, nonatomic) NSMutableArray *selectedTags;



@end
