//
//  webViewController.m
//  Devoo
//
//  Created by Sean Crowe on 2/14/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import "webViewController.h"

@interface webViewController ()

@end

@implementation webViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"url is: %@", _url);
    
    NSString *fullURL = _url;
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    _webView.delegate = self;
    
    [_webView loadRequest:requestObj];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"page is loading");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"finished loading");
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
