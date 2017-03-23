//
//  RallyTableViewCell.h
//  Devoo
//
//  Created by Sean Crowe on 5/9/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>


@interface AFIndexedCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

////////
////////

@interface RallyTableViewCell : UITableViewCell

//collection view stuff
@property (weak, nonatomic) IBOutlet AFIndexedCollectionView *collectionView;


- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;


@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
//storyboard views
@property (weak, nonatomic) IBOutlet UILabel *typeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet PFImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *acceptedView;
@property (weak, nonatomic) IBOutlet UIView *declinedView;
@property (weak, nonatomic) IBOutlet UIView *unansweredView;
@property (weak, nonatomic) IBOutlet UIButton *startChatButton;
@property (weak, nonatomic) IBOutlet UIButton *rallyButton;
@property (weak, nonatomic) IBOutlet UILabel *specialLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

//actions
- (IBAction)startChatButtonPressed:(id)sender;
- (IBAction)infoButtonPressed:(id)sender;

@end
