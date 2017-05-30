//
//  RSSDetailViewController.h
//  RSSParser
//
//  Created by jelfar on 5/30/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSEntry.h"

@interface RSSDetailViewController : UIViewController

@property (nonatomic, weak) RSSEntry *rssEntry;

@end
