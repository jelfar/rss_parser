//
//  RSSCollectionViewController.m
//  RSSParser
//
//  Created by jelfar on 5/29/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import "RSSCollectionViewController.h"

@interface RSSCollectionViewController ()

@end

@implementation RSSCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const headerReuseIdentifier = @"HeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, [[UIScreen mainScreen] bounds].size.width - 20, [[UIScreen mainScreen] bounds].size.height)];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView registerClass:[RSSCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerReuseIdentifier];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    self.navigationItem.hidesBackButton = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCollection)
                                                 name:@"RSSUpdateCollection"
                                               object:nil];
    self.rssEntries = [NSMutableArray array];
    self.imageCache = [NSMutableDictionary dictionary];
}

- (void)updateCollection {
    NSLog(@"we updated the collection successfully");
    self.rssEntries = self.rssParser.rssEntries;
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
//    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
//    [flowLayout invalidateLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateBoundsAndReloadData];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateBoundsAndReloadData];
    }];
}

- (void)updateBoundsAndReloadData {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    [flowLayout invalidateLayout];
    [self.collectionView setFrame:CGRectMake(10, 0, [[UIScreen mainScreen] bounds].size.width - 20, [[UIScreen mainScreen] bounds].size.height)];
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerReuseIdentifier forIndexPath:indexPath];
    //headerView.backgroundColor = [UIColor redColor];
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Previous Articles";
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    label.frame = CGRectMake(10, 0, label.frame.size.width, label.frame.size.height);
    [headerView addSubview:label];
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if([self.rssEntries count] == 0) {
        return CGSizeZero;
    }
    
    if(section == 1) {
        return CGSizeMake(self.view.frame.size.width, 20);
    }
    return CGSizeZero;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if([self.rssEntries count] == 0) {
        return 0;
    }
    
    if(section == 0) {
        return 1;
    }
    return [self.rssEntries count] - 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat width = indexPath.section == 0 ? self.view.frame.size.width - 20 : self.view.frame.size.width/2 - 15; //first cell will be full width
    CGSize itemSize = CGSizeMake(width -
                                 flowLayout.sectionInset.left -
                                 flowLayout.sectionInset.right -
                                 self.collectionView.contentInset.left -
                                 self.collectionView.contentInset.right, 300);
    return itemSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RSSCollectionViewCell *cell = (RSSCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    if(indexPath.section == 0) {
        cell.rssNode = [self.rssEntries firstObject];
        
        cell.descLabel.hidden = NO;
    } else {
        cell.rssNode = [self.rssEntries objectAtIndex:indexPath.row + 1];
        
        cell.descLabel.hidden = YES;
    }
    
    [cell.titleLabel setText:cell.rssNode.title];
    [cell.titleLabel sizeToFit];
    
    cell.descLabel.text = @"";
    
    NSString *dateString = cell.rssNode.date;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d\\d\\d\\d" options:0 error:nil];
    NSRange needleRange = [regex rangeOfFirstMatchInString:dateString options:0 range:NSMakeRange(0, dateString.length)];
    if(needleRange.location != NSNotFound) {
        dateString = [dateString substringWithRange:NSMakeRange(0, needleRange.location + 4)];
    }
    
    cell.descLabel.text = [NSString stringWithFormat:@"%@ — %@", dateString, cell.rssNode.desc];
    [cell.descLabel sizeToFit];
    
    if(indexPath.section == 0) {
        [cell.titleLabel setFrame:CGRectMake(8, cell.imageView.frame.size.height + 5, cell.frame.size.width - 16, 40)];
        cell.titleLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        [cell.titleLabel setFrame:CGRectMake(5, cell.imageView.frame.size.height + 5, cell.frame.size.width - 10, cell.frame.size.height - cell.imageView.frame.size.height - 10)];
        cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    [cell.imageView setFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height*(.66))];
    //[cell.titleLabel setFrame:CGRectMake(5, cell.imageView.frame.size.height + 5, cell.frame.size.width - 10, cell.frame.size.height - cell.imageView.frame.size.height - 10)];
    [cell.descLabel setFrame:CGRectMake(8,
                                        cell.titleLabel.frame.size.height + cell.titleLabel.frame.origin.y + 5,
                                        cell.frame.size.width - 16,
                                        cell.descLabel.frame.size.height)];
                                        //cell.frame.size.height - cell.titleLabel.frame.size.height - cell.titleLabel.frame.origin.y - 5)];
    
    [self loadImageForCell:cell withIndexPath:indexPath];
    
    return cell;
}

- (void)loadImageForCell:(RSSCollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    NSString *imageKey = [NSString stringWithFormat:@"%@", indexPath];
    cell.imageView.image = nil;
    if([self.imageCache objectForKey:imageKey]) {
        cell.imageView.image = [self.imageCache objectForKey:imageKey];
    } else {
        NSURL *url = [NSURL URLWithString:cell.rssNode.imageURL];
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data) {
                UIImage *image = [UIImage imageWithData:data];
                if(image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.imageCache setObject:image forKey:imageKey];
                        RSSCollectionViewCell *updatedCell = (RSSCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                        if(updatedCell) {
                            cell.imageView.image = image;
                        }
                        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    });
                }
            }
        }];
        [task resume];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
