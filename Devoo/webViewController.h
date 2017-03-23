//
//  webViewController.h
//  Devoo
//
//  Created by Sean Crowe on 2/14/16.
//  Copyright © 2016 Devoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface webViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic)  NSString *url;

@end
