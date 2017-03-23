//
//  rootCYOViewController.h
//  Devoo
//
//  Created by Sean Crowe on 4/15/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pageContentCYOViewController.h"
#import <Parse/Parse.h>


@interface rootCYOViewController : UIViewController <UIPageViewControllerDataSource>


@property (nonatomic,strong) UIPageViewController *PageViewController;
@property (nonatomic,strong) pageContentCYOViewController *contentVC1;
@property (nonatomic,strong) pageContentCYOViewController *contentVC2;
@property (nonatomic,strong) pageContentCYOViewController *contentVC3;
@property (nonatomic,strong) pageContentCYOViewController *contentVC4;
@property (nonatomic,strong) pageContentCYOViewController *contentVC5;


@property (nonatomic,strong) NSArray *questionTitlesArray;

@property NSUInteger pageIndex;


- (pageContentCYOViewController *)viewControllerAtIndex:(NSUInteger)index;


- (IBAction)nextbuttonPressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) NSArray *leftConstraints;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraintback;

@property (strong, nonatomic) PFObject *activityObject;
@property bool movedControls;

@property (weak, nonatomic) IBOutlet UIImageView *oval1;
@property (weak, nonatomic) IBOutlet UIImageView *oval2;
@property (weak, nonatomic) IBOutlet UIImageView *oval3;
@property (weak, nonatomic) IBOutlet UIImageView *oval4;
@property (weak, nonatomic) IBOutlet UIImageView *oval5;

//activity props

@end



