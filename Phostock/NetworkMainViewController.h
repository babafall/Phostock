//
//  NetworkMainViewController.h
//  Phostock
//
//  Created by Roman Truba on 26.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "BaseController.h"
#import "CustomGraySearchBar.h"
#import "NetWorker.h"
#import "PhotoCells.h"
#import "BottomTabs.h"
#import "NetworkTabbedController.h"
#import "UIFastLabel.h"
#import "AvatarButton.h"
#import "MainHeader.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "PhotoActionSheet.h"
@interface NetworkMainViewController : BaseController <UITableViewDataSource, UITableViewDelegate, CustomSearchBarDelegate, PhotoHeaderDelegate, UIFastLabelDelegate, UIActionSheetDelegate, PhotoViewerDelegate>
{
    NSDictionary * selectedPhotoDescr;
    NSMutableArray * photosArray;
    NSMutableDictionary * existingPhotos, * historyForId;
    int totalPhotos;
    
    NSString * lastSearchQuery;
    BOOL isSearching, isLoading, needReturn, startedSearch, needToReload, bottomHidden, canProcessScroll, ignoreTextUpdate, clearBeforeAdd, pullToRefresh;
    BOOL loadingPhotoNow, replaceFirst, isVisible, useGridView;
    int searchPage, workPage, lastSearchPage;
    
    ApiMethod * currentWorkingMethod;
}

@property (nonatomic, strong) IBOutlet UIView * tableHeader;
@property (nonatomic, strong) IBOutlet MainHeader * tableMainHeader;
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet CustomGraySearchBar * searchBar;
@property (nonatomic, strong) TabButton * tabButton;

@property (nonatomic, unsafe_unretained) NetworkTabbedController * tabbedController;

@property (nonatomic, strong) BottomTabs   * bottomTabs;
@property (nonatomic, assign) int selectedType;
@property (nonatomic, strong) NSString * selectedUser;
@property (nonatomic, strong) NSMutableArray * photosArray;

-(void) loadFeedForUser;
-(void) loadFeedForUser:(NSString*) userName;
-(void) searchByText:(NSString*) text;
-(void) beginSearch;
-(void) resetSearch;
-(void) clear;
-(void) reload;
-(void) processPhotosFromResponse:(PhotoResponse*) response users:(NSDictionary*)users;
-(void) presentActionSheetWithAction:(NSString*) title forPhotoInfo:(NSDictionary*) photoInfo;
@end
