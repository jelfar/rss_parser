//
//  RSSDetailViewController.m
//  RSSParser
//
//  Created by jelfar on 5/30/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import "RSSDetailViewController.h"

@interface RSSDetailViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation RSSDetailViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Setup our main view. Point self.view to the webview to make changing orientation work.
    self.webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = self.webView;
    
    //Set webview delegate
    self.webView.delegate = self;
    
    //Create request and load the page on the webview
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.rssEntry.articleURL, @"?displayMobileNavigation=0"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.webView loadRequest:request];
    
    //Create and format loading indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = YES;
    
    //Adds loading indicator on top of the webview
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    
    self.title = self.rssEntry.title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UIWebViewDelegate>

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
{
    [self.activityIndicator startAnimating];
    return YES;
}

- (void)webViewDidFinishLoading:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
}

# pragma mark - Rotation


/*
 * Handles case where phone is rotated while webview is loading
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateActivityIndicatorPosition];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateActivityIndicatorPosition];
    }];
}

- (void)updateActivityIndicatorPosition {
    self.activityIndicator.center = self.view.center;
}

@end
