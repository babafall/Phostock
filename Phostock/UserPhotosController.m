//
//  MyPhotosController.m
//  Phostock
//
//  Created by Roman Truba on 28.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "UserPhotosController.h"
#import "CaptionTagsParser.h"
#import "SVPullToRefresh.h"
#define FOLLOWERS_PER_PAGE 50
@implementation UserPhotosController
@synthesize selectedUser;

-(void)viewDidLoad
{
    [super viewDidLoad];

    shouldLoadFeed = NO;
    if (!self.selectedUser)
    {
        isMyPage = YES;
        self.selectedUser = [[NSUserDefaults standardUserDefaults] objectForKey:kUsernameKey];
        
    }
    else
    {
        isMyPage = NO;
        needReturn = YES;
        [self.headerPanel.actionButton setTitle:@"Block user" forState:UIControlStateNormal];
    }
    self.userHeader = [UsersHeader createUserHeader:self.selectedUser];
    self.userHeader.photoView.photosTable.delegate = self;
    __unsafe_unretained UserPhotosController * weakSelf = self;
    [self.userHeader.mainHeader setGridCallback:^(BOOL result) {
        weakSelf->useGridView = result;
        [weakSelf.tableView reloadData];
    }];
    self.userHeader.delegate = self;
    if (!isMyPage)
    {
        self.userHeader.photoView.labelText.text = @"user don't have a photo yet";
        [self.userHeader.mainHeader showBackButton:^{
            [self.tabbedController selectControllerAtIndex:self.tabbedController.selectedControllerIndex];
        }];
    }
    [self.tableView setTableHeaderView:self.userHeader];
    
    if (imageToUpload)
    {
        shouldLoadFeed = YES;
    }
    else {
        if (![self.selectedUser isEqualToString:@"me"])
        {
            [self loadFeedForUser:self.selectedUser];
        }
        else
        {
            self.selectedUser = @"me";
            [self loadFeedForUser];
        }
    }
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        weakSelf->pullToRefresh = YES;
        weakSelf->clearBeforeAdd = YES;
        [weakSelf loadFeedForUser:weakSelf.selectedUser];
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoUploaded) name:PhotoUploadedEvent object:nil];
    
    nextFollowingSection = 0;
    followingPage = 0;
    currentSectionLoaded = NO;
    finishFollowers = NO;
    followersLoader = nil;
    [self loadFollowers:0];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect bottomTabsFrame = self.bottomTabs.frame,
    tableFrame = self.tableView.frame;
    CGFloat screenSize = [BaseController hasFourInchDisplay] ? 548 : 460;
    bottomTabsFrame.origin.y = screenSize - bottomTabsFrame.size.height;
    
    tableFrame.size.height = bottomTabsFrame.origin.y - tableFrame.origin.y;
    
    self.tableView.frame = tableFrame;
    self.bottomTabs.frame = bottomTabsFrame;

}
-(void)photoViewer:(PhotoViewer *)viewer didSelectPhotoView:(int)index photoInfo:(NSDictionary *)photoInfo
{
    if (viewer != self.userHeader.photoView.photosTable)
    {
        if (isMyPage)
        {
            if (photosArray.count < index) return;
            NSDictionary * photoDescr = [photosArray objectAtIndex:index];
            selectedPhotoDescr = photoDescr;
            [self presentActionSheetWithAction:@"Delete" forPhotoInfo:photoInfo];
        }
        else
        {
            [super photoViewer:viewer didSelectPhotoView:index photoInfo:photoInfo];
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (isMyPage)
    {
        //Удаление фотки
        if (buttonIndex == 0)
        {
            isLoading = YES;
            [(NSMutableDictionary*)selectedPhotoDescr setObject:[NSNumber numberWithBool:YES] forKey:kWillBeRemoved];
            [self.tableView reloadData];
            [[NetWorker sharedInstance] deletePhoto:[selectedPhotoDescr objectForKey:kPhotoId] complete:^(BOOL success) {
                [photosArray removeObject:selectedPhotoDescr];
                totalPhotos--;
                isLoading = NO;
                [self.tableView reloadData];
                
                [self loadFeedForUser];
            }];
        }
        else
        {
            [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        }
    }
    else
    {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }
}

-(void) loadFeedForUser
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    if ([def objectForKey:kUserPhoto]) {
//        [self.topAvatarButton setAvatarImageUrl:[def objectForKey:kUserPhoto]];
    }
    
    [super loadFeedForUser];
}

-(void)fastLabel:(UIFastLabel *)label didSelectLink:(FastAttributedStringCustomLink *)link
{
    NetworkMainViewController * searchController = [self.tabbedController showSearchController];
    
    if (searchController.view)
    {
        [searchController.searchBar.textInput becomeFirstResponder];
        [searchController searchByText:link.stringUrl];
        [searchController.searchBar.textInput resignFirstResponder];
    }
    else
    {
        [searchController searchByText:link.stringUrl];
    }
}
-(BOOL) shouldHighlightHeader
{
    return NO;
}
-(void)usersHeaderResized
{
    self.tableView.tableHeaderView = self.userHeader;
}
-(void)userButtonClicked
{
    self.headerPanel.frame = RectSetY(self.view.frame, RectHeight(self.userHeader.mainHeader.frame));
    [self.view addSubview:self.headerPanel];
    self.tableView.scrollEnabled = ![self.headerPanel toggle];
    self.userHeader.mainHeader.titleButton.selected = !self.tableView.scrollEnabled;
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
}
-(void)setUserPhoto
{
    [self.tabbedController showPhotoPickerForAvatar:YES];
}

-(IBAction) headerCancelClicked:(id)sender
{
    [self userButtonClicked];
}

-(IBAction) headerActionClicked:(id)sender
{
    [self.headerPanel hide];
    if (isMyPage)
    {
        [self.tabbedController logoutClicked:sender];
    }
    else
    {
        ApiBlockUser * block = [[ApiBlockUser alloc] init];
        block.userId = self.selectedUser;
        [block start];
        [self.tabbedController selectControllerAtIndex:self.tabbedController.selectedControllerIndex];
        
    }
}
-(void) photoUploaded
{
    [self.userHeader loadUserInfo];
    
    clearBeforeAdd = YES;
    [self loadFeedForUser];
}
-(void)photoViewer:(PhotoViewer *)viewer didScrollToPhotoInfo:(NSDictionary *)photoInfo
{
    if (viewer == self.userHeader.photoView.photosTable)
    {
        ApiUpdateUserpic * update = [[ApiUpdateUserpic alloc] init];
        update.photoId = [photoInfo objectForKey:kPhotoId];
        [update start];
    }
}

-(void)clear
{
    [super clear];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)dealloc
{

}

-(void) loadFollowers:(int) offset
{
    if (isLoadingFollowers) return;
    if (nextFollowingSection >= 3)
    {
        finishFollowers = YES;
        return;
    }
    isLoadingFollowers = YES;
    if (!followersLoader)
    {
        followersLoader = [[ApiGetFollowers alloc] init];
    }
    
    followersLoader.userId = self.selectedUser;
    switch (nextFollowingSection) {
        case 0:
            followersLoader.filter = @"following";
            break;
        case 1:
            followersLoader.filter = @"followed_back";
            break;
        case 2:
            followersLoader.filter = @"follower";
            break;
        default:
            break;
    }
    
    followersLoader.offset = offset;
    [followersLoader startForUsers:^(NSArray *usersArray) {
        isLoadingFollowers = NO;
        if (!allFollowersArray) allFollowersArray = [NSMutableArray arrayWithCapacity:3];
        int currentSectionCount = -1;
        if (usersArray)
        {
            if (nextFollowingSection == allFollowersArray.count) allFollowersArray[nextFollowingSection] = [NSMutableArray new];
            [allFollowersArray[nextFollowingSection] addObjectsFromArray:usersArray];
            
            switch (nextFollowingSection) {
                case 0:
                    if (usersArray.count == followersLoader->following_count)
                    {
                        currentSectionLoaded = YES;
                        currentSectionCount = followersLoader->following_count;
                    }
                    break;
                case 1:
                    if (usersArray.count == followersLoader->followers_back_count)
                    {
                        currentSectionLoaded = YES;
                        currentSectionCount = followersLoader->followers_back_count;
                    }
                    break;
                case 2:
                    if (usersArray.count == followersLoader->followers_count)
                    {
                        currentSectionLoaded = YES;
                        currentSectionCount = followersLoader->followers_back_count;
                    }
                    break;
                default:
                    break;
            }
        }
        else
        {
            currentSectionLoaded = YES;
        }
        if (currentSectionLoaded)
        {
            nextFollowingSection++;
            followingPage = 0;
        }
     
        if (followersMode)
            [self.tableView reloadData];
        if (currentSectionCount == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startSectionLoad];
            });
        }
    }];
}
-(void) startSectionLoad
{
    [self loadFollowers:followingPage * FOLLOWERS_PER_PAGE];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!followersMode) return [super numberOfSectionsInTableView:tableView];
    return allFollowersArray.count;
    //Followed back + followers
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!followersMode) return [super tableView:tableView numberOfRowsInSection:section];
    int rows = ceil(1.0f * [allFollowersArray[section] count] / 3);
    if (isLoadingFollowers) rows += 1;
    return rows;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!followersMode) return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if (isLoadingFollowers && (indexPath.row * 3) > [allFollowersArray[indexPath.section] count]) return 45;
    return 105;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!followersMode) return [super tableView:tableView heightForHeaderInSection:section];
    if (isLoadingFollowers && !allFollowersArray.count) return 0;
    return 26;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!followersMode) return [super tableView:tableView viewForHeaderInSection:section];
    if (isLoadingFollowers && !allFollowersArray.count) return nil;
    FollowersHeader * view = [PhotoCells getFollowersHeader];
    switch (section) {
        case 0:
            [view setCount:followersLoader->following_count ofText:[@"following by " stringByAppendingString:self.selectedUser]];
            break;
        case 1:
            [view setCount:followersLoader->followers_back_count ofText:[@"followed back by " stringByAppendingString:self.selectedUser]];
            break;
        case 2:
            [view setCount:followersLoader->followers_count ofText:@"followers"];
            break;
        default:
            break;
    }
    return view;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!followersMode) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (isLoadingFollowers && (indexPath.row * 3) > [allFollowersArray[indexPath.section] count]) return [PhotoCells getLoadingCell];
    GridPhotoCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"GridPhotoCell"];
    if (!cell)
    {
        cell = [GridPhotoCell getNew];
    }
    
    int row = indexPath.row, photoIndex = row * 3;
    cell.startPhotoIndex = photoIndex;
    cell.delegate = self;

    int curPhotoCount = [allFollowersArray[indexPath.section] count];
    NSLog(@"%d", curPhotoCount);
    if (photoIndex > (curPhotoCount - 10) && !finishFollowers)
    {
        if (!currentSectionLoaded)
        {
            followingPage++;
            [self loadFollowers:followingPage * FOLLOWERS_PER_PAGE];
        }
        else
        {
            [self loadFollowers:followingPage * FOLLOWERS_PER_PAGE];
        }
    }
    NSArray * imagesView = cell.photoViews;
    for (int i = 0; i < 3; i++)
    {
        SmallPhotoView * curImageView = imagesView[i];
        if (photoIndex + i < [allFollowersArray[indexPath.section] count])
        {
            NSDictionary * currentUser = allFollowersArray[indexPath.section][photoIndex + i];
            [curImageView setUser:currentUser];
        }
        else
        {
            [curImageView setUser:nil];
        }
    }
    
    return cell;
}
-(void)showFollowers
{
    NSLog(@"Show followers mode");
    followersMode = YES;
    [self.userHeader setEncounterPhotos];
    [self.tableView reloadData];
}
-(void)showPhotos
{
    followersMode = NO;
    [self.userHeader setEncounterFollowers];
    [self.tableView reloadData];
}
-(void)showMentions
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSearchUserMentionNotification object:self.selectedUser];
}

@end

