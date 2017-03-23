//
//  filterViewController.h
//  Devoo
//
//  Created by Sean Crowe on 3/22/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Canvas.h>

@interface filterViewController : UIViewController

@property bool selectedToday;
@property bool selectedTomorrow;
@property bool selectedWeekend;

- (IBAction)activityButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *findNextButton;

- (IBAction)filterSelected:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *dinner;
@property (weak, nonatomic) IBOutlet UIButton *drink;
@property (weak, nonatomic) IBOutlet UIButton *entertainment;
@property (weak, nonatomic) IBOutlet UIButton *movies;
@property (weak, nonatomic) IBOutlet UIButton *music;
@property (weak, nonatomic) IBOutlet UIButton *arts;
@property (weak, nonatomic) IBOutlet UIButton *experiences;
@property (weak, nonatomic) IBOutlet UIButton *deals;
@property (weak, nonatomic) IBOutlet UIButton *recent;
@property (weak, nonatomic) IBOutlet UIButton *random;
@property (weak, nonatomic) IBOutlet UIButton *sports;
@property (weak, nonatomic) IBOutlet CSAnimationView *nextAnimation;

@property (weak, nonatomic) IBOutlet CSAnimationView *animationView1;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView2;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView3;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView4;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView5;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView6;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView7;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView8;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView9;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView10;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView11;



@end
