//
//  DefaultViewController.h
//  Phostock
//
//  Created by Roman Truba on 26.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "CameraController.h"
#import "PhotoEditController.h"
#import "UIDeviceHardware.h"
#import "PhotoEditController.h"
#import "BaseController.h"
#import "EasyTableView.h"
#import "RecentPhotosView.h"
#import "NetworkTabbedController.h"
#import "ImageDrawerView.h"
#import "AvatarButton.h"
#import "RollHolderView.h"

@interface DefaultViewController : BaseController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, RecentPhotosViewDelegate, UITextFieldDelegate>
{
    CameraController * cameraController;
    PhotoEditController * photoEditController;
    NSDate * lastAssetNotification;
    @public
    BOOL becomeActive, loggedIn;
    
    UIImage * firstPostImage;
    NSString * firstPostCaption;
}
@property (nonatomic, strong) IBOutlet RollHolderView * rollHolder;
@property (nonatomic, strong) IBOutlet RecentPhotosView * recentPhotosView;
@property (nonatomic, strong) IBOutlet UILabel  * appTitle;
@property (nonatomic, strong) IBOutlet UIButton * takePhotoButton;
@property (nonatomic, strong) IBOutlet UIButton * cameraRollButton;
@property (nonatomic, strong) IBOutlet UIView * mainView;
@property (nonatomic, strong) IBOutlet ImageDrawerView * photoDrawer;

//Second view

@property (nonatomic, strong) IBOutlet AvatarButton * postButton;
@property (nonatomic, strong) IBOutlet UIButton * loginButton;
@property (nonatomic, strong) IBOutlet UITextField * loginInput;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * loadActivity;
@property (nonatomic, strong) IBOutlet UILabel  * errorLabel;

//Third view

@property (nonatomic, strong) NetworkTabbedController * networkController;

-(IBAction) cameraRollClicked:(id)sender;
-(IBAction) cameraTake:(id)sender;
-(void) savePhoto:(NSDictionary*) photoInfo toCameraRoll:(void(^)(BOOL okay, UIImage * resultImage)) onComplete;
-(void) prepareLogoff;
-(void) madeLogoff;

-(IBAction)loginButtonClicked;
-(IBAction)postButtonClicked;
@end
