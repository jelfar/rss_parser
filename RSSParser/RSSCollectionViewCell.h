//
//  RSSCollectionViewCell.h
//  RSSParser
//
//  Created by jelfar on 5/29/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RSSEntry.h"

@interface RSSCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) RSSEntry *rssNode;

@end
