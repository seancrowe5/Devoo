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
#import "RallyTableViewCell.h"
#import "SCCollectionViewCell.h"


@interface RalliedActivitiesViewController : PFQueryTableViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate>

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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;

@property (strong, nonatomic) NSMutableArray *selectedTags;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end
