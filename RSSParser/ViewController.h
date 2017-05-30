//
//  ViewController.h
//  RSSParser
//
//  Created by jelfar on 5/28/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSCollectionViewController.h"
#import "RSSParser.h"


@interface ViewController : UIViewController

@property (nonatomic) RSSCollectionViewController *rssCollectionViewController;
@property (nonatomic, strong) RSSParser *rssParser;

@end

