//
//  RallyTableViewCell.m
//  Devoo
//
//  Created by Sean Crowe on 5/9/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "RallyTableViewCell.h"

@implementation AFIndexedCollectionView

@end
@implementation RallyTableViewCell




-(void)awakeFromNib{
    
    // Initialization code
    [_backgroundImageView.layer setOpacity:1];
    
    
    
    // Add colors to layer
    UIColor *firstColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];

    // Set image over layer
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _backgroundImageView.frame;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[firstColor CGColor],(id)[firstColor CGColor],
                       nil];
    
    
    
    [_backgroundImageView.layer insertSublayer:gradient atIndex:0];
    
    //add blur!
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _blurEffectView.frame = _backgroundImageView.bounds;
    _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _blurEffectView.alpha = 0.0f;
    [_backgroundImageView addSubview:_blurEffectView];
    
    //button round
    _rallyButton.layer.cornerRadius = 4.0;

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)startChatButtonPressed:(id)sender {
}

- (IBAction)infoButtonPressed:(id)sender {
    
    bool isBlurred = false;
    
    if (_blurEffectView.alpha == 1.0f) {
        //the blur view is there!
        isBlurred = true;
    }
    
    
    if (!isBlurred) {
        [UIView animateWithDuration:0.6f animations:^{
            
            [_typeNameLabel setAlpha:0.0f];
            [_priceLabel setAlpha:0.0f];
            [_timeLabel setAlpha:0.0f];
            _blurEffectView.alpha = 1.0f;
            
        }];
        
        [UIView animateWithDuration:0.6f animations:^{
            _rallyButton.alpha = 1.0f;
            _specialLabel.alpha = 1.0f;
            
            
            
        }];

    }else{
        [UIView animateWithDuration:0.6f animations:^{
            
            [_typeNameLabel setAlpha:1.0f];
            [_priceLabel setAlpha:1.0f];
            [_timeLabel setAlpha:1.0f];
            _blurEffectView.alpha = 0.0f;
            
        }];
        
        [UIView animateWithDuration:0.6f animations:^{
            _rallyButton.alpha = 0.0f;
            _specialLabel.alpha = 0.0f;
            
            
            
        }];
    }
    
    
    //fade in stuff
}

-(void)prepareForReuse {
    
    [super prepareForReuse];
    
    //set the alpha for the background image to 0
    _blurEffectView.alpha = 0;
    
    //set the alpha for the special label to 0
    _specialLabel.alpha = 0;

    //set the alpha for the button to 0
    _rallyButton.alpha = 0;

    
    //set the alpha for the activity name to 1
    _typeNameLabel.alpha  = 1;
    
    //set alpha for activit time to 1
    _timeLabel.alpha = 1;
    
    //set alpha for activity price to 1
    _priceLabel.alpha = 1;
    
    
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.indexPath = indexPath;
    
    [self.collectionView reloadData];
}

@end
