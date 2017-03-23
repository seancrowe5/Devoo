//
//  LoginViewController.m
//  Devoo
//
//  Created by Sean Crowe on 2/12/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <Mixpanel.h>


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Show keyboard when view loads
    
    //set styling for button
    _getStartedButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _getStartedButton.layer.borderWidth = 2.0;
    _getStartedButton.layer.cornerRadius = _getStartedButton.bounds.size.height/2;
    _getStartedButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    _numberField.delegate = self;
    
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (IBAction)getStartedButtonPressed:(id)sender {
    
    
    //We want the phone number to be username and password for now so we can get them in the app quickly
    //Later we'll add a true signup flow
    
    //Get the phone and strip any special characters and spaces...format should be 3306714458
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *resultString = [[_numberField.text componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    
    //for login use the vars number/name
    NSString *number = resultString;
    NSString *firstName;
    NSString *lastName;
    
    NSRange whiteSpaceRange = [_nameField.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound) {
       //space exists
        firstName = [[_nameField.text componentsSeparatedByString:@" "] objectAtIndex:0]; //John
        NSString *fullName = _nameField.text;
        lastName = [[fullName substringFromIndex:[fullName rangeOfString:firstName].length + 1] capitalizedString];
        
        
    }else{
        //no white space
        firstName = [[_nameField.text componentsSeparatedByString:@" "] objectAtIndex:0]; //John
    }

 
    //make sure user entered someting in the fields
    if (![_numberField.text isEqualToString:@""] && ![_nameField.text isEqualToString:@""]) {
        
        //First, let's try loggining in with that phone number to see if user exists already
        [PFUser logInWithUsernameInBackground:number password:number block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            if (error) {
                //You're here b/c the login didn't work...this means no user exists OR typed in # wrong...so create one
                
                
                //New User
                PFUser *newUser = [PFUser user];
                newUser.username = number;
                newUser.password = number;
                newUser[@"firstName"] = firstName;
                if (lastName) {
                    newUser[@"lastName"] = lastName;
                }
                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if (!error) {
                        //you're here b/c the creation of new user worked!
                        
                        //we need to register device in Parse to send push notifications
                        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                        currentInstallation[@"user"] = newUser;
                        [currentInstallation saveInBackground];
                        
                        //tell mixpanel who dis is
                        Mixpanel *mixpanel = [Mixpanel sharedInstance];
                        [mixpanel createAlias:newUser.objectId
                                forDistinctID:mixpanel.distinctId];
                        [mixpanel identify:newUser.objectId];
                        [mixpanel.people set:@{@"first_name": _nameField.text,
                                               @"Phone": number}];

                        
                        //go to the activity feed
                        [self performSegueWithIdentifier:@"loggedIn" sender:self];
                    }else{
                        //user couldn't log in OR sign up!
                        NSLog(@"DIDN'T WORK");
                        
                        //TODO: Show some type of alert
                    }
                }];

            }else{
                //You're here because the login worked!
                //we need to register device in Parse to send push notifications
                                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                currentInstallation[@"user"] = user;
                [currentInstallation saveInBackground];
                
                                
                //call identify with the paree objectId
                Mixpanel *mixpanel = [Mixpanel sharedInstance];
                [mixpanel identify:user.objectId];

                //go to the activity feed
                [self performSegueWithIdentifier:@"loggedIn" sender:self];

            }
            
        }];
        
    }
}

#pragma mark - Format Field as Phone

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int length = (int)[self getLength:textField.text];
    //NSLog(@"Length  =  %d ",length);
    
    if(length == 10)
    {
        if(range.length == 0)
            return NO;
    }
    
    if(length == 3)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) ",num];
        
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
    }
    else if(length == 6)
    {
        NSString *num = [self formatNumber:textField.text];
        //NSLog(@"%@",[num  substringToIndex:3]);
        //NSLog(@"%@",[num substringFromIndex:3]);
        textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
        
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
    
    return YES;
}

- (NSString *)formatNumber:(NSString *)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = (int)[mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    
    return mobileNumber;
}

- (int)getLength:(NSString *)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    
    return length;
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSLog(@"view is: %f", self.view.bounds.size.width);
    
    if (self.view.bounds.size.width == 320) {
        
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -(keyboardSize.height-50);
        self.view.frame = f;
    }];
        
    }
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    
    if (self.view.bounds.size.width == 320) {

    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
    }
}
@end
