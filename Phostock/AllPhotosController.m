//
//  AllPhotosController.m
//  Phostock
//
//  Created by Roman Truba on 28.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "AllPhotosController.h"
#import "SVPullToRefresh.h"
#import "SingleViewer.h"
@implementation AllPhotosController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.tableMainHeader.titleText = @"Explore";
    if (!lastSearchQuery)
        [self searchByText:@""];
    
    __unsafe_unretained AllPhotosController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        weakSelf->pullToRefresh = YES;
        weakSelf->clearBeforeAdd = YES;
        weakSelf->searchPage = 1;
        [weakSelf searchByText:weakSelf->lastSearchQuery];
        
    }];
    self.tableView.pullToRefreshView.arrowColor = [UIColor whiteColor];
    self.tableView.pullToRefreshView.textColor  = [UIColor whiteColor];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    lastOffset = scrollView.contentOffset.y;
}
-(void)fastLabel:(UIFastLabel *)label didSelectLink:(FastAttributedStringCustomLink *)link
{
    [self.searchBar.textInput becomeFirstResponder];
    [self searchByText:link.stringUrl];
    [self.searchBar.textInput resignFirstResponder];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}


- (UITableViewCell *) getEmptyCell
{
    UITableViewCell * cell = [PhotoCells getEmptyCell];
    [(UILabel*)[cell viewWithTag:2] setText:@"Well, it happens. Try another query or reload"];
    return cell;
}


@end
