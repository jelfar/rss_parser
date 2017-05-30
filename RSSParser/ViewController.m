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
    
    //Create the view controller 
    self.rssCollectionViewController = [[RSSCollectionViewController alloc] init];
    
    //Create RSS Parser and begin populating entries
    self.rssParser = [[RSSParser alloc] initWithURL:kPCBlogURL];
    [self.rssParser populateRSSEntries];
    
    //Give the collection view controller access to rssParser
    self.rssCollectionViewController.rssParser = self.rssParser;
    
    //Set the frame of the view and push on the collection view controller
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
    [self.navigationController pushViewController:self.rssCollectionViewController animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
