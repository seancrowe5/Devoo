//
//  ExtededView.m
//  Devoo
//
//  Created by Sean Crowe on 4/21/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "ExtededView.h"

@implementation ExtededView


- (void)willMoveToWindow:(UIWindow *)newWindow
{
    NSLog(@"you're being fired");
    // Use the layer shadow to draw a one pixel hairline under this view.
    [self.layer setShadowOffset:CGSizeMake(0, 1.0f/UIScreen.mainScreen.scale)];
    [self.layer setShadowRadius:0];
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.layer setShadowOpacity:0.25f];
    
    self.backgroundColor = [UIColor purpleColor];
}


@end
