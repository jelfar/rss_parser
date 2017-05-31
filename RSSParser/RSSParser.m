//
//  RSSParser.m
//  RSSParser
//
//  Created by jelfar on 5/28/17.
//  Copyright © 2017 jelfar. All rights reserved.
//
//
//  Parses a given url using NSXMLParser. Creates RSSEntry model objects
//  asynchronously from item nodes and stores them in a collection.

#import "RSSParser.h"

@interface RSSParser ()

@property (nonatomic) NSMutableString *xmlString;
@property (nonatomic) NSMutableDictionary *xmlItemDict;

@end

@implementation RSSParser

#pragma mark - Init

/*
 * Default init creates empty URL.
 */
- (instancetype) init {
    if (self = [super init])
    {
        [self initPropertiesWithURL:@""];
    }
    return self;
}

/*
 * Custom init method to take in RSS url.
 */
- (instancetype) initWithURL:(NSString *)URL
{
    if (self = [super init])
    {
        [self initPropertiesWithURL:URL];
    }
    return self;
}

/*
 * Sets up all data members to handle XML parsing.
 */
- (void)initPropertiesWithURL:(NSString *)url {
    self.rssEntries = [NSMutableArray array];
    self.url = url;
    self.xmlString = [NSMutableString string];
    self.xmlItemDict = [NSMutableDictionary dictionary];
}

# pragma mark - Parsing
/*
 * Kicks off actual RSS parsing asynchronously using GCD
 */
- (void) populateRSSEntries {
    if(![self.url length]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:self.url]];
        [parser setDelegate:self];
        [parser parse];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Send notification to let RSSCollectionViewController know the data is ready
            [[NSNotificationCenter defaultCenter] postNotificationName:kRSSupdateCollectionNotification object:self];
        });
    });
    
}

/*
 * Utility to print out rss entries
 */
- (void) printRSSEntries {
    NSLog(@"RSS Entries: \n");
    for(RSSEntry *entry in self.rssEntries) {
        NSLog(@"title: %@", entry.title);
        NSLog(@"pubDate: %@", entry.date);
        NSLog(@"description: %@", entry.desc);
        NSLog(@"articleURL: %@", entry.articleURL);
        NSLog(@"imageURL: %@\n\n", entry.imageURL);
        
    }
}

#pragma mark - NSXMLParserDelegate

/*
 * The basic idea is to cycle through each attribute of each item node and add them to
 * a dictionary. Once you reach the end of a given item node, create an RSSEntry using
 * the dictionary built for that node. Then, clear the dictionary and repeat.
 *
 * The string xmlString is used to obtain the data in between each start/end tag. It is cleared
 * after an end tag is found in order to cycle through each item's attributes.
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(nonnull NSDictionary<NSString *,NSString *> *)attributeDict {
    if([elementName isEqualToString:@"item"]) {
        [self.xmlItemDict removeAllObjects];
    }
    
    if([elementName isEqualToString:@"media:content"]) { //handle this case in didStartElement because we dont have attributeDict in didEndElement
        NSString *stringValue = [[attributeDict objectForKey:@"url"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.xmlItemDict setObject:stringValue forKey:@"imageURL"];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(nonnull NSString *)string {
    [self.xmlString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName {
    if([elementName isEqualToString:@"item"]) {
        [self.rssEntries addObject:[[RSSEntry alloc] initWithTitle:[self.xmlItemDict objectForKey:@"title"]
                                                       withPubDate:[self.xmlItemDict objectForKey:@"pubDate"]
                                                   withDescription:[self.xmlItemDict objectForKey:@"description"]
                                                    withArticleURL:[self.xmlItemDict objectForKey:@"link"]
                                                      withImageURL:[self.xmlItemDict objectForKey:@"imageURL"]]];
    }
    
    if([elementName isEqualToString:@"title"] ||
       [elementName isEqualToString:@"description"] ||
       [elementName isEqualToString:@"pubDate"] ||
       [elementName isEqualToString:@"link"]) {
        NSString *stringValue = [self.xmlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *stringKey = [elementName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.xmlItemDict setObject:stringValue forKey:stringKey];
    }
    [self.xmlString setString:@""];
}

@end
