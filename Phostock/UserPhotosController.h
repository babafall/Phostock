//
//  MyPhotosController.h
//  Phostock
//
//  Created by Roman Truba on 28.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkMainViewController.h"
#import "RecentPhotosView.h"
#import "AvatarButton.h"
#import "HeaderMovePannel.h"
@interface UserPhotosController : NetworkMainViewController<UsersHeaderDelegate>
{
    UIImage * imageToUpload;
    NSString * captionToUpload;
    
    BOOL shouldLoadFeed, isMyPage, followersMode;
    
    ApiGetFollowers * followersLoader;
    
    NSMutableArray * allFollowersArray;
    int nextFollowingSection, followingPage;
    BOOL currentSectionLoaded, isLoadingFollowers, finishFollowers;
}
@property (nonatomic, strong) IBOutlet HeaderMovePannel * headerPanel;;
@property (nonatomic, strong) UsersHeader       * userHeader;

@property (nonatomic, strong) NSString * selectedUser;

@end
