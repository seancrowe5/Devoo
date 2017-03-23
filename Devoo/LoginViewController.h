//
//  LoginViewController.h
//  Devoo
//
//  Created by Sean Crowe on 2/12/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;
- (IBAction)getStartedButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end
