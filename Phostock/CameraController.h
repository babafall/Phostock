//
//  CameraControllerViewController.h
//  Phostock
//
//  Created by Roman Truba on 28.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "BaseController.h"
#import "StandardFilters.h"
#import "FilterImagesHolder.h"

static NSString * kPhotoMadeEvent   = @"kPhotoMadeEvent";
static NSString * kCameraImageKey   = @"kCameraImage";
static NSString * kCameraFilterKey  = @"kCameraFilter";
static NSString * kBlurFilterKey    = @"kBlurFilter";
static NSString * kBlurPointKey     = @"kBlurPoint";
static NSString * kBlurSizeKey      = @"kBlurSizeKey";

@interface CameraController : BaseController <EasyTableViewDelegate, UIGestureRecognizerDelegate>
{
    GPUImageStillCamera *stillCamera;
    GPUImageGaussianSelectiveBlurFilter *blurFilter;
    GPUImageOutput<GPUImageInput> * filter;
    
    IBOutlet GPUImageView * cameraView;
    IBOutlet UIButton * flashButton;
    IBOutlet UIButton * rotateCameraButton;
    IBOutlet UIButton * photoCaptureButton;
    IBOutlet UIButton * blurButton;
    IBOutlet UIButton * filterButton;
    IBOutlet UIView * focusView;
    IBOutlet UIView * filtersTableHolder;
    IBOutlet UIView * irisAnimator;
    
    EasyTableView * filtersView;
    
    CATransition * currentAnimation;
    UIView * focusSquareView;
    GPUImageBrightnessFilter * brightFilter;
    FilterImagesHolder * thumbsHolder;
    BOOL kCancelFocus, viewJustLoaded, viewLoaded, viewOnScreen, killCamera, blurTurnedOn, frontCameraSelected;
    
    NSString * phoneModel;
    
    int filterNum, flashMode, shutterAnimated;
    float blurPointSize;
}

@property (nonatomic, assign) BOOL makeUserPic;
@property (nonatomic, strong) NSString * photoIdToResponse;

+ (CameraController*) instance;

@end
