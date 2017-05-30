//
//  RSSCollectionViewController.h
//  RSSParser
//
//  Created by jelfar on 5/29/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import "RSSCollectionViewCell.h"
#import "RSSParser.h"
#import <UIKit/UIKit.h>

@interface RSSCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *rssEntries;
@property (nonatomic, strong) RSSParser *rssParser;
@property (nonatomic, strong) NSMutableDictionary *imageCache;

@end
