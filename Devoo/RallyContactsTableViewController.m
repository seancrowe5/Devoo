//
//  RallyContactsTableViewController.m
//  Devoo
//
//  Created by Sean Crowe on 2/9/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "RallyContactsTableViewController.h"
#import <Mixpanel.h>

@interface RallyContactsTableViewController (){
    

    NSMutableArray *contactsArray; //stores all the contacts from phone
    bool hasRecents; //flag to show if user has recent invites to show
    UIButton *sendInvites; //button at bottom of view
    NSMutableArray *selectedContacts; //contains the contacts the user selects in table
    NSMutableArray *savedContacts; //to save contacts to device for 'recents' (TODO: CORE DATA)
    NSMutableArray *recentContactsRetreived; //Since savedContacts isn't APContact type, this stores better version upon retreival
    NSArray *useThisPhoneArr;

    
    bool itsAMatch;
}
@property (nonatomic, strong) APAddressBook *addressBook;


@end

@implementation RallyContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
 
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:16/255.0 green:165/255.0 blue:192/255.0 alpha:1]; //teal
    
    self.title = @"Pick friends to join!";
    [self.navigationController.navigationBar
setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    //initializes arrays for storage
    selectedContacts = [[NSMutableArray alloc] init];
    savedContacts = [[NSMutableArray alloc] init];
    filteredContentList = [[NSMutableArray alloc] init];
    recentContactsRetreived = [[NSMutableArray alloc] init];
  
    
    
    //Checks if ther are recents saved on the device
    if([defaults objectForKey:@"recentContacts"]){
        savedContacts = [[defaults objectForKey:@"recentContacts"] mutableCopy];
        hasRecents = YES;
    }
    
    ////////////////
    ////ADD BUTTON//
    ////////////////
    sendInvites = [[UIButton alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-40 , self.view.bounds.size.width, 40)];
    [sendInvites setTitle:@"SEND INVITES" forState:UIControlStateNormal];
    [sendInvites.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:20.0]];
    sendInvites.backgroundColor = [UIColor colorWithRed:216/255.0 green:97/255.0 blue:80/255.0 alpha:1];
    [sendInvites addTarget:self action:@selector(sendInvitesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:sendInvites];

    ////////////////
    //GET CONTACTS//
    ////////////////
    APAddressBook *addressBook = [[APAddressBook alloc] init];

    //filter out blank first names
    addressBook.filterBlock = ^BOOL(APContact *contact){return contact.firstName > 0;};
    
    //sort by firstname and then last name
    addressBook.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]];
    
    //filter out blank phone numbers
    addressBook.filterBlock = ^BOOL(APContact *contact){return (contact.phones.count > 0 && contact.firstName > 0);};
    
    //LOAD CONTACTS FROM PHONE
    [addressBook loadContacts:^(NSArray <APContact *> *contacts, NSError *error)
     {
         // hide activity
         if (!error)
         {
             //Store contacts in public array
             contactsArray = [[NSMutableArray alloc] initWithArray:contacts];
            
             NSLog(@"contacts are: %@", contactsArray);
             
             //once loaded, reload data on the tableview
             [self.tableView reloadData];
         }
         else
         {
             // show error
             NSLog(@"error: %@", error);
         }
     }];

    
    ///////////////
    //SEARCH BAR///
    ///////////////
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = false;
    self.definesPresentationContext = true;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.tableView.tableHeaderView = _searchController.searchBar;
    

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //reload data each time table is shown
    [self.tableView reloadData];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    
    //remove button from controller
    [sendInvites removeFromSuperview];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //logic for showing correct number of sections with recents vs no recents
    if (_searchController.active && ![_searchController.searchBar.text  isEqual: @""]) {
        return 1;
    }else{
        
        if (hasRecents) {
            return 2;
        }else{
            return 1;
        }
    }
   }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if (_searchController.active && ![_searchController.searchBar.text  isEqual: @""]) {
        NSLog(@"hey look you're here: %@", filteredContentList);
        return filteredContentList.count;
    }else{
        if (hasRecents && section==0)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray *temp =  [defaults objectForKey:@"recentContacts"];
            return temp.count; //count of recents
        }
        else{
            return contactsArray.count;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(hasRecents && section == 0)
        return @"Recent";
    else
        return @"Your Contacts";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    //change ui of label
    cell.phoneLabel.textColor = [UIColor darkGrayColor];
    
    if (_searchController.active && ![_searchController.searchBar.text  isEqual: @""]) {
        //You are here b/c the user started to search for a name in the search bar
        //what happens is we get the APContact object from the filtered results array (not the original big list of contacts)
        //and display only those contacts that are filtered
        
        APContact *contact = [filteredContentList objectAtIndex:indexPath.row];
        
        NSString *firstName = @"";
        NSString *lastName = @"";

        if (contact.firstName) {
            firstName = contact.firstName;
        }
        
        if (contact.lastName) {
            lastName = contact.lastName;
        }
        NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];

        cell.nameLabel.text = fullName;
        if(contact.phones.count > 1){
            cell.phoneLabel.text = @"Multiple Numbers";
            
        }else{
            cell.phoneLabel.text = [contact.phones firstObject];
            
        }
        cell.selectedButton.selected = [self selectedForIndexPathRecent:contact];
    }
    else {
        //You are here b/c the user just arrived on the rally friends view and sees a list of all of his/her contacts
        //If they've invited friends before, those recents show up at the top in their own section
        
        if (hasRecents && indexPath.section == 0) {
            //User has invited friends before, so show the recent contacts that are found
            //in the user defaults...I've never used coredata so this is an okay solution for now.
            
            NSDictionary *contactDic = [[NSDictionary alloc] init];
            contactDic = [savedContacts objectAtIndex:indexPath.row];
            
            APContact *contact = [self getContactObjectFromDefaults:[contactDic objectForKey:@"firstName"] getContact:[contactDic objectForKey:@"phone"]];
            
            NSString *firstName = @"";
            NSString *lastName = @"";
            
            if (contact.firstName) {
                firstName = contact.firstName;
            }
            
            if (contact.lastName) {
                lastName = contact.lastName;
            }

            
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];

            cell.nameLabel.text = fullName;
            if(contact.phones.count > 1){
                cell.phoneLabel.text = @"Multiple Numbers";

            }else{
                cell.phoneLabel.text = [contact.phones firstObject];

            }

            cell.selectedButton.selected = [self selectedForIndexPathRecent:contact];
        
        }else{
            //You are here b/c the user has NOT invited anyone before...aka no recents
            //we want to display all the contacst found in their address book
            
            APContact *contactInfo = [contactsArray objectAtIndex:indexPath.row];
            
            NSString *firstName = @"";
            NSString *lastName = @"";
            
            if (contactInfo.firstName) {
                firstName = contactInfo.firstName;
            }
            
            if (contactInfo.lastName) {
                lastName = contactInfo.lastName;
            }

            
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
            cell.nameLabel.text = fullName;
            if(contactInfo.phones.count > 1){
                cell.phoneLabel.text = @"Multiple Numbers";
                
            }else{
                cell.phoneLabel.text = [contactInfo.phones firstObject];
                
            }
            cell.selectedButton.selected = [self selectedForIndexPath:indexPath];
            
        }
    }
   return cell;
    
}

-(APContact *)getContactObjectFromDefaults:(NSString *)firstName getContact:(NSString *)phone{
   
    APContact *returnedContact;
    
    for (APContact *contact in contactsArray) {
        if ([contact.firstName isEqualToString:firstName] && [[contact.phones firstObject] isEqualToString:phone]) {
            NSLog(@"we found your contact");
            returnedContact = contact;
            
            if (hasRecents) {
                [recentContactsRetreived addObject:contact];
            }
        }
    }
    
    return returnedContact;
}

-(bool)selectedForIndexPath:(NSIndexPath *)indexPath{
 
    itsAMatch = false;
    
    for (APContact *contact in selectedContacts) {
        if (contact == [contactsArray objectAtIndex:indexPath.row]) {
            NSLog(@"EQUALITY!");
            
            itsAMatch =  true;
            
        }
    }
    
    return itsAMatch;
}

-(bool)selectedForIndexPathRecent:(APContact *)contactr{
    
    itsAMatch = false;
    
    for (APContact *contact in selectedContacts) {
        if (contact == contactr) {
            NSLog(@"EQUALITY!");
            
            itsAMatch =  true;
            
        }
    }
    
    return itsAMatch;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"did slect: %ldl", (long)indexPath.row);
    
    
    ContactTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    APContact *selectedContact;
    
   
    if (_searchController.isActive) {
        if (filteredContentList.count == 0) {
            //otherwise it's either recents OR your contacts
            if (hasRecents && indexPath.section == 0) {
                selectedContact = [recentContactsRetreived objectAtIndex:indexPath.row];
                
            }else{
                selectedContact = [contactsArray objectAtIndex:indexPath.row];
            }
            
        }else{
            //search results uses a different array of data

            selectedContact = [filteredContentList objectAtIndex:indexPath.row];
            

            [self performSelector:@selector(dismissSearchBar)
                       withObject:self
                       afterDelay:.25];
 
        }
        
    }else{
        //otherwise it's either recents OR your contacts
        if (hasRecents && indexPath.section == 0) {
            selectedContact = [recentContactsRetreived objectAtIndex:indexPath.row];

        }else{
            selectedContact = [contactsArray objectAtIndex:indexPath.row];
        }
    }
    
    
    //set button as selected
    if (cell.selectedButton.selected == true) {
        cell.selectedButton.selected = false;
        
        //remove from selected list
        [selectedContacts removeObjectIdenticalTo:selectedContact];
        
        //change label for send invites to reflect number of selected
        NSString *titleLable = [NSString stringWithFormat:@"SEND INVITES (%lu)", (unsigned long)selectedContacts.count];
        [sendInvites setTitle:titleLable forState:UIControlStateNormal];
    }else{
        
        cell.selectedButton.selected = true;
        
        if (selectedContact.phones.count > 1) {
            //do somthing
            NSLog(@"show alertttttt");
            
            
            NSString *phone1;
            NSString *phone2;
            NSString *phone3;
            NSString *phone4;
            
            
            //build alert
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This person has multiple numbers."
                                                                           message:@"Which phone number would you like to use?"
                                                                    preferredStyle:UIAlertControllerStyleActionSheet]; // 1
            
            
            
            if (selectedContact.phones.count > 1) {
                phone1 = selectedContact.phones[0];
                phone2 = selectedContact.phones[1];
                
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:phone1
                                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                          NSLog(@"You pressed button one");
                                                                          
                                                                          useThisPhoneArr = [[NSArray alloc] initWithObjects:phone1,phone2, nil];
                                                                          selectedContact.phones = useThisPhoneArr;
                                                                          
                                                                          //add selected contact to selected array
                                                                          [selectedContacts addObject:selectedContact];
                                                                          
                                                                          NSLog(@"You selected this: %@", selectedContact.phones);
                                                                          
                                                                          
                                                                          
                                                                          
                                                                          
                                                                          //change label for send invites to reflect number of selected
                                                                          NSString *titleLable = [NSString stringWithFormat:@"SEND INVITES (%lu)", (unsigned long)selectedContacts.count];
                                                                          [sendInvites setTitle:titleLable forState:UIControlStateNormal];
                                                                          
                                                                      }]; // 2
                
                UIAlertAction *secondAction = [UIAlertAction actionWithTitle:phone2
                                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                           NSLog(@"You pressed button two");
                                                                           
                                                                           useThisPhoneArr = [[NSArray alloc] initWithObjects:phone2,phone1, nil];
                                                                           selectedContact.phones = useThisPhoneArr;
                                                                           
                                                                           //add selected contact to selected array
                                                                           [selectedContacts addObject:selectedContact];
                                                                           
                                                                           NSLog(@"You selected this: %@", selectedContact.phones);
                                                                           
                                                                           
                                                                           
                                                                           
                                                                           
                                                                           //change label for send invites to reflect number of selected
                                                                           NSString *titleLable = [NSString stringWithFormat:@"SEND INVITES (%lu)", (unsigned long)selectedContacts.count];
                                                                           [sendInvites setTitle:titleLable forState:UIControlStateNormal];
                                                                           
                                                                           
                                                                       }]; // 3
                
                [alert addAction:firstAction]; // 4
                [alert addAction:secondAction]; // 5
            }
            
            if (selectedContact.phones.count > 2) {
                
                phone3 = selectedContact.phones[2];
                
                UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:phone3
                                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                          NSLog(@"You pressed button two");
                                                                          
                                                                          useThisPhoneArr = [[NSArray alloc] initWithObjects:phone3,phone1,phone2, nil];
                                                                          selectedContact.phones = useThisPhoneArr;
                                                                          
                                                                          //add selected contact to selected array
                                                                          [selectedContacts addObject:selectedContact];
                                                                          
                                                                          NSLog(@"You selected this: %@", selectedContact.phones);
                                                                          
                                                                          
                                                                          
                                                                          //change label for send invites to reflect number of selected
                                                                          NSString *titleLable = [NSString stringWithFormat:@"SEND INVITES (%lu)", (unsigned long)selectedContacts.count];
                                                                          [sendInvites setTitle:titleLable forState:UIControlStateNormal];
                                                                          
                                                                          
                                                                      }]; // 3
                
                [alert addAction:thirdAction]; // 5
                
            }
            
            if (selectedContact.phones.count > 3) {
                
                phone4 = selectedContact.phones[3];
                
                
                UIAlertAction *fourthAction = [UIAlertAction actionWithTitle:phone4
                                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                           NSLog(@"You pressed button two");
                                                                           
                                                                           useThisPhoneArr = [[NSArray alloc] initWithObjects:phone4, phone3, phone2,phone1, nil];
                                                                           selectedContact.phones = useThisPhoneArr;
                                                                           
                                                                           //add selected contact to selected array
                                                                           [selectedContacts addObject:selectedContact];
                                                                           
                                                                           NSLog(@"You selected this: %@", selectedContact.phones);
                                                                           
                                                                           
                                                                       }]; // 3
                [alert addAction:fourthAction]; // 5
                
                
            }
            
            
            [self presentViewController:alert animated:YES completion:nil]; // 6
            
        }else{
            
            //add selected contact to selected array
            [selectedContacts addObject:selectedContact];

            //change label for send invites to reflect number of selected
            NSString *titleLable = [NSString stringWithFormat:@"SEND INVITES (%lu)", (unsigned long)selectedContacts.count];
            [sendInvites setTitle:titleLable forState:UIControlStateNormal];

        }
   
    }
    
    
}

-(void)dismissSearchBar{
    [_searchController setActive:NO];
    
}
-(void)sendInvitesButtonPressed{
    NSLog(@"Send Invites Pressed: %@", selectedContacts);
    
    if (recentContactsRetreived.count > 0) {
        
        //let's go see if the contact we're trying to save right now, exists in the recentContacts array
        bool contactAlreaadySaved = false;
        for (APContact *selectedContact in selectedContacts) {
            for (APContact *savedContact in recentContactsRetreived) {
                if (selectedContact == savedContact) {
                    NSLog(@"Hey, the contact we're trying to save now alrady is saved!");
                    contactAlreaadySaved = true;
                }
  
            }
            
            if (!contactAlreaadySaved) {
                NSLog(@"SAVE CONTACT NOW");
                NSMutableDictionary *dic = [[NSMutableDictionary  alloc] init];
                
                if (selectedContact.lastName) {
                    [dic setObject:selectedContact.firstName forKey:@"firstName"];
                }
                
                if (selectedContact.lastName) {
                    [dic setObject:selectedContact.lastName forKey:@"lastName"];
                }
                NSString *phone = [selectedContact.phones firstObject];
                [dic setObject:phone forKey:@"phone"];
                
                //add the dictionary to an array
                //we may have an array of like 3 dictionaries...one per contact invited
                [savedContacts insertObject:dic atIndex:0 ];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:savedContacts forKey:@"recentContacts"];
                [defaults synchronize];
            }
        }
    }else{
        NSLog(@"This is the first time we're inviting ppl");
        
        for (APContact *contact in selectedContacts) {
            NSMutableDictionary *dic = [[NSMutableDictionary  alloc] init];
            
            if (contact.firstName) {
                [dic setObject:contact.firstName forKey:@"firstName"];
            }
            
            if (contact.lastName) {
                [dic setObject:contact.lastName forKey:@"lastName"];
            }
            
            NSString *phone = [contact.phones firstObject];
            [dic setObject:phone forKey:@"phone"];
            
           
            
            //add the dictionary to an array
            //we may have an array of like 3 dictionaries...one per contact invited
            [savedContacts insertObject:dic atIndex:0 ];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:savedContacts forKey:@"recentContacts"];
            [defaults synchronize];
        }
    }

    NSMutableArray *pointerArray = [[NSMutableArray alloc] init];
    NSMutableArray *contactObjectArray = [[NSMutableArray alloc] init];
    NSMutableArray *phoneArray = [[NSMutableArray alloc] init]; //use contact object soon
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    NSMutableArray *contactObjectidsArray = [[NSMutableArray alloc] init];
    
    
    //loop through all the selected activities and create the pointer object
    //this way we have an array of pointers in parse, instead of just unique ids...pretty cool!
    //pointerArray contains the json formated pointers, we will add that to the RALLY object lata
    
    for (PFObject *activity in _activitiesArray) {
        //pin activities to local

        [activity pinInBackground];
        //[activity fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            NSMutableDictionary *pointer = [[NSMutableDictionary alloc] init];
            [pointer setObject:@"Pointer" forKey:@"__type"];
            [pointer setObject:@"Activity" forKey:@"className"];
            [pointer setObject:activity.objectId forKey:@"objectId"];
            
            [pointerArray addObject:pointer];
            
        //}];
        
    }
    
    //loop through all the selected contacts and build arrays of the name/phone
    //phoneArray and nameArray will both be passed to cloud code to send out SMS to those numbas
    for (APContact *contact in selectedContacts) {
        
        //strip phone of special characters
        NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        NSString *resultString = [[[contact.phones firstObject] componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        
        [nameArray addObject:contact.firstName];
        [phoneArray addObject:resultString];
        
        //CREATE CONTACT OBJECT (SINCE THEY AREN'T USERS)
        PFObject *contactObject = [[PFObject alloc] initWithClassName:@"Contacts"];
        NSLog(@"contact last is: %@", contact.lastName);
        
        
        
        NSString *fullName = [NSString stringWithFormat:@"%@", contact.firstName];
        contactObject[@"contactName"] = fullName;
        contactObject[@"contactPhone"] = resultString;
        contactObject[@"contactOwner"] = [PFUser currentUser];
        [contactObject pinInBackground];
        [contactObjectArray addObject:contactObject];
        
    }
    
    [PFObject saveAllInBackground:contactObjectArray block:^(BOOL succeeded, NSError * _Nullable error) {
       
        NSMutableArray *invitesArray = [[NSMutableArray alloc] init];
        NSMutableArray *invitesObjectIdArray = [[NSMutableArray alloc] init];

        
        
        //CREATE RALLY OBJECT w/ activity pointesr
        //what if we already created a rally object for this activity.
        //that means it is pinned on the device...so let's query locally for it,
        //if no response, then create it
        
        PFQuery *query = [[PFQuery alloc] initWithClassName:@"Rally"];
        [query whereKey:@"activityObjectsArray" containsAllObjectsInArray:pointerArray];
        [query whereKey:@"userObject" equalTo:[PFUser currentUser]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
            if (!error) {
                NSLog(@"The user has done this rally before with these events: %@", object);
                //this means we can re-use this rally object and add invites to it
                
                for (PFObject *contact in contactObjectArray) {
                    [contactObjectidsArray addObject:contact.objectId];
                    
                    //create invites objects in parse and pin locally
                    PFObject *invite = [PFObject objectWithClassName:@"Invites"];
                    invite[@"rallyObject"] = object;
                    invite[@"contactObject"] = contact;
                    [invite pinInBackground];
                    [invitesArray addObject:invite];
                    
                }
                
                
                [PFObject saveAllInBackground:invitesArray block:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    for (PFObject *invite in invitesArray) {
                        [invitesObjectIdArray addObject:invite.objectId];
                    }
                    
                    NSString *daySelected;
                    if (_selectedToday == true) {
                        NSLog(@"today was selected");
                        daySelected = @"today";
                    }else if (_selectedTommorrow) {
                        NSLog(@"tomorrow was selected");
                        daySelected = @"tomorrow";

                    }else if (!_selectedToday && !_selectedTommorrow) {
                        NSLog(@"weekend was selected");

                        daySelected = @"this weekend";
                    }
                    
                    //once the rally object is saved, call cloud code to send the sms!
                    [PFCloud callFunctionInBackground:@"sendInvites"
                                       withParameters:@{@"rallyObjectId" : object.objectId,
                                                        @"contactsArray": contactObjectidsArray,
                                                        @"invitesArray": invitesObjectIdArray,
                                                        @"daySelected": daySelected}
                                                block:^(NSString *result, NSError *error) {
                                                    if (!error) {
                                                        //success!
                                                        
                                                    
                                                        
                                                    }else{
                                                        NSLog(@"ERROR");
                                                    }
                                                    
                                                }];
                    
                }];

                

                
            }else{
                //no rally object so let's make one!
                PFObject *rallyObject = [[PFObject alloc] initWithClassName:@"Rally"];
                rallyObject[@"userObject"] = [PFUser currentUser];
                rallyObject[@"activityObjectsArray"] = pointerArray;
                [rallyObject pinInBackground];
                
                [rallyObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if(succeeded){
                        for (PFObject *contact in contactObjectArray) {
                            [contactObjectidsArray addObject:contact.objectId];
                            
                            //create invites objects in parse and pin locally
                            PFObject *invite = [PFObject objectWithClassName:@"Invites"];
                            invite[@"rallyObject"] = rallyObject;
                            invite[@"contactObject"] = contact;
                            [invite pinInBackground];
                            [invitesArray addObject:invite];
                            
                        }
                        
                        
                        [PFObject saveAllInBackground:invitesArray block:^(BOOL succeeded, NSError * _Nullable error) {
                            
                            for (PFObject *invite in invitesArray) {
                                [invitesObjectIdArray addObject:invite.objectId];
                            }
                            
                            NSString *daySelected;
                            if (_selectedToday == true) {
                                NSLog(@"today was selected");
                                daySelected = @"today";
                            }else if (_selectedTommorrow == true) {
                                NSLog(@"tomorrow was selected");
                                daySelected = @"tomorrow";
                                
                            }else if (!_selectedToday && !_selectedTommorrow) {
                                NSLog(@"weekend was selected");
                                
                                daySelected = @"this weekend";
                            }

                            
                            //once the rally object is saved, call cloud code to send the sms!
                            [PFCloud callFunctionInBackground:@"sendInvites"
                                               withParameters:@{@"rallyObjectId" : rallyObject.objectId,
                                                                @"contactsArray": contactObjectidsArray,
                                                                @"invitesArray": invitesObjectIdArray,
                                                                @"daySelected": daySelected}
                                                        block:^(NSString *result, NSError *error) {
                                                            if (!error) {
                                                                //success!
                                                                
                                                                
                                                                
                                                            }else{
                                                                NSLog(@"ERROR");
                                                            }
                                                            
                                                        }];
                            
                        }];
                        
                        
                    }
                    
                }];


            }
            
        }];
        
    }];
    
    //add alert to tell user what just happened
    //when they click okay, it sends back to activity list
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Invites Sent!"
                                  message:@"Sit tight to find out which friends are down!"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Sounds Great!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //MIXPANEL
                                    int arrayCount = (int)selectedContacts.count;
                                    NSNumber *n = [NSNumber numberWithInt:arrayCount];
                                    Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                    
                                    //TODO:
                                    [mixpanel track:@"Invite Sent" properties:@{
                                                                                  @"Num of Contacts": n
                                                                                  }];
                                    [mixpanel.people increment:@"Rallies" by:@1];
                                    
                                    //go to rallies
//                                    NSString * storyboardName = @"Main";
//                                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
//                                    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"nav"];

//                                    [self presentViewController:vc animated:YES completion:nil];
//                                  
                                    [self.navigationController popToRootViewControllerAnimated:NO];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBarButtonBadge" object:nil];


                                    
                                }];
    
    [alert addAction:yesButton];
    
    
    
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma MARK - Search Bar

- (void)searchTableList {
    NSLog(@"SEARCH: %@", _searchController.searchBar.text);
    NSString *searchString = _searchController.searchBar.text;

    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"firstName BEGINSWITH[c] %@", searchString];
    filteredContentList = [[contactsArray filteredArrayUsingPredicate:resultPredicate]mutableCopy];

    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSLog(@"update search results"); //testing
    NSString *searchString = searchController.searchBar.text;
    [self searchTableList];
    [self.tableView reloadData];
    
    if (!searchController.active) {
        NSLog(@"cancel pressed");
    }
}



#pragma mark - Navigation



- (IBAction)closeButtonPressed:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBarButtonBadge" object:nil];

}
@end
