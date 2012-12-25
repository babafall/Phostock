//
//  NSTabbedController.h
//  Phostock
//
//  Created by Roman Truba on 28.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomTabs.h"
#import "BaseController.h"
#import "RecentPhotosView.h"
#import "TabButton.h"
#import "RollHolderView.h"

@class UserPhotosController;
@class DefaultViewController;
@class NetworkMainViewController;
@class NewsFeedController;
@class RepliesViewController;

@interface NetworkTabbedController : BaseController <UITabBarControllerDelegate, UINavigationControllerDelegate>
{
    UserPhotosController    * usersController;
    UINavigationController  * allPhotosController;
    
    NewsFeedController      * homeConroller;
    UINavigationController  * homeNavigationConroller;
    
    RepliesViewController   * repliesController;
    UINavigationController  * repliesNavigationController;
    
    UserPhotosController    * lastUserController;
    
    NSArray * viewControllers;
    
    IBOutletCollection(TabButton) NSArray * tabButtons;
    
}
@property (nonatomic, strong) IBOutlet BottomTabs   * bottomTabs;
@property (nonatomic, assign) int selectedControllerIndex;

@property (nonatomic, strong) IBOutlet UIView   * selectPhotosView;
@property (nonatomic, strong) IBOutlet UIButton * shootBtn;
@property (nonatomic, strong) IBOutlet UIButton * cancelBtn;

@property (nonatomic, strong) IBOutlet UIView   * rollPlaceholder;
@property (nonatomic, strong) IBOutlet RollHolderView * rollHolder;

@property (nonatomic, strong) IBOutlet UIView   * selectReplyView;
@property (nonatomic, strong) IBOutlet UIImageView * replyPhotoView;

@property (nonatomic, strong) RecentPhotosView * recentPhotosView;
@property (nonatomic, strong) NSDictionary * photoInfoForReply;
@property (nonatomic, unsafe_unretained) UINavigationController * cNavigationController;
@property (nonatomic, unsafe_unretained) DefaultViewController * mainController;
@property (nonatomic, assign) BOOL shouldMakeAvatarPhoto;

-(void) showPhotoPickerForReply:(NSDictionary*) photoInfo;
-(void) showPhotoPickerForAvatar:(BOOL) forAvatar;
-(IBAction) closePhotoPicker:(id)sender;
-(IBAction) buttonPressed:(id)sender;
-(IBAction) takePhotoClicked:(id)sender;
-(IBAction) cameraRollClicked:(id)sender;
-(IBAction) logoutClicked:(id)sender;
-(void) clear;

-(void) selectControllerAtIndex:(int) index;
-(void) showTabButton:(int) index animated:(BOOL) animated;
-(void) showTabButton:(TabButton *) button;
-(void) hideTabButton:(int) index animated:(BOOL) animated;
-(void) hideTabButton:(TabButton *) button;

-(void) statusBarFrameUpdated:(NSNotification*) notification;
-(NetworkMainViewController*) showSearchController;
@end
