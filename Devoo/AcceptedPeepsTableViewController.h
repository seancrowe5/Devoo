//
//  AcceptedPeepsTableViewController.h
//  Devoo
//
//  Created by Sean Crowe on 2/15/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h>


@interface AcceptedPeepsTableViewController : UITableViewController <MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) PFObject *activityObject;

@end
