//
//  HomeSegmentedViewController.m
//  Devoo
//
//  Created by Sean Crowe on 4/21/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "HomeSegmentedViewController.h"

@interface HomeSegmentedViewController ()

@end

@implementation HomeSegmentedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //take out the shadow line so it looks like the navigation bar is longer than it actually is! woot
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"TransparentPixel"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Pixel"] forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
