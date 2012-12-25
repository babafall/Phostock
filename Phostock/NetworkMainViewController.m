//
//  NetworkMainViewController.m
//  Phostock
//
//  Created by Roman Truba on 26.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "NetworkMainViewController.h"
#import "PhotoCells.h"
#import "UIImageView+AFNetworking.h"
#import "NetWorker.h"
#import "UITableView+ReusableHeaders.h"
#import "AllPhotosController.h"
#import "UserPhotosController.h"
#import "SVPullToRefresh.h"
#import "DefaultViewController.h"
#import "SingleViewer.h"

@implementation NetworkMainViewController
@synthesize selectedUser, photosArray;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        isVisible = NO;
        bottomHidden = clearBeforeAdd = replaceFirst = ignoreTextUpdate = NO;
        
    }
    return self;
}
-(void)viewDidLoad
{
    self.tableMainHeader = [MainHeader getNewHeader];
    if (self.tableHeader) [self.tableHeader addSubview:self.tableMainHeader];
    else
    {
        [self.tableView setTableHeaderView:self.tableMainHeader];
    }
    self.tableMainHeader.backButton.hidden = YES;
    __unsafe_unretained NetworkMainViewController * weakSelf = self;
    [self.tableMainHeader setGridCallback:^(BOOL result) {
        weakSelf->useGridView = result;
        [weakSelf.tableView reloadData];
    }];
    
    [super viewDidLoad];
    canProcessScroll = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = YES;
    self.searchBar.delegate = self;
    self.tableHeader.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    searchPage = workPage = lastSearchPage = 1;
    [self.searchBar setText:lastSearchQuery];
        
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.tableView.scrollsToTop = NO;
    isVisible = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (isVisible) return;
    self.tableView.scrollsToTop = YES;
    isVisible = YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    CGRect bottomTabsFrame = self.bottomTabs.frame,
    tableFrame = self.tableView.frame;
    CGFloat screenSize = [BaseController hasFourInchDisplay] ? 548 : 460;
    if (bottomHidden)
    {
        bottomTabsFrame.origin.y = screenSize;
    }
    else
    {
        bottomTabsFrame.origin.y = screenSize - bottomTabsFrame.size.height;
    }
    tableFrame.size.height = bottomTabsFrame.origin.y - tableFrame.origin.y;

    self.tableView.frame = tableFrame;
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomTabs.frame = bottomTabsFrame;
    }];
    

    [self.tabbedController statusBarFrameUpdated:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (useGridView)
        return 5;
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (useGridView)
    {
        UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)];
        v.backgroundColor = [UIColor whiteColor];
        return v;
    }
    return nil;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoading)
    {
        if (!useGridView)
        {
            return photosArray.count + 1;
        }
        else
        {
            return ceil((float)photosArray.count / 3) + 1;
        }
    }
    if (totalPhotos == 0) return 1;
    if (totalPhotos != -1) {
        if (isSearching && searchPage * PHOTOS_PER_PAGE < totalPhotos)
        {
            if (!useGridView)
            {
                return photosArray.count + 1;
            }
            else
            {
                return ceil((float)photosArray.count / 3) + 1;
            }
        }
        if (!isSearching && workPage * PHOTOS_PER_PAGE < totalPhotos)
        {
            if (!useGridView)
            {
                return photosArray.count + 1;
            }
            else
            {
                return ceil((float)photosArray.count / 3) + 1;
            }
        }
    }
    else
    {
        if (photosArray.count == 0) return 1;
    }
    if (!useGridView)
    {
        return photosArray.count;
    }
    else
    {
        return ceil((float)photosArray.count / 3);
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (totalPhotos == 0 || indexPath.row == photosArray.count ) return 45.0f;
    if (isLoading && indexPath.row == ceil((float)photosArray.count / 3)) return 45.0f;
    NSDictionary * photoDescr = [photosArray objectAtIndex:indexPath.row];
    if ([[photoDescr objectForKey:kPhoto] isEqual:@""])
    {
//        NSLog(@"Height return 0, row: %d", indexPath.row);
        return 0;
    }
    if (!useGridView)
    {
        return 365.0f;
    }
    else
    {
        return 105.0f;
    }
}
- (UITableViewCell *) getEmptyCell
{
    return [PhotoCells getEmptyCell];
}
-(BOOL) shouldHighlightHeader
{
    return YES;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (totalPhotos == -1 && !isLoading && photosArray.count == 0)
    {
        return [self getEmptyCell];
    }
    if (totalPhotos == 0 && !isLoading)
    {
        return [self getEmptyCell];
    }
//    NSLog(@"Cell at index: %d", indexPath.row);
    
    UITableViewCell * cell = nil;
    if (!useGridView)
    {
        cell = [self fillStandardCell:indexPath.row];
    }
    else
    {
        cell = [self fillGridCell: indexPath.row];
    }
    
    return cell;
}
-(void) performNextLoadCheck
{
    //Проверка, что можно грузить дальше
    if (!isLoading && isSearching && searchPage * PHOTOS_PER_PAGE < totalPhotos)
    {
        searchPage++;
        [self searchByText:lastSearchQuery];
    }
    else if (!isSearching && !isLoading && workPage * PHOTOS_PER_PAGE < totalPhotos)
    {
        workPage++;
        [self loadFeedForUser:selectedUser];
    }
    
}
-(UITableViewCell *) fillGridCell:(int) row
{
    if (isLoading && row == ceil((float)photosArray.count / 3))
    {
        return [PhotoCells getLoadingCell];
    }
    
    GridPhotoCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"GridPhotoCell"];
    if (!cell)
    {
        cell = [GridPhotoCell getNew];
    }
    int photoIndex = row * 3;
    cell.startPhotoIndex = photoIndex;
    cell.delegate = self;
    int totalCount = photosArray.count;
    if ((totalCount - 10) < photoIndex)
    {
        [self performNextLoadCheck];
    }
    NSArray * imagesView = cell.photoViews;
    for (int i = 0; i < 3; i++)
    {
        SmallPhotoView * curImageView = imagesView[i];
        if (photoIndex + i < photosArray.count)
        {
            [curImageView setPhoto:photosArray[photoIndex + i] delegate:self];
        }
        else
        {
            [curImageView setPhoto:nil delegate:self];
        }
    }
    
    return cell;
}
-(UITableViewCell *) fillStandardCell:(int) row
{
    if (isLoading && row == photosArray.count)
    {
        return [PhotoCells getLoadingCell];
    }
    int totalCount = photosArray.count;
    if ((totalCount - 10) < row)
    {
        [self performNextLoadCheck];
    }
    MainPhotoCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
    if (!cell)
    {
        cell = [PhotoCells getMainPhotoCell];
    }
    
    NSMutableDictionary * photoInfo = (NSMutableDictionary*)[photosArray objectAtIndex:row];
    NSDictionary * userInfo = [[photosArray objectAtIndex:row] objectForKey:kUserInfo];
    
    PhotoHeader * header = cell.photoHeader;
    header.delegate = self;
    header.timestampLabel.text = [photoInfo objectForKey:kDateStr];
    header.userAvatarView.dontUseProgressBar = YES;
    
    header.usernameLabel.text = [userInfo objectForKey:@"login"];
    [ header.usernameLabel sizeToFit ];
    if ([header.usernameLabel.text isEqual:lastSearchQuery])
    {
        header.usernameLabel.backgroundColor = [UIColor colorWithRed:222.0/255 green:218.0/255 blue:214.0/255 alpha:1];
    }
    else
    {
        header.usernameLabel.backgroundColor = [UIColor clearColor];
    }
    NSDictionary * userPhotos = [userInfo objectForKey:@"photo"];
    if (userPhotos) {
        NSString * smallPhoto = [userPhotos objectForKey:@"photo_small"];
        if (smallPhoto && ![smallPhoto isEqualToString:@""]) {
            header.userAvatarView.highlightedImage = nil;
            [header.userAvatarView setImageWithURL:[NSURL URLWithString: smallPhoto] maskImage:[UIImage imageNamed:@"FeedAvatarMask"]];
        }
    }
    else {
        header.userAvatarView.image = [UIImage imageNamed:@"Avatar"];
        header.userAvatarView.highlightedImage = [UIImage imageNamed:@"Avatar_Pressed"];
    }
    if (![self shouldHighlightHeader])
    {
        [header.headerButton setBackgroundImage:[UIImage imageNamed:@"PhotoHeader.png"] forState:UIControlStateHighlighted];
        header.userAvatarView.highlightedImage = nil;
    }
    else
    {
        [header.headerButton setBackgroundImage:[UIImage imageNamed:@"PhotoHeader_Pressed.png"] forState:UIControlStateHighlighted];
    }
    cell.photoViewer.imagesArray = nil;
    cell.photoViewer.historyCompleted = NO;
    
    header.replyAvatarView.hidden = YES;
    header.replyAvatarView.image = [UIImage imageNamed:@"Avatar"];
    header.replyAvatarView.highlightedImage = [UIImage imageNamed:@"Avatar_Pressed"];
    
    NSMutableArray * photos = [NSMutableArray array];
    if (photoInfo)
        [photos addObject:photoInfo];
    NSDictionary * reply = [photoInfo objectForKey:kReplyPhoto];
    if (reply && [reply count])
    {
        [photos addObject:reply];
        header.replyAvatarView.hidden = NO;
//        NSLog(@"reply: %@", reply);
        NSDictionary * photo = [[reply objectForKey:kUserInfo] objectForKey:@"photo"];
        if (photo)
        {
            NSString * smallPhoto = [photo objectForKey:@"photo_small"];
            if (smallPhoto && ![smallPhoto isEqualToString:@""]) {
                header.replyAvatarView.highlightedImage = nil;
                [header.replyAvatarView setImageWithURL:[NSURL URLWithString: smallPhoto] maskImage:[UIImage imageNamed:@"FeedAvatarMask"]];
            }
        }
    }
    
    cell.photoViewer.imagesArray = photos;
    cell.photoViewer.delegate = self;
    cell.photoViewer.tableView.scrollsToTop = NO;
    cell.photoViewer.photoIndex = row;
    return cell;
}

-(void) loadFeedForUser
{
    clearBeforeAdd = YES;
    [self loadFeedForUser:@"me"];
}
-(void) loadFeedForUser:(NSString*) userName
{
    isSearching = NO; isLoading = YES;

    selectedUser = userName;

    ApiGetPhotos * getPhotos = [[ApiGetPhotos alloc] initWithUserId:selectedUser];
    getPhotos.offset = (workPage-1) * PHOTOS_PER_PAGE;
    getPhotos.limit  = PHOTOS_PER_PAGE;
    [getPhotos start:^(NSDictionary *users, PhotoResponse *photoResponse) {
        [self processPhotosFromResponse:photoResponse users:users];
    } onError:^(NSError * error) {
#warning Process error
    }];
    
}
-(void) resetSearch
{
    searchPage = 1;
    photosArray = nil;
    existingPhotos = nil;
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self searchByText:@""];
}

-(void) searchByText:(NSString*) text
{
    if (text.length == 1) return;
    isSearching = isLoading = YES;
    if (![lastSearchQuery isEqualToString:text] || lastSearchPage == searchPage)
    {
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        ignoreTextUpdate = YES;
        [self.searchBar setText:text];
        ignoreTextUpdate = NO;
        photosArray = nil;
        searchPage = 1;
        startedSearch = YES;
//        [self reload];
    }
    lastSearchQuery = text;
    ApiSearch * search = [[ApiSearch alloc] initWithQuery:lastSearchQuery];
    search.offset = (searchPage-1) * PHOTOS_PER_PAGE;
    search.limit  = PHOTOS_PER_PAGE;
    [search start:^(NSDictionary *users, PhotoResponse *photoResponse) {
        [self processPhotosFromResponse:photoResponse users:users];
    } onError:^(NSError * error) {
#warning Process error
    }];
    
}
-(void) reload
{
    if (pullToRefresh)
        [self.tableView.pullToRefreshView stopAnimating];
    pullToRefresh = NO;
    if (!self.tableView.decelerating && !self.tableView.isDragging)
    {
        [self.tableView reloadData];
    }
    else
    {
        needToReload = YES;
    }
}

-(void)searchBar:(CustomGraySearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    NSLog(@"New search text: %@", searchText);
    if (!ignoreTextUpdate)
        [self searchByText:searchText];
}
-(void)searchBarCancelButtonClicked:(CustomGraySearchBar *)searchBar
{
//    NSLog(@"Cancel search");
    
    [searchBar.textInput resignFirstResponder];
    if (!startedSearch) return;
    startedSearch = NO;
    self.tableView.contentOffset = CGPointMake(0, 0);
    canProcessScroll = NO;
    CGRect 
    searchBarFrame  = self.searchBar.frame,
    bottomTabsFrame = self.bottomTabs.frame,
    tableViewFrame  = self.tableView.frame;
    
    CGFloat screenSize = [BaseController hasFourInchDisplay] ? 548 : 460;
    
    searchBarFrame = CGRectMake(0, 0, 320, 90);
    bottomTabsFrame.origin.y = screenSize - bottomTabsFrame.size.height;
    
    tableViewFrame.origin.y = 0;
    tableViewFrame.size.height = bottomTabsFrame.origin.y;

    [UIView animateWithDuration:0.3 animations:^{
//        self.tableHeader.frame      = searchBarFrame;
        self.bottomTabs.frame       = bottomTabsFrame;
        self.tableView.frame        = tableViewFrame;
        
    } completion:^(BOOL finished) {
        bottomHidden = NO;
        canProcessScroll = YES;
    }];
    
    if (![lastSearchQuery isEqualToString:@""])
        [self searchByText:@""];
    
}
-(void)searchBarDidBeginEditing:(CustomGraySearchBar *)searchBar textField:(UITextField *)field
{
//    NSLog(@"Begin search");
    [self beginSearch];
}
-(void) beginSearch
{
    if (startedSearch) return;
    canProcessScroll = NO;
    startedSearch = YES;
//    self.tableView.tableHeaderView = nil;
//    [self.view addSubview:self.tableHeader];
    
    CGRect 
    searchBarFrame = self.tableHeader.frame,
    bottomTabsFrame = self.bottomTabs.frame,
    tableViewFrame  = self.tableView.frame;
    
    CGFloat screenSize = [BaseController hasFourInchDisplay] ? 548 : 460;
    
    searchBarFrame = CGRectMake(0, -45, 320, 90);
    bottomTabsFrame.origin.y = screenSize;
    tableViewFrame.origin.y = 0;
    tableViewFrame.size.height = screenSize;

    [UIView animateWithDuration:0.3 animations:^{
//        self.tableHeader.frame      = searchBarFrame;
        self.bottomTabs.frame       = bottomTabsFrame;
        self.tableView.frame        = tableViewFrame;
    } completion:^(BOOL finished) {
        bottomHidden = YES;
        canProcessScroll = YES;
    } ];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (needToReload)
    {
        [self.tableView reloadData];
        needToReload = NO;
    }
}


-(void)headerSelectedUser:(NSString *)nick {
    if (self.navigationController)
    {
        UserPhotosController * vc = [[UserPhotosController alloc] initWithNibName:@"UserPhotosController" bundle:nil];
        vc.selectedUser = nick;
        vc.bottomTabs = self.bottomTabs;
        vc.tabbedController = self.tabbedController;
        [self.navigationController pushViewController:vc animated:YES];
        [self.bottomTabs unselectAll];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    CGSize theSize = actionSheet.frame.size;
    CGRect frame; frame.origin = CGPointMake(0, 0); frame.size = theSize;
    UIView * view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    [actionSheet insertSubview:view atIndex:0];
}

-(void) saveCurrentSelectedToCameraRoll
{
    DefaultViewController * vc = self.tabbedController.mainController;
    [vc savePhoto:selectedPhotoDescr toCameraRoll:^(BOOL okay, UIImage *resultImage) {
        [(NSMutableDictionary*)selectedPhotoDescr setObject:[NSNumber numberWithBool:NO] forKey:kWillBeLoaded];
        [self.tableView reloadData];
    }];
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}
-(void)clear
{
    [currentWorkingMethod stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void) dealloc
{
    NSLog(@"Dealloc: %@", self);
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) processPhotosFromResponse:(PhotoResponse*)response users:(NSDictionary*)users
{
    NSMutableArray * nicks = [NSMutableArray arrayWithCapacity:users.count];
    for (NSDictionary * userId in users)
    {
        [nicks addObject:users[userId][@"login"]];
    }
    [[NetWorker sharedInstance] putUsers:nicks];
    isLoading = NO;
    totalPhotos = response.totalPhotoCount;
    if (totalPhotos == 0 && loadingPhotoNow) totalPhotos = 1;
    
    id firstObject = nil;
    if (photosArray.count > 0) firstObject = [photosArray objectAtIndex:0];
    if (!photosArray || clearBeforeAdd )
    {
        photosArray = [NSMutableArray arrayWithCapacity:totalPhotos];
        clearBeforeAdd = NO;
    }
    [photosArray addObjectsFromArray:response.photos];
    if (replaceFirst && firstObject && photosArray.count > 0)
    {
        replaceFirst = NO;
        [photosArray replaceObjectAtIndex:0 withObject:firstObject];
    }
    
    [self reload];
}

-(void)photoViewer:(PhotoViewer *)viewer loadHistoryForId:(NSString *)photoId
{
    if ([historyForId objectForKey:photoId])
    {
        [viewer addPhotosFromHistory:[historyForId objectForKey:photoId] startId:photoId];
    }
    else
    {
        ApiGetHistory * history = [[ApiGetHistory alloc] init];
        history.photoId = photoId;
        [history start:^(NSDictionary *users, PhotoResponse *photos) {
            [historyForId setObject:photos.photos forKey:photoId];
            viewer.historyCompleted = history.complete;
            [viewer addPhotosFromHistory:photos.photos startId:photoId];
        } onError:^(NSError * error) {
            NSLog(@"Error: %@", error);
        }];
    }
}
-(void)photoViewer:(PhotoViewer *)viewer didSelectSmallView:(int)index photoInfo:(NSDictionary *)photoInfo
{
    SingleViewer * vc = [[SingleViewer alloc] initWithNibName:@"SingleViewer" bundle:nil];
    vc.photoInfo = photoInfo;
    vc.caller = self;
    [self.tabbedController.cNavigationController pushViewController:vc animated:YES];
}
-(void)photoViewer:(PhotoViewer *)viewer didSelectPhotoView:(int)index photoInfo:(NSDictionary *)photoInfo
{
    if (index >= photosArray.count) return;
    NSDictionary * photoDescr = [photosArray objectAtIndex:index];
    selectedPhotoDescr = photoDescr;
    
    [self presentActionSheetWithAction:@"Reply" forPhotoInfo:photoInfo];
}

-(void) presentActionSheetWithAction:(NSString*) title forPhotoInfo:(NSDictionary*) photoInfo
{
    PhotoActionSheet * sheet = [[PhotoActionSheet alloc] initWithTitle:@"Choose action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:title otherButtonTitles:@"Save to camera roll", nil];
    sheet.photoInfo = photoInfo;
    [sheet showInView:self.bottomTabs];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    PhotoActionSheet * pas = (PhotoActionSheet*)actionSheet;
    //Реплай на фотку
    if (buttonIndex == 0)
    {
        [self.tabbedController showPhotoPickerForReply:pas.photoInfo];
    }
    else if (buttonIndex == 1)
    {
        [self saveCurrentSelectedToCameraRoll];
    }
}

@end
