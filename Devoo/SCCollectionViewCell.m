//
//  SCCollectionViewCell.m
//  Devoo
//
//  Created by Sean Crowe on 5/16/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "SCCollectionViewCell.h"

@implementation SCCollectionViewCell


-(void)prepareForReuse {
    
    [super prepareForReuse];
    _initialView.backgroundColor = [UIColor lightGrayColor];
    _nameLabel.textColor = [UIColor lightGrayColor];
    _initialView.tag = 0;
    }


@end
