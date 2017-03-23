//
//  CreateYourOwnActivityViewController.m
//  Devoo
//
//  Created by Sean Crowe on 3/17/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "CreateYourOwnActivityViewController.h"
#import "RallyContactsTableViewController.h"

@interface CreateYourOwnActivityViewController (){
    UIColor *newNavBarColor;

}

@end

@implementation CreateYourOwnActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _descriptionTextView.delegate = self;
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    newNavBarColor = [UIColor colorWithRed:216/255.0 green:97/255.0 blue:80/255.0 alpha:1]; //red
    
    self.navigationController.navigationBar.barTintColor = newNavBarColor;
    
    //Change inset for placeholder text on textfields
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    _activityNameField.leftView = paddingView;
    _activityNameField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView1 = [[UIView alloc] initWithFrame:paddingView.frame];
    _locationField.leftView = paddingView1;
    _locationField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView2 = [[UIView alloc] initWithFrame:paddingView.frame];
    _dateField.leftView = paddingView2;
    _dateField.leftViewMode = UITextFieldViewModeAlways;
 
    
    //TODO: Change inset for text on the description textview
    
    //date picker
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [_datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [_datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    _dateField.inputView = self.datePicker;
    

}


- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd hh:mm a"];
    
    NSString *dateString = [dateFormatter stringFromDate:datePicker.date];

    _dateField.text =  dateString;
    _activityDate = datePicker.date;
    
}


- (IBAction)rallyFriendsButtonPressed:(id)sender {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Check yo' self!"
                                  message:@"Make sure you filled out all the fields!"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Sounds Good!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //Handel your yes please button action here
                                    
                                    
                                }];
    
    [alert addAction:yesButton];
    
    
    if ([_activityNameField.text isEqualToString:@""]) {
        [self presentViewController:alert animated:YES completion:nil];
    }else if([_dateField.text isEqualToString:@""]){
        [self presentViewController:alert animated:YES completion:nil];
    }else if([_locationField.text isEqualToString:@""]){
        [self presentViewController:alert animated:YES completion:nil];
    }else if([_descriptionTextView.text isEqualToString:@""]){
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        
        //do magic here
    
        //TODO: save activity to local datastore
        PFObject *activityObject = [[PFObject alloc] initWithClassName:@"Activity"];
        activityObject[@"activityType"] = _activityNameField.text;
        activityObject[@"activityName"] = _locationField.text;
        activityObject[@"activityStartTime"] = _activityDate;
        activityObject[@"activitySpecial"] = _descriptionTextView.text;
        activityObject[@"activityOwner"] = [PFUser currentUser];
        
        if (_imageChosen) {
            NSData *imageData = UIImagePNGRepresentation(_imageChosen);
            PFFile *imageFile = [PFFile fileWithName:@"customActivity.png" data:imageData];
            activityObject[@"activityImage"] = imageFile;
        }
        
        
        [activityObject pinInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            _activityObject = activityObject;
        }];

      

        //save object and go to rally friends view
        [activityObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self performSegueWithIdentifier:@"showRallyFriends" sender:self];

        }];
    }
}

- (IBAction)cameraButtonPressed:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    _imageChosen = chosenImage;
    
    [_cameraButton setBackgroundImage:[UIImage imageNamed:@"camera-check"] forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:_activityObject, nil];
    RallyContactsTableViewController *vc = [segue destinationViewController];
    vc.activitiesArray = array;        
   
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    
    if ([textView.text isEqualToString:@"Description"]) {
        [textView setText:@""];
    }
}

- (void) textViewDidEndEditing:(UITextView *) textView {
    
    if ([textView.text isEqualToString:@""]) {
        [textView setText:@"Description"];
    }
}


@end
