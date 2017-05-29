//
//  RSSParser.h
//  RSSParser
//
//  Created by jelfar on 5/28/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import "RSSEntry.h"
#import <Foundation/Foundation.h>

@interface RSSParser : NSObject <NSXMLParserDelegate>

@property NSMutableArray *rssEntries;
@property (copy) NSString *url;

- (instancetype) initWithURL:(NSString *)URL;
- (void) populateRSSEntries;


@end
