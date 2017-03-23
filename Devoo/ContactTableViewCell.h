//
//  ContactTableViewCell.h
//  Devoo
//
//  Created by Sean Crowe on 2/9/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;

@end
