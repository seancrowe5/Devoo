//
//  permissionViewController.m
//  Devoo
//
//  Created by Sean Crowe on 5/23/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "permissionViewController.h"
#import <Parse/Parse.h>

@interface permissionViewController ()

@end

@implementation permissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *its = @"yes";
    
    [prefs setObject:its forKey:@"shownPermission"];
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

- (IBAction)soundsGoodPressed:(id)sender {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:^{
            
            
        }];
    }];
    
}

- (IBAction)closePressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];

}
@end
