//
//  RallyContactsTableViewController.h
//  Devoo
//
//  Created by Sean Crowe on 2/9/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <APAddressBook.h>
#import <APContact.h>
#import <UIKit/UIKit.h>
#import "ContactTableViewCell.h"
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>
@import AddressBook;

@interface RallyContactsTableViewController : UITableViewController <UISearchResultsUpdating, UISearchBarDelegate>{
    
    NSMutableArray *filteredContentList;
    BOOL isSearching;
}


@property (strong, nonatomic)  UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *activitiesArray;
- (IBAction)closeButtonPressed:(id)sender;

@property bool selectedToday;
@property bool selectedTommorrow;


@end
