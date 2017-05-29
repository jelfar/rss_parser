//
//  RSSEntry.m
//  RSSParser
//
//  Created by jelfar on 5/28/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import "RSSEntry.h"

@implementation RSSEntry

/*
 * Custom init method to set model values
 */
- (instancetype) initWithTitle:(NSString *)title
                   withPubDate:(NSString *)pDate
               withDescription:(NSString *)desc
                withArticleURL:(NSString *)aURL
                  withImageURL:(NSString *)iURL
{
    if (self = [super init])
    {
        self.title = title;
        self.date = pDate;
        self.desc = desc;
        self.articleURL = aURL;
        self.imageURL = iURL;
    }
    return self;
}

@end
