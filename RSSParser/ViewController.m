//
//  ViewController.m
//  RSSParser
//
//  Created by jelfar on 5/28/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import "RSSParser.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    RSSParser *parser = [[RSSParser alloc] initWithURL:@"https://www.personalcapital.com/blog/feed/?cat=3%2C891%2C890%2C68%2C284"];
    [parser populateRSSEntries];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
