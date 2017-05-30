//
//  RSSCollectionViewCell.m
//  RSSParser
//
//  Created by jelfar on 5/29/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import "RSSCollectionViewCell.h"

@implementation RSSCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.3].CGColor;
        self.layer.borderWidth = 1.0f;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height*(.66))];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, self.imageView.frame.size.height + 5, frame.size.width - 6, frame.size.height - self.imageView.frame.size.height - 6)];
        self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(3,
                                                                   self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 5,
                                                                   frame.size.width,
                                                                   frame.size.height - self.titleLabel.frame.origin.y - self.titleLabel.frame.size.height - 5)];
        
        self.descLabel.text = @"";
        self.descLabel.numberOfLines = 2;
        self.descLabel.font = [UIFont systemFontOfSize:14.0f];
        
        self.titleLabel.text = @"";
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.imageView.backgroundColor = [UIColor greenColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.descLabel];
    }
    return self;
}


@end
