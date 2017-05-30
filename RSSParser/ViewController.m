//
//  ViewController.m
//  RSSParser
//
//  Created by jelfar on 5/28/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import "ViewController.h"

static NSString * const kPCBlogURL = @"https://www.personalcapital.com/blog/feed/?cat=3%2C891%2C890%2C68%2C284";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.rssParser = [[RSSParser alloc] initWithURL:kPCBlogURL];
    [self.rssParser populateRSSEntries];
    
    self.rssCollectionViewController = [[RSSCollectionViewController alloc] init];
    self.rssCollectionViewController.rssParser = self.rssParser;
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
    [self.navigationController pushViewController:self.rssCollectionViewController animated:NO];
    //[self addChildViewController:self.rssCollectionViewController];
    //[self.view addSubview:self.rssCollectionViewController.view];
    //[self.rssCollectionViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
