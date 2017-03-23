//
//  SelectDayViewController.m
//  Devoo
//
//  Created by Sean Crowe on 3/13/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "SelectDayViewController.h"
#import "filterViewController.h"
#import <Parse/Parse.h>

@interface SelectDayViewController (){
    UIButton *floatingPlus;
    CGPoint center;
    bool buttonIsRect;

    bool selectedToday;
    bool selectedTomorrow;
    bool selectedWeekend;

}

@end


const float klabelTopMargin = 10.0;
const float klabelHeight = 20.0;
const float klabelBottomMargin = 10.0;
const float klabelLeftMargin = 10.0;
const float klabelRightMargin = 10.0;
const float kimageInside = 10.0;
const float kImageBottom = 10.0;



@implementation SelectDayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    selectedToday = false;
    selectedTomorrow = false;
    selectedWeekend = false;
    
    //title bar
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-text"]];
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
        
    //barbutton
    // Build your regular UIBarButtonItem with Custom View
    UIImage *image = [UIImage imageNamed:@"Bell"];
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithImage:image
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(bellButtonPressed:)];

    self.navigationItem.rightBarButtonItem = navLeftButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeCount) name:@"updateBarButtonBadge" object:nil];
    
    
    
    //Initialize
    _topLabel = [[UILabel alloc] init];
    
    _todayImageView = [[UIImageView alloc] init];
    _tomorrowImageView = [[UIImageView alloc] init];
    _weekendImageView = [[UIImageView alloc] init];
    
    _todayButton = [[UIButton alloc] init];
    _tomorrowButton = [[UIButton alloc] init];
    _weekendButton = [[UIButton alloc] init];
    
    _todayLabel = [[UILabel alloc] init];
    _tomorrowLabel = [[UILabel alloc] init];
    _weekendLabel = [[UILabel alloc] init];

    
    //autolaoyout
    _topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _todayImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _tomorrowImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _weekendImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _todayButton.translatesAutoresizingMaskIntoConstraints = NO;
    _tomorrowButton.translatesAutoresizingMaskIntoConstraints = NO;
    _weekendButton.translatesAutoresizingMaskIntoConstraints = NO;
    _todayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tomorrowLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _weekendLabel.translatesAutoresizingMaskIntoConstraints = NO;

    
    //Label Props
    _topLabel.text = @"When do you want to make plans?";
    [_topLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:17.0]];
    _topLabel.adjustsFontSizeToFitWidth = YES;
    [_topLabel setTextAlignment:NSTextAlignmentCenter];
    
    //Today image props
    _todayImageView.image = [UIImage imageNamed:@"today"];
    _todayImageView.contentMode = UIViewContentModeScaleAspectFill;
    _todayImageView.clipsToBounds = YES;
    
    _tomorrowImageView.image = [UIImage imageNamed:@"tomorrow"];
    _tomorrowImageView.contentMode = UIViewContentModeScaleAspectFill;
    _tomorrowImageView.clipsToBounds = YES;
    
    _weekendImageView.image = [UIImage imageNamed:@"weekend"];
    _weekendImageView.contentMode = UIViewContentModeScaleAspectFill;
    _weekendImageView.clipsToBounds = YES;
    
    //buttons
    [_todayButton setImage: [UIImage imageNamed:@"Stopwatch-60"] forState:UIControlStateNormal];
    [_tomorrowButton setImage: [UIImage imageNamed:@"Arrow-60"] forState:UIControlStateNormal];
    [_weekendButton setImage: [UIImage imageNamed:@"Wine-60"] forState:UIControlStateNormal];

    
    //center
    CGFloat spacing = 6.0;
    CGSize imageSized = _todayButton.imageView.image.size;
    _todayButton.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSized.width, - (imageSized.height + spacing), 0.0);
    CGSize titleSize = [_todayButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _todayButton.titleLabel.font}];
    _todayButton.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (25), 0.0, 0.0, - titleSize.width);
    
    CGSize imageSized1 = _tomorrowButton.imageView.image.size;
    _tomorrowButton.titleEdgeInsets = UIEdgeInsetsMake(
                                                    0.0, - imageSized1.width, - (imageSized1.height + spacing), 0.0);
    CGSize titleSize1 = [_tomorrowButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _tomorrowButton.titleLabel.font}];
    _tomorrowButton.imageEdgeInsets = UIEdgeInsetsMake(
                                                    - (25), 0.0, 0.0, - titleSize1.width);
    
    CGSize imageSized2 = _weekendButton.imageView.image.size;
    _weekendButton.titleEdgeInsets = UIEdgeInsetsMake(
                                                    0.0, - imageSized2.width, - (imageSized2.height + spacing), 0.0);
    CGSize titleSize3 = [_weekendButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _weekendButton.titleLabel.font}];
    _weekendButton.imageEdgeInsets = UIEdgeInsetsMake(
                                                    - (25), 0.0, 0.0, - titleSize.width);
    
    
    //actions
    [_todayButton addTarget:self action:@selector(todayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_tomorrowButton addTarget:self action:@selector(tomorrowButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_weekendButton addTarget:self action:@selector(weekendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    //today label
    _todayLabel.text = [self setTitleLabel:_todayLabel];
    _todayLabel.textAlignment = NSTextAlignmentCenter;
    _todayLabel.textColor = [UIColor whiteColor];
    _todayLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:23];
    
    _tomorrowLabel.text = [self setTitleLabel:_tomorrowLabel];
    _tomorrowLabel.textAlignment = NSTextAlignmentCenter;
    _tomorrowLabel.textColor = [UIColor whiteColor];
    _tomorrowLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:23];

    _weekendLabel.text = [self setTitleLabel:_weekendLabel];
    _weekendLabel.textAlignment = NSTextAlignmentCenter;
    _weekendLabel.textColor = [UIColor whiteColor];
    _weekendLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:23];
    
    
    [self.view addSubview:_topLabel];
    [self.view addSubview:_todayImageView];
    [self.view addSubview:_tomorrowImageView];
    [self.view addSubview:_weekendImageView];
    [self.view addSubview:_todayButton];
    [self.view addSubview:_tomorrowButton];
    [self.view addSubview:_weekendButton];
    [self.view addSubview:_todayLabel];
    [self.view addSubview:_tomorrowLabel];
    [self.view addSubview:_weekendLabel];


    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = 20.0;
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat visibleArea = viewHeight - statusBarHeight - navHeight;
 
    
    //visible area - (top + bottom + imageMargin + imageMargin + bottomMargin)
    CGFloat totalImageSize = visibleArea - (klabelTopMargin + klabelBottomMargin + kimageInside + kimageInside + kImageBottom + klabelHeight);
    CGFloat singleImage = totalImageSize/3;

    NSLog(@"visible %f", visibleArea);
    
    
    NSDictionary *views = @{@"todayImage": _todayImageView,
                            @"tomorrowImage": _tomorrowImageView,
                            @"tomorrowButton": _tomorrowButton,
                            @"weekendImage": _weekendImageView,
                            @"weekendButton": _weekendButton,
                            @"topLabel": _topLabel,
                            @"todayButton": _todayButton,
                            @"tomorrowButton": _tomorrowButton,
                            @"weekendButton": _weekendButton,
                            @"todayLabel": _todayLabel,
                            @"tomorrowLabel": _tomorrowLabel,
                            @"weekendLabel": _weekendLabel};
    
    
    NSNumber *labelTop = [NSNumber numberWithFloat:klabelTopMargin];
    NSNumber *labelLeft = [NSNumber numberWithFloat:klabelLeftMargin];
    NSNumber *labelRight = [NSNumber numberWithFloat:klabelRightMargin];
    NSNumber *labelBottom = [NSNumber numberWithFloat:klabelBottomMargin];
    NSNumber *imageInside = [NSNumber numberWithFloat:kimageInside];
    NSNumber *imageBottom = [NSNumber numberWithFloat:kImageBottom];
    NSNumber *imageSize = [NSNumber numberWithFloat:singleImage];
    NSNumber *lableHeight = [NSNumber numberWithFloat:klabelHeight];


    
    NSDictionary *metrics = @{@"labelTop": labelTop,
                            @"labelBottom": labelBottom,
                            @"labelLeft": labelLeft,
                             @"labelRight": labelRight,
                              @"imageSize": imageSize,
                              @"imageInside": imageInside,
                              @"imageBottom": imageBottom,
                              @"labelHeight": lableHeight};
    
    
    //top label
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(labelLeft)-[topLabel]-(labelRight)-|"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(labelTop)-[topLabel(labelHeight)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];

    //today image
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[todayImage]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLabel]-(8)-[todayImage(imageSize)]" //third of height
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //today button
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[todayButton]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLabel]-(8)-[todayButton(imageSize)]" //third of height
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //today label
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[todayLabel]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[todayButton]-(-65)-[todayLabel(40)]" //third of height
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    
    //tomorrow image
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[tomorrowImage]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[todayImage]-(imageInside)-[tomorrowImage(imageSize)]" //third of height
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //tomorrow button
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[tomorrowButton]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[todayImage]-(imageInside)-[tomorrowButton(imageSize)]" //third of height
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //tomorrow label
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[tomorrowLabel]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[tomorrowButton]-(-65)-[tomorrowLabel(40)]" //third of height
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //weenked image
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[weekendImage]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[tomorrowImage]-(imageInside)-[weekendImage(imageSize)]" //third of height
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //weenked button
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[weekendButton]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[tomorrowImage]-(imageInside)-[weekendButton(imageSize)]" //third of height
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];

    
    //tomorrow label
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[weekendLabel]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[weekendButton]-(-65)-[weekendLabel(40)]" //third of height
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];

    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated{
    
    //floating plus button Plus-80
    floatingPlus = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 90,self.view.bounds.size.height-15,60, 60)];
    floatingPlus.backgroundColor = [UIColor colorWithRed:216/255.0 green:97/255.0 blue:80/255.0 alpha:1];
    [floatingPlus setTitle:@"+" forState:UIControlStateNormal];
    [floatingPlus.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:50.0]];
    floatingPlus.layer.cornerRadius = floatingPlus.layer.bounds.size.width/2;
    [floatingPlus addTarget:self action:@selector(showCYOViewController) forControlEvents:UIControlEventTouchUpInside];
    floatingPlus.layer.shadowColor = [UIColor blackColor].CGColor;
    floatingPlus.layer.shadowOpacity = 0.8;
    floatingPlus.layer.shadowRadius = 5;
    floatingPlus.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    [self.navigationController.view addSubview:floatingPlus];
    
    center = floatingPlus.center;
    buttonIsRect = false;
 
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:16/255.0 green:165/255.0 blue:192/255.0 alpha:1]; //teal
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [floatingPlus removeFromSuperview];
    
    
}

-(void)showCYOViewController{
    [self performSegueWithIdentifier:@"showCreateYourOwn" sender:self];
}
                                                         

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showFilterIcons"]) {
        filterViewController *vc = segue.destinationViewController;
        
        if (selectedToday) {
            NSLog(@"SELECTED TODAY SEGUED");
            vc.selectedToday = true;
        }else if (selectedTomorrow) {
            NSLog(@"SELECTED TOMORROW SEGUED");
            vc.selectedTomorrow = true;
        }else if (selectedWeekend){
            NSLog(@"SELECTED WEEKEND SEGUED");
            vc.selectedWeekend = true;
        }
        
    }
}


- (IBAction)todayButtonPressed:(id)sender {
    NSLog(@"SELECTED TODAY PRESSED");
    selectedToday = true;
    selectedTomorrow = false;
    selectedWeekend = false;
    
    [self performSegueWithIdentifier:@"showFilterIcons" sender:self];
}

- (IBAction)tomorrowButtonPressed:(id)sender {
    
    NSLog(@"SELECTED TOMORROW PRESSED");
    selectedToday = false;
    selectedTomorrow = true;
    selectedWeekend = false;
    [self performSegueWithIdentifier:@"showFilterIcons" sender:self];

}

- (IBAction)weekendButtonPressed:(id)sender {
    
    NSLog(@"SELECTED WEEKEND PRESSED");
    selectedToday = false;
    selectedTomorrow = false;
    selectedWeekend = true;
    [self performSegueWithIdentifier:@"showFilterIcons" sender:self];

}

-(NSString *)setTitleLabel:(UILabel*)label{
    NSString *labelString;
    NSDate* curDate = [NSDate date];
    int dayInt = [[[NSCalendar currentCalendar] components: NSCalendarUnitWeekday fromDate: curDate] weekday];
    
    //1=sun 2=mon 3=tues 4=wed 5=thur 6=fri 7=sat
    NSLog(@"weekday int is: %d", dayInt);
    
    if (dayInt == 6) {
        //FRIDAY
        if (label == _todayLabel) {
            labelString = @"TODAY";
        }
        
        if (label == _tomorrowLabel) {
            labelString = @"TOMORROW";
        }
        
        if (label == _weekendLabel) {
            labelString = @"SUNDAY";
        }
        
    }else if(dayInt == 7){
        //SATURDAY
        
        if (label == _todayLabel) {
            labelString = @"TODAY";
        }
        
        if (label == _tomorrowLabel) {
            labelString = @"SUNDAY";
        }
        
        if (label == _weekendLabel) {
            labelString = @"NEXT WEEKEND";
        }
        
    }else if(dayInt == 1){
        //SUNDAY
        if (label == _todayLabel) {
            labelString = @"TODAY";
        }
        
        if (label == _tomorrowLabel) {
            labelString = @"TOMORROW";
        }
        
        if (label == _weekendLabel) {
            labelString = @"NEXT WEEKEND";
        }
        
    }else{
        //ELSE
        
        if (label == _todayLabel) {
            labelString = @"TODAY";
        }
        
        if (label == _tomorrowLabel) {
            labelString = @"TOMORROW";
        }
        
        if (label == _weekendLabel) {
            labelString = @"THIS WEEKEND";
        }
    }

    return labelString;
}

- (IBAction)feedbackPressed:(id)sender {
    
    [self showEmail:sender];
}

- (IBAction)bellButtonPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"showRallies" sender:self];
    
    self.navigationItem.rightBarButtonItem.badgeValue = @"0";

}

- (IBAction)showEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = @"Send Feedback";
    // Email Content
    NSString *messageBody = @"Devoo Team:";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"jose@devooapp.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    // remove the custom nav bar font
    NSMutableDictionary* navBarTitleAttributes = [[UINavigationBar appearance] titleTextAttributes].mutableCopy;
    UIFont* navBarTitleFont = navBarTitleAttributes[NSFontAttributeName];
    navBarTitleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:navBarTitleFont.pointSize];
    [[UINavigationBar appearance] setTitleTextAttributes:navBarTitleAttributes];
    
    
    if ([MFMailComposeViewController canSendMail]) {
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];

        [self presentViewController:mc animated:YES completion:NULL];
    }
    
    }

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)updateBadgeCount{
    
    self.navigationItem.rightBarButtonItem.badgeValue = @"1";

}

@end
