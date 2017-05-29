//
//  RSSEntry.h
//  RSSParser
//
//  Created by jelfar on 5/28/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface RSSEntry : NSObject

@property (copy) NSString *title;
@property NSString *imageURL;
@property NSString *desc;
@property NSString *date;
@property NSString *articleURL;

- (instancetype) initWithTitle:(NSString *)title
                   withPubDate:(NSString *)pDate
               withDescription:(NSString *)desc
                withArticleURL:(NSString *)aURL
                  withImageURL:(NSString *)iURL;

@end
