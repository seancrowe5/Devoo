//
//  rootCYOViewController.m
//  Devoo
//
//  Created by Sean Crowe on 4/15/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "rootCYOViewController.h"
#import "RallyContactsTableViewController.h"

@interface rootCYOViewController ()

@end

@implementation rootCYOViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    //Names of the storyboard IDs of the VCs we want
    _questionTitlesArray = @[@"pageContentViewController",@"pageContentViewController2",@"pageContentViewController3",@"pageContentViewController4",@"pageContentViewController5"];

    _pageIndex = 0;
    _activityObject = [[PFObject alloc] initWithClassName:@"Activity"];
    

    // Create page view controller
    self.PageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageViewController"];
    self.PageViewController.dataSource = nil;
    _contentVC1 = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[_contentVC1];
    [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.PageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100);
    [self addChildViewController:_PageViewController];
    [self.view addSubview:_PageViewController.view];
    [self.PageViewController didMoveToParentViewController:self];
    
   //load sticky butotn
    [self stickyButton];
    
    _oval1.image = [UIImage imageNamed:@"Oval 1-filled"];
    
  
    
    
        
 
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:216/255.0 green:97/255.0 blue:80/255.0 alpha:1];
    
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];

    
    self.title = @"Create your own!";
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

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    NSLog(@"View Controller Before is: %@", viewController.restorationIdentifier);

    
    NSUInteger index = ((pageContentCYOViewController *) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    NSLog(@"View Controller After is: %@", viewController.restorationIdentifier);

    NSUInteger index = ((pageContentCYOViewController*) viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    if (index == [_questionTitlesArray count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}


- (pageContentCYOViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([_questionTitlesArray count] == 0) || (index >= [_questionTitlesArray count])) {
        return nil;
    }
    // Create a new view controller and pass suitable data.
    
    pageContentCYOViewController *vc;
    
    if (index == 0) {
        _contentVC1 = [self.storyboard instantiateViewControllerWithIdentifier:_questionTitlesArray[index]];
        vc = _contentVC1;
        
        
    }else if(index == 1){
        _contentVC2 = [self.storyboard instantiateViewControllerWithIdentifier:_questionTitlesArray[index]];
        vc = _contentVC2;
        
    }else if(index == 2){
        _contentVC3 = [self.storyboard instantiateViewControllerWithIdentifier:_questionTitlesArray[index]];
        vc = _contentVC3;

        
    }else if(index == 3){
        _contentVC4 = [self.storyboard instantiateViewControllerWithIdentifier:_questionTitlesArray[index]];
        vc = _contentVC4;

        
    }else if(index == 4){
        _contentVC5 = [self.storyboard instantiateViewControllerWithIdentifier:_questionTitlesArray[index]];
        vc = _contentVC5;
    }
    
    vc.pageIndex = index;
    return vc;
}

- (IBAction)nextbuttonPressed:(id)sender {
    bool noError = true;
    
    
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

    
    
    //get data from current VC
    pageContentCYOViewController *dataVC = [[pageContentCYOViewController alloc] init];
    
    if (_pageIndex == 0) {
        dataVC = _contentVC1;
    
        //error check
        if ([dataVC.responseTextBox.text isEqualToString:@""]) {
            alert.message = @"Make sure you fill out the Activity Name";
            [self presentViewController:alert animated:YES completion:nil];

            noError = false; //there was an error
        }else{
            _activityObject[@"activityName"] = dataVC.responseTextBox.text;
            _oval1.image = [UIImage imageNamed:@"Oval 1"];
            _oval2.image = [UIImage imageNamed:@"Oval 1-filled"];
            [_nextButton setTitle:@"Location" forState:UIControlStateNormal];
            [self animateButtonIn];
        }

    }else if (_pageIndex == 1){
        dataVC = _contentVC2;
        
        //error check
        if ([dataVC.dateTextBox.text isEqualToString:@""]) {
            alert.message = @"Make sure you fill out the date!";
            [self presentViewController:alert animated:YES completion:nil];
            
            noError = false; //there was an error
        }else{
            _activityObject[@"activityStartTime"] = dataVC.activityDate;
            
            //set time string
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm a"]; //Friday, April 15
            _activityObject[@"activityTime"] = [dateFormatter stringFromDate:dataVC.activityDate];

            
            
            _oval2.image = [UIImage imageNamed:@"Oval 1"];
            _oval3.image = [UIImage imageNamed:@"Oval 1-filled"];
            [_nextButton setTitle:@"Description" forState:UIControlStateNormal];
        }


   
    }else if (_pageIndex == 2){
        dataVC = _contentVC3;
        _activityObject[@"activityCost"] = dataVC.locationTextbox.text;
        _oval3.image = [UIImage imageNamed:@"Oval 1"];
        _oval4.image = [UIImage imageNamed:@"Oval 1-filled"];
        [_nextButton setTitle:@"Picture" forState:UIControlStateNormal];

        
    }else if (_pageIndex == 3){
        dataVC = _contentVC4;
        _activityObject[@"activitySpecial"] = dataVC.descriptionTextbox.text;
        _oval4.image = [UIImage imageNamed:@"Oval 1"];
        _oval5.image = [UIImage imageNamed:@"Oval 1-filled"];
        [_nextButton setTitle:@"Rally Friends" forState:UIControlStateNormal];

        
    }else if (_pageIndex == 4){
        dataVC = _contentVC5;
        
        
        //get image if it exists
        if (dataVC.imageChosen) {
            NSData *imageData = UIImagePNGRepresentation(dataVC.imageChosen);
            PFFile *imageFile = [PFFile fileWithName:@"customActivity.png" data:imageData];
            _activityObject[@"activityImage"] = imageFile;
        }

        //makes sure it ain't null
        _activityObject[@"activityType"] = @"";
        _activityObject[@"activityOwner"] = [PFUser currentUser];
        
        //save object in background
        [_activityObject saveInBackground];

        
        //pin object to device and segue
        [_activityObject pinInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

            [self performSegueWithIdentifier:@"showRallyFriends" sender:self];

        }];
        
            }
    
    
    if (_pageIndex < (_questionTitlesArray.count - 1) && noError) {
        
        //increase index
        _pageIndex++;
        
        pageContentCYOViewController *nextVC = [self viewControllerAtIndex:_pageIndex];

        
        NSArray *viewControllers = @[nextVC];
        [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    }
}

- (IBAction)backButtonPressed:(id)sender {
    
    
    if (_pageIndex > 0) {
        //increase index
        _pageIndex--;
        
        pageContentCYOViewController *startingViewController = [self viewControllerAtIndex:_pageIndex];
        
        NSArray *viewControllers = @[startingViewController];
        [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
        
        
        if (_pageIndex == 0) {
            
            //remove back button
            [self animateButtonOut];
            
            
            _oval1.image = [UIImage imageNamed:@"Oval 1-filled"];
            _oval2.image = [UIImage imageNamed:@"Oval 1"];
        }
        
        if (_pageIndex == 1) {
            _oval2.image = [UIImage imageNamed:@"Oval 1-filled"];
            _oval3.image = [UIImage imageNamed:@"Oval 1"];
        }
        
        if (_pageIndex == 2) {
            _oval3.image = [UIImage imageNamed:@"Oval 1-filled"];
            _oval4.image = [UIImage imageNamed:@"Oval 1"];
        }
        
        if (_pageIndex == 3) {
            _oval4.image = [UIImage imageNamed:@"Oval 1-filled"];
            _oval5.image = [UIImage imageNamed:@"Oval 1"];
        }
        
    }
    
    
    

    
}

- (void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    NSLog(@"View Controller is: %@", pageViewController.restorationIdentifier);
    
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [_questionTitlesArray count];
}
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


-(void)stickyButton{
    
    _nextButton = [[UIButton alloc] init];
    _nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    _nextButton.backgroundColor = [UIColor colorWithRed:16/255.0 green:165/255.0 blue:192/255.0 alpha:1];
    [_nextButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [_nextButton setTitle:@"Day & Time" forState:UIControlStateNormal];
    [_nextButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:20.0]];

    [_nextButton addTarget:self
               action:@selector(nextbuttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _nextButton.titleLabel.textColor = [UIColor whiteColor];
    _nextButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    _nextButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    _nextButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    [_nextButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0)];


    
    [self.view addSubview:_nextButton];
    
    _oval1.translatesAutoresizingMaskIntoConstraints = NO;
    _oval2.translatesAutoresizingMaskIntoConstraints = NO;
    _oval3.translatesAutoresizingMaskIntoConstraints = NO;
    _oval4.translatesAutoresizingMaskIntoConstraints = NO;
    _oval5.translatesAutoresizingMaskIntoConstraints = NO;
    
    _backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_backButton setImage:[UIImage imageNamed:@"arrow-left"] forState:UIControlStateNormal];
    [_backButton setTitle:@"" forState:UIControlStateNormal];
    _backButton.alpha = 0.0;

    [self.view bringSubviewToFront:_backButton];
    NSDictionary *views = @{@"view": _nextButton,
                            @"oval1": _oval1,
                            @"oval2": _oval2,
                            @"oval3": _oval3,
                            @"oval4": _oval4,
                            @"oval5": _oval5,
                            @"back": _backButton,
                            @"top": self.topLayoutGuide };
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[top][view]" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(44)]" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[oval1]-(10)-[view]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[oval2]-(10)-[view]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[oval3]-(10)-[view]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[oval4]-(10)-[view]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[oval5]-(10)-[view]" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[back(44)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[back(110)]" options:0 metrics:nil views:views]];

    
    
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:_nextButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.view addConstraint:self.bottomConstraint];
    
    self.bottomConstraintback = [NSLayoutConstraint constraintWithItem:_backButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.view addConstraint:self.bottomConstraintback];
    
    self.leftConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-10)-[view]-(-10)-|" options:0 metrics:nil views:views];
    [self.view addConstraints:_leftConstraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];;
    
}

-(void)keyboardDidShow:(NSNotification *)sender
{
    //https://gist.github.com/dlo/8572874
    
    if(!_movedControls){
        
        
        CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
        
        self.bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
        self.bottomConstraintback.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);

        
        //this re-layouts our view
        [self.view layoutIfNeeded];
        
        _movedControls = true;
    }
    
}

- (void)keyboardWillHide:(NSNotification *)sender {
//    self.bottomConstraint.constant = 0;
//    [self.view layoutIfNeeded];
}

-(void)animateButtonIn{
    [self.view layoutIfNeeded];
    
    NSDictionary *views = @{@"view": _nextButton};
    
    [self.view removeConstraints:_leftConstraints];
    self.leftConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(120)-[view]-(-10)-|" options:0 metrics:nil views:views];
    [self.view addConstraints:_leftConstraints];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:.6
                         animations:^{
                             _backButton.alpha = 1.0;
                         }];
        
        [UIView animateWithDuration:.6
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];

    });
    
}

-(void)animateButtonOut{
    [self.view layoutIfNeeded];
    
    NSDictionary *views = @{@"view": _nextButton};
    
    [self.view removeConstraints:_leftConstraints];
    self.leftConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-10)-[view]-(-10)-|" options:0 metrics:nil views:views];
    [self.view addConstraints:_leftConstraints];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:.6
                         animations:^{
                             _backButton.alpha = 0.0;
                         }];
        
        [UIView animateWithDuration:.6
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
        
    });

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showRallyFriends"]) {
        
        //UINavigationController *nav = [segue destinationViewController];
        //RallyContactsTableViewController *vc = (RallyContactsTableViewController *)nav.topViewController;
        RallyContactsTableViewController *vc = [segue destinationViewController];

        NSArray *array = [[NSArray alloc] initWithObjects:_activityObject, nil];
        vc.activitiesArray = [array mutableCopy];
        
    }
    
}


@end
