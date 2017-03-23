//
//  SCCollectionViewCell.h
//  Devoo
//
//  Created by Sean Crowe on 5/16/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *initialView;
@property (weak, nonatomic) IBOutlet UILabel *initialLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
