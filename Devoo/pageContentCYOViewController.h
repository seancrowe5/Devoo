//
//  pageContentCYOViewController.h
//  Devoo
//
//  Created by Sean Crowe on 4/15/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pageContentCYOViewController : UIViewController < UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *questionLabel;
@property (strong, nonatomic) IBOutlet UITextField *responseTextBox;



@property NSUInteger pageIndex;
@property NSString *imgFile;
@property NSString *txtTitle;

//date
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UITextField *dateTextBox;
@property (strong, nonatomic) IBOutlet UITextField *locationTextbox;
@property (strong, nonatomic) NSDate *activityDate;

@property (strong, nonatomic) IBOutlet UITextField *descriptionTextbox;
@property (strong, nonatomic) IBOutlet UIButton *addPictureButton;
@property (strong, nonatomic) UIImage *imageChosen;

- (IBAction)addPictureButtonPressed:(id)sender;

@end
