//
//  pageContentCYOViewController.m
//  Devoo
//
//  Created by Sean Crowe on 4/15/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "pageContentCYOViewController.h"

@interface pageContentCYOViewController ()

@end

@implementation pageContentCYOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _questionLabel.text = _txtTitle;
 
    
    
    //date picker
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [_datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [_datePicker addTarget:self action:@selector(onDatePickerValueChangedd:) forControlEvents:UIControlEventValueChanged];
    _dateTextBox.inputView = self.datePicker;
    

    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_pageIndex == 1) {
            [_dateTextBox becomeFirstResponder];
        }
        
        if (_pageIndex == 2) {
            [_locationTextbox becomeFirstResponder];
        }
        
        if (_pageIndex == 3) {
            [_descriptionTextbox becomeFirstResponder];
        }
        

    });
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)onDatePickerValueChangedd:(UIDatePicker *)datePicker
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd hh:mm a"];
    
    NSString *dateString = [dateFormatter stringFromDate:datePicker.date];
    
    _dateTextBox.text =  dateString;
    _activityDate = datePicker.date;
    
}


- (IBAction)addPictureButtonPressed:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    _imageChosen = chosenImage;
    
    [_addPictureButton setBackgroundImage:[UIImage imageNamed:@"camera-check"] forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
@end
