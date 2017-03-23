//
//  SelectDayViewController.h
//  Devoo
//
//  Created by Sean Crowe on 3/13/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "UIBarButtonItem+Badge.h"

@interface SelectDayViewController : UIViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

//actions
- (IBAction)todayButtonPressed:(id)sender;
- (IBAction)tomorrowButtonPressed:(id)sender;
- (IBAction)weekendButtonPressed:(id)sender;

//views
@property (strong, nonatomic)  UIImageView *todayImageView;
@property (strong, nonatomic)  UIImageView *tomorrowImageView;
@property (strong, nonatomic)  UIImageView *weekendImageView;
@property (strong, nonatomic)  UIButton *todayButton;
@property (strong, nonatomic)  UIButton *tomorrowButton;
@property (strong, nonatomic)  UIButton *weekendButton;
@property (strong, nonatomic)  UILabel *topLabel;

@property (strong, nonatomic)  UILabel *todayLabel;
@property (strong, nonatomic)  UILabel *tomorrowLabel;
@property (strong, nonatomic)  UILabel *weekendLabel;

- (IBAction)feedbackPressed:(id)sender;
- (IBAction)bellButtonPressed:(id)sender;



@end
