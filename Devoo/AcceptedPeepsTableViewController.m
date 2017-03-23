//
//  AcceptedPeepsTableViewController.m
//  Devoo
//
//  Created by Sean Crowe on 2/15/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "AcceptedPeepsTableViewController.h"
#import "ContactTableViewCell.h"
#import <Mixpanel.h>

@interface AcceptedPeepsTableViewController (){
    NSMutableArray *totalInvites;
    NSMutableArray *yesResponses;
    NSMutableArray *noResponses;
    
    NSMutableArray *selectedContacts;

    UIButton *sendSMSButton;

    bool flag;
    
    
    
}

@end

@implementation AcceptedPeepsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    
    totalInvites = [[NSMutableArray alloc] init];
    yesResponses = [[NSMutableArray alloc] init];
    noResponses = [[NSMutableArray alloc] init];
    selectedContacts = [[NSMutableArray alloc] init];

    sendSMSButton = [[UIButton alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-40 , self.view.bounds.size.width, 40)];
    [sendSMSButton setTitle:@"START CHAT" forState:UIControlStateNormal];
    [sendSMSButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:20.0]];
    sendSMSButton.backgroundColor = [UIColor colorWithRed:16/255.0 green:165/255.0 blue:192/255.0 alpha:1];
    [sendSMSButton addTarget:self action:@selector(showSMS) forControlEvents:UIControlEventTouchUpInside];
    

    self.title = @"Pick your group!";

    
    [self.navigationController.view addSubview:sendSMSButton];

    //First, let's go get the Rally object from this user on this activity
    //Then, let's go ahead and get the POINTER array of contacts that were invited
    //Display everyone invited
    

    PFQuery *query = [PFQuery queryWithClassName:@"Rally"];
    [query whereKey:@"userObject" equalTo:[PFUser currentUser]];
    [query whereKey:@"activityObjectsArray" equalTo:_activityObject];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFQuery *query = [PFQuery queryWithClassName:@"Invites"];
        [query whereKey:@"rallyObject" equalTo:object];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable inviteObjects, NSError * _Nullable error) {
            
            NSLog(@"invite objects are: %@", inviteObjects);
            
            PFQuery *query = [PFQuery queryWithClassName:@"Response"];
            [query whereKey:@"inviteObject" containedIn:inviteObjects];
            [query whereKey:@"activityObject" equalTo:_activityObject];
            [query includeKey:@"invteObject"];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable responseObjects, NSError * _Nullable error) {
                
                //total invites is in inviteObjects
                totalInvites = [inviteObjects mutableCopy];
                
                for (PFObject *response in responseObjects) {
                    
                    
                    if ([response[@"response"] isEqualToString:@"yes"]) {
                        [yesResponses addObject:response];
                        
                        
                    }else if ([response[@"response"] isEqualToString:@"no"]) {
                        [noResponses addObject:response];
                    }
                    
                    PFObject *inviteObject = response[@"inviteObject"];
                    [inviteObject fetchIfNeeded];
                    
                    NSMutableArray *totalInvitesCopy = [totalInvites mutableCopy];
                    
                    for (PFObject *invite in totalInvitesCopy) {
                        if ([invite.objectId isEqualToString:inviteObject.objectId]) {
                            [totalInvites removeObjectIdenticalTo:invite];
                        }
                    }
                }
                
                NSLog(@"TOTAL: %@", totalInvites);
                NSLog(@"YES: %@", yesResponses);
                NSLog(@"NO: %@", noResponses);

                [self.tableView reloadData];
            }];
            
        }];
        //we need total responses
        
    }];
        
            
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [sendSMSButton removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0 && yesResponses.count > 0 ) {
        return yesResponses.count;
        
    }else if (section == 1 && noResponses.count > 0){
        return noResponses.count;
    }else if(section == 2 && totalInvites.count > 0){
        return totalInvites.count;
    }else
        return 0;
        
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *nameLabel = @"";
    cell.selectedButton.selected = false;
    
    if (indexPath.section == 0) {
        //accepted
        
        PFObject *responseObject = [yesResponses objectAtIndex:indexPath.row];
        PFObject *inviteObject = responseObject[@"inviteObject"];
        [inviteObject fetchIfNeeded];
        PFObject *contactObject = inviteObject[@"contactObject"];
        [contactObject fetchIfNeeded];
        
        nameLabel = contactObject[@"contactName"];
    }
    
    else if (indexPath.section == 1) {
        //rejected
        
        PFObject *responseObject = [noResponses objectAtIndex:indexPath.row];
        PFObject *inviteObject = responseObject[@"inviteObject"];
        [inviteObject fetchIfNeeded];
        PFObject *contactObject = inviteObject[@"contactObject"];
        [contactObject fetchIfNeeded];

        nameLabel = contactObject[@"contactName"];
    }
    
    else{
        //unanswered
        PFObject *inviteObject = [totalInvites objectAtIndex:indexPath.row];
        PFObject *contactObject = inviteObject[@"contactObject"];
        [contactObject fetchIfNeeded];
        nameLabel = contactObject[@"contactName"];
        
    }
    
    cell.nameLabel.text = nameLabel;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Accepted";
    else if(section == 1){
        return @"Rejected";
    }else
        return @"Unanswered";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    
    if (indexPath.section == 0) {
        //selected an accepted user
        
        PFObject *responseObject = [yesResponses objectAtIndex:indexPath.row];
        PFObject *inviteObject = responseObject[@"inviteObject"];
        [inviteObject fetchIfNeeded];
        PFObject *contactObject = inviteObject[@"contactObject"];
        [contactObject fetchIfNeeded];

        
        if (cell.selectedButton.selected == YES) {
            cell.selectedButton.selected = NO;
            [selectedContacts removeObjectIdenticalTo:contactObject[@"contactPhone"]];

        }else{
            cell.selectedButton.selected = YES;
            [selectedContacts addObject:contactObject[@"contactPhone"]];

        }
        
    }else if (indexPath.section == 1) {
        PFObject *responseObject = [noResponses objectAtIndex:indexPath.row];
        PFObject *inviteObject = responseObject[@"inviteObject"];
        [inviteObject fetchIfNeeded];
        PFObject *contactObject = inviteObject[@"contactObject"];
        [contactObject fetchIfNeeded];
        
        
        if (cell.selectedButton.selected == YES) {
            cell.selectedButton.selected = NO;
            [selectedContacts removeObjectIdenticalTo:contactObject[@"contactPhone"]];
            
        }else{
            cell.selectedButton.selected = YES;
            [selectedContacts addObject:contactObject[@"contactPhone"]];
            
        }

    
    }else if (indexPath.section == 2) {
        
        PFObject *inviteObject = [totalInvites objectAtIndex:indexPath.row];
        PFObject *contactObject = inviteObject[@"contactObject"];
        [contactObject fetchIfNeeded];
                
        
        if (cell.selectedButton.selected == YES) {
            cell.selectedButton.selected = NO;
            [selectedContacts removeObjectIdenticalTo:contactObject[@"contactPhone"]];
            
        }else{
            cell.selectedButton.selected = YES;
            [selectedContacts addObject:contactObject[@"contactPhone"]];
            
        }

    }


}


#pragma mark - messaging

- (void)showSMS{
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = selectedContacts;
    NSString *activityName = _activityObject[@"activityName"];
    NSString *activityTime= _activityObject[@"activityTime"];
    NSString *activityURL = _activityObject[@"url"];

    
    NSString *message = [NSString stringWithFormat:@"Hey! I chose %@ for %@. Let's go! Go to website @: %@", activityName, activityTime, activityURL];
    
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    
    //MIXPANEL
    int arrayCount = (int)selectedContacts.count;
    NSNumber *n = [NSNumber numberWithInt:arrayCount];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Chat Started" properties:@{
                                                  @"Num of Contacts": n
                                                  }];
    [mixpanel.people increment:@"Chats" by:@1];

    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:{
            NSLog(@"jtlakj");
            [selectedContacts removeAllObjects];
            [self.tableView reloadData];
            
            break;}
            
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
