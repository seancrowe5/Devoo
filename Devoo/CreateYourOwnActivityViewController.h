//
//  CreateYourOwnActivityViewController.h
//  Devoo
//
//  Created by Sean Crowe on 3/17/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface CreateYourOwnActivityViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

//ui elements
@property (weak, nonatomic) IBOutlet UITextField *activityNameField;
@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *rallyFriendsButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

//Action
- (IBAction)rallyFriendsButtonPressed:(id)sender;
- (IBAction)cameraButtonPressed:(id)sender;

//date picker
@property (strong, nonatomic) UIDatePicker *datePicker;

//activity vars
@property (strong, nonatomic) NSDate *activityDate;
@property (strong, nonatomic) UIImage *imageChosen;
@property (strong, nonatomic) PFObject *activityObject;



@end
