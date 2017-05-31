//
//  RSSCollectionViewController.m
//  RSSParser
//
//  Created by jelfar on 5/29/17.
//  Copyright © 2017 jelfar. All rights reserved.
//

#import "RSSCollectionViewController.h"

@interface RSSCollectionViewController ()

@property (nonatomic, assign) BOOL isRefreshingData;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation RSSCollectionViewController

//Local constants
static NSString * const kRSSreuseIdentifier = @"Cell";
static NSString * const kRSSheaderReuseIdentifier = @"HeaderView";
static NSInteger const kRSScollectionViewItemHeight = 300;

#pragma mark - UIViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, [[UIScreen mainScreen] bounds].size.width - 20, [[UIScreen mainScreen] bounds].size.height)];
    
    //Create layout for collection view
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    //Set insets for top and bottom only. This allows for equal spacing between the two columns
    //as long as the frame of the collectionview is explicitly set with margins.
    layout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //Setup collectionview and register classes for a custom cell as well as for the custom header view
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView registerClass:[RSSCollectionViewCell class] forCellWithReuseIdentifier:kRSSreuseIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kRSSheaderReuseIdentifier];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    
    //Setup loading indicator for main feed
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.activityIndicator];
    
    //Hide back button as this is now the main view
    self.navigationItem.hidesBackButton = YES;
    
    //Add refresh button to nav bar
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshCollection)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    //This notification is used by the RSSParser to relay that the data has been loaded
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCollection)
                                                 name:kRSSupdateCollectionNotification
                                               object:nil];
    
    self.rssEntries = [NSMutableArray array];
    self.imageCache = [NSMutableDictionary dictionary];
    
    self.title = @"Research and Insights";
    self.isRefreshingData = NO;
}

/*
 * Callback for when all rssEntries have been loaded from RSSParser.
 */
- (void)updateCollection {
    self.rssEntries = [self.rssParser.rssEntries copy]; //Use copy to make refreshing smooth
    [self.imageCache removeAllObjects]; //Clear our cache to start fresh
    [self.collectionView reloadData]; //Reload the new data
    self.navigationItem.rightBarButtonItem.enabled = YES; //Enable refresh button once we have our data
    self.isRefreshingData = NO;
    [self.activityIndicator stopAnimating];
}

/*
 * Handles action of clicking refresh button to kick off rss parsing.
 */
- (void)refreshCollection {
    //Disable refresh button on press to limit how many times it can be spammed
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.isRefreshingData = YES;
    
    //Cancel all downloading tasks to make sure we start fresh
    [[NSURLSession sharedSession] getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        for(NSURLSessionDataTask *downloadTask in downloadTasks) {
            [downloadTask cancel];
        }
        
        //Request for data
        [self.rssParser.rssEntries removeAllObjects];
        [self.rssParser populateRSSEntries];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - <UICollectionViewDataSource>

/*
 * Custom header view for "Previous Articles"
 */
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kRSSheaderReuseIdentifier forIndexPath:indexPath];
    //headerView.backgroundColor = [UIColor redColor];
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Previous Articles";
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    label.frame = CGRectMake(10, 0, label.frame.size.width, label.frame.size.height);
    [headerView addSubview:label];
    return headerView;
}

/*
 * The first section will have only one item to be displayed larger than the rest.
 * The second section will contain all other rss entries.
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

/*
 * Return number of elements with section in consideration (first section has 1 element always)
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if([self.rssEntries count] == 0) {
        return 0;
    }
    
    if(section == 0) {
        return 1;
    }
    return [self.rssEntries count] - 1;
}

/*
 * Selecting an item will open a detail view with respective webview
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RSSEntry *selectedEntry;
    if(indexPath.section == 0) {
        selectedEntry = [self.rssEntries objectAtIndex:0];
    } else {
        selectedEntry = [self.rssEntries objectAtIndex:indexPath.row + 1];
    }
    
    RSSDetailViewController *detailViewController = [[RSSDetailViewController alloc] init];
    detailViewController.rssEntry = selectedEntry;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

/*
 * Setup each item in the collectionView
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RSSCollectionViewCell *cell = (RSSCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRSSreuseIdentifier forIndexPath:indexPath];
    
    //Set appropriate rssNode object
    cell.rssNode = indexPath.section == 0 ? [self.rssEntries firstObject] : [self.rssEntries objectAtIndex:indexPath.row + 1];
    
    //Set frame of imageview
    [cell.imageView setFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height*(.66))];
    
    //Position loading indicator
    cell.activityIndicator.center = cell.imageView.center;
    
    //Set title and description text if applicable
    [self formatTitleAndDescriptionWithCell:cell withIndexPath:indexPath];
    
    //Load image
    [self loadImageForCell:cell withIndexPath:indexPath];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

/*
 * Set size of each item in the collectionView. Account for different amount of rows on ipad vs iphone as well
 * as only having one item in the first section.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat width;
    if(indexPath.section == 0) {
        width = self.view.frame.size.width - 20;
    } else {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { //rows of 3 for ipad
            width = self.view.frame.size.width/3 - 15;
        } else {
            width = self.view.frame.size.width/2 - 15;
        }
    }
    CGSize itemSize = CGSizeMake(width -
                                 flowLayout.sectionInset.left -
                                 flowLayout.sectionInset.right -
                                 self.collectionView.contentInset.left -
                                 self.collectionView.contentInset.right, kRSScollectionViewItemHeight);
    return itemSize;
}

/*
 * Return a reference size for the header of section 1. Any other case should return an empty size.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if([self.rssEntries count] == 0) {
        return CGSizeZero;
    }
    
    if(section == 1) {
        return CGSizeMake(self.view.frame.size.width, 20);
    }
    return CGSizeZero;
}

#pragma mark - Cell Formatting Helpers

/*
 * Loads article images for each cell. Caches image to avoid excessive requests.
 */
- (void)loadImageForCell:(RSSCollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    [cell.activityIndicator startAnimating];
    
    //Unique key combining section and row
    NSString *imageKey = [NSString stringWithFormat:@"%ld%ld", (long)indexPath.section, (long)indexPath.row];
    cell.imageView.image = nil;
    if([self.imageCache objectForKey:imageKey]) { //Image has already been downloaded
        cell.imageView.image = [self.imageCache objectForKey:imageKey];
        [cell.activityIndicator stopAnimating];
    } else {
        NSURL *url = [NSURL URLWithString:cell.rssNode.imageURL];
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data) {
                UIImage *image = [UIImage imageWithData:data];
                if(image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([self indexPathIsValid:indexPath] && !self.isRefreshingData) {
                            [self.imageCache setObject:image forKey:imageKey];
                            RSSCollectionViewCell *updatedCell = (RSSCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                            
                            //Make sure cell is still on screen by calling cellForItemAtIndexPath
                            if(updatedCell) {
                                updatedCell.imageView.image = image;
                                [updatedCell.activityIndicator stopAnimating];
                            }
                            
                            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                            
                        }
                    });
                }
            }
        }];
        [task resume];
    }
}

/*
 * Helper function to make sure indexPath is still valid in asynchronous image loading
 */
- (BOOL)indexPathIsValid:(NSIndexPath *)indexPath {
    if(indexPath.section >= self.collectionView.numberOfSections) {
        return false;
    }
    
    if(indexPath.row >= [self.collectionView numberOfItemsInSection:indexPath.section]) {
        return false;
    }
    return true;
}

/*
 * Formats title and description if applicable depending on what section we are on.
 */
- (void)formatTitleAndDescriptionWithCell:(RSSCollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    //Set title text
    [cell.titleLabel setText:cell.rssNode.title];
    
    //Format title and description depending on if it is the first element in the collectinview
    [cell.titleLabel sizeToFit];
    if(indexPath.section == 0) {
        [cell.titleLabel setFrame:CGRectMake(10, cell.imageView.frame.size.height + 10, cell.frame.size.width - 20, 40)];
        cell.titleLabel.textAlignment = NSTextAlignmentLeft;
        cell.titleLabel.adjustsFontSizeToFitWidth = NO;
        
        cell.descLabel.hidden = NO;
        cell.descLabel.attributedText = [self createDescriptionWithCell:cell];
        [cell.descLabel sizeToFit];
        [cell.descLabel setFrame:CGRectMake(10,
                                            cell.titleLabel.frame.size.height + cell.titleLabel.frame.origin.y + 5,
                                            cell.frame.size.width - 20,
                                            cell.descLabel.frame.size.height)];
    } else {
        [cell.titleLabel setFrame:CGRectMake(5,
                                             cell.imageView.frame.size.height + 5,
                                             cell.frame.size.width - 10,
                                             cell.frame.size.height - cell.imageView.frame.size.height - 10)];
        cell.titleLabel.adjustsFontSizeToFitWidth = YES;
        cell.titleLabel.textAlignment = NSTextAlignmentCenter;
        cell.descLabel.hidden = YES;
    }
    
}

/*
 * Creates description to display underneath title. Finds the date from pubDate on node using
 * regex to find 4 numbers in a row (a year ex: 2017). The description of the article is
 * appended to the date and then it is used to create attributed text to correctly
 * encode any html.
 */
- (NSMutableAttributedString *)createDescriptionWithCell:(RSSCollectionViewCell *)cell {
    //Get date
    NSString *dateString = cell.rssNode.date;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d\\d\\d\\d" options:0 error:nil];
    NSRange needleRange = [regex rangeOfFirstMatchInString:dateString options:0 range:NSMakeRange(0, dateString.length)];
    if(needleRange.location != NSNotFound) {
        dateString = [dateString substringWithRange:NSMakeRange(0, needleRange.location + 4)];
    }
    
    //Append date and description
    dateString = [NSString stringWithFormat:@"%@ — %@", dateString, cell.rssNode.desc];
    
    //Handle HTML encoding
    cell.descLabel.attributedText = [[NSAttributedString alloc] initWithData:[dateString dataUsingEncoding:NSUnicodeStringEncoding]
                                                                     options:@{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
                                                          documentAttributes:nil error:nil];
    
    NSMutableAttributedString *result = [cell.descLabel.attributedText mutableCopy];
    [result beginEditing];
    
    //Change font
    [result addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0f] range:NSMakeRange(0, result.length)];
    
    //Add some line spacing and truncation
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:1.5];
    [paragrahStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [result addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, result.length)];
    [result endEditing];
    
    return result;
}

#pragma mark - Rotation

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
    self.activityIndicator.center = self.view.center;
    [self.collectionView reloadData];
}
@end
