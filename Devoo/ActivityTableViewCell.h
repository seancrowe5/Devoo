//
//  ActivityTableViewCell.h
//  Devoo
//
//  Created by Sean Crowe on 2/6/16.
//  Copyright © 2016 Devoo. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface ActivityTableViewCell : UITableViewCell

//Storyboard Elements

//normal view
@property (weak, nonatomic) IBOutlet PFImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *typeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImage;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (strong, nonatomic)  UIButton *hideButton;
@property (weak, nonatomic) IBOutlet UIView *normalView;
@property (weak, nonatomic) IBOutlet UIView *ribbonView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locationIcon;
@property (weak, nonatomic) IBOutlet UIButton *rallyButton;

//ribbon view
@property (weak, nonatomic) IBOutlet UILabel *ralliersLabel;
@property (weak, nonatomic) IBOutlet UIButton *ralliersButton;
- (IBAction)showAcceptedResultsButtonPressed:(UIButton *)sender;

//flip view
@property (strong, nonatomic) NSString *specialString;
@property (strong, nonatomic) UIButton *webURL;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (weak, nonatomic) IBOutlet UILabel *specialLabel;

//@property bool isFlipped;
@property (strong,nonatomic) UILabel *detailsLabel;
- (IBAction)infoButtonPressed:(id)sender;

//actions
//- (IBAction)flipbuttonAction:(UIButton *)sender;

//methods

@end
