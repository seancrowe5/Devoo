//
//  ActivityTableViewCell.m
//  Devoo
//
//  Created by Sean Crowe on 2/6/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "ActivityTableViewCell.h"

@implementation ActivityTableViewCell

- (void)awakeFromNib {
    
        
    // Initialization code
    _normalView.backgroundColor = [UIColor blackColor];
    _hideButton = [[UIButton alloc] init];
    _webURL = [[UIButton alloc] init];
    [_backgroundImageView.layer setOpacity:1];

    
    // Add colors to layer
    UIColor *firstColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    UIColor *secondColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    UIColor *thirdColor = [UIColor clearColor];
    UIColor *fourthColor = [UIColor clearColor];
    
    // Set image over layer
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _backgroundImageView.frame;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[firstColor CGColor],
                       (id)[secondColor CGColor],
                       (id)[thirdColor CGColor],
                       (id)[fourthColor CGColor],
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

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//    _flipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height)];
//    _flipView.backgroundColor = [UIColor colorWithRed:177/255.0 green:201/255.0 blue:96/255.0 alpha:1];
//    
//   
//}

-(void)prepareForReuse {
    
    [super prepareForReuse];
    
    _normalView.backgroundColor = [UIColor blackColor];
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

- (IBAction)showAcceptedResultsButtonPressed:(UIButton *)sender {
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
            _locationIcon.alpha = 0;
            _distanceLabel.alpha = 0;
            _blurEffectView.alpha = 1.0f;
            
        }];
        
        [UIView animateWithDuration:0.6f animations:^{
            _detailButton.alpha = 1.0f;
            _specialLabel.alpha = 1.0f;
            _rallyButton.alpha = 1.0f;

            
            
        }];
        
    }else{
        [UIView animateWithDuration:0.6f animations:^{
            
            [_typeNameLabel setAlpha:1.0f];
            [_priceLabel setAlpha:1.0f];
            [_timeLabel setAlpha:1.0f];
            _locationIcon.alpha = 1.0f;
            _distanceLabel.alpha=  1.0f;
            _blurEffectView.alpha = 0.0f;
            
        }];
        
        [UIView animateWithDuration:0.6f animations:^{
            _rallyButton.alpha = 0.0f;
            _specialLabel.alpha = 0.0f;
            
            
            
        }];
    }
    

}
@end
