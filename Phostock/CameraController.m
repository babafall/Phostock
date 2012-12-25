//
//  CameraControllerViewController.m
//  Phostock
//
//  Created by Roman Truba on 28.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "CameraController.h"
#import "PhotoEditController.h"
#import "UIDeviceHardware.h"

@implementation CameraController

+ (CameraController*) instance
{
    return [[CameraController alloc] initWithNibName:@"CameraController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIDeviceHardware * device = [[UIDeviceHardware alloc] init];
        phoneModel = [device platform];
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    CATransition *animation = [CATransition animation];
    if (!shutterAnimated)
    {
        animation.speed = 0;
        animation.duration = 0.6;

        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = @"cameraIrisHollowOpen";
        [irisAnimator.layer addAnimation:animation forKey:nil];    
    }
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!stillCamera)
        {
            CGSize forceSize = CGSizeMake(1224 / 2, 1632 / 2);
            brightFilter = [[GPUImageBrightnessFilter alloc] init];
            [brightFilter prepareForImageCapture];
            
            blurPointSize = 0.2f;
            blurFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
            [blurFilter setExcludeCircleRadius:blurPointSize];
            [blurFilter prepareForImageCapture];
            
            filter = [thumbsHolder getFilterAtIndex:filterNum];
            [filter forceProcessingAtSize:forceSize];
            
            [self recreateCamera];
        }
        else if (!viewJustLoaded)
        {
            [stillCamera startCameraCapture];
        }
        
        viewJustLoaded = NO;
        viewOnScreen = YES;
        filtersView.selectedMask = thumbsHolder.selectedFilterMask;
        [stillCamera waitForFrame];
        [filtersView reloadData];

        if (!shutterAnimated) {
            animation.speed = 1;
            [irisAnimator.layer addAnimation:animation forKey:nil];
        }
        shutterAnimated = YES;
        flashButton.enabled = rotateCameraButton.enabled = blurButton.enabled = photoCaptureButton.enabled = filterButton.enabled = YES;
    });
    
    [super viewDidAppear:animated];
    
    NSLog(@"Camera appear");
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"disappear");
    [self clearAll];
    
    viewOnScreen = NO;
}
-(void) clearAll
{
    runOnMainQueueWithoutDeadlocking(^{
        [stillCamera stopCameraCapture];
        [stillCamera removeAllTargets];
        [stillCamera removeInputsAndOutputs];
        stillCamera = nil;
        
        [brightFilter removeAllTargets];
        brightFilter = nil;
        
        [blurFilter removeAllTargets];
        blurFilter = nil;
        
        [filter removeAllTargets];
        filter = nil;
    });
}
-(void) recreateCamera
{
    stillCamera = [[GPUImageStillCamera alloc] init];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    if (stillCamera.inputCamera.isFlashAvailable )
    {
        [stillCamera.inputCamera lockForConfiguration:nil];
        [stillCamera.inputCamera setFlashMode:flashMode];
        [stillCamera.inputCamera unlockForConfiguration];
    }
    else
    {
        [flashButton setHidden:YES];
    }
    if (frontCameraSelected)
    {
        [stillCamera rotateCamera];
        [stillCamera waitForFrame];
    }
    [self turnFilterUpWithBlur];
    [stillCamera startCameraCapture];
    [photoCaptureButton setEnabled:YES];
}
-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (!viewOnScreen)
    {
        [self clearAll];
        
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [blurButton setImage:[UIImage imageNamed:@"Blur.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    flashMode = AVCaptureFlashModeAuto;
    [self createFiltersView];
//    CGFloat height = CGRectGetHeight(cameraView.frame);
//    CGFloat width = height * (3./4);
//    CGRect fr = CGRectMake((320 - width) / 2, 0, width, height);
//    cameraView.frame = fr;
    
    [filtersView selectCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
    cameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    viewJustLoaded = YES;
    
    if(![UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
    {
        [rotateCameraButton setHidden:YES];
    }
        
    // Add a single tap gesture to focus on the point tapped, then lock focus
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
    [singleTap setNumberOfTapsRequired:1];
    [focusView addGestureRecognizer:singleTap];
    
    // Add a double tap gesture to reset the focus mode to continuous auto focus
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
    [doubleTap setNumberOfTapsRequired:2];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [focusView addGestureRecognizer:doubleTap];
    
    UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(blurPinchChanged:)];
    pinch.delegate = self;
    [focusView addGestureRecognizer:pinch];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    cameraView = nil;
    flashButton = nil;
    rotateCameraButton = nil;
    photoCaptureButton = nil;
    focusView = nil;
}

-(IBAction) cancelButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction) filtersButtonClicked:(id)sender
{
    UIButton * filtersButton = (UIButton*) sender;
    if (filtersTableHolder.isHidden)
    {
        filtersTableHolder.alpha = 0;
        filtersTableHolder.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            filtersTableHolder.alpha = 1;
        }];
        [filtersButton setBackgroundImage:[UIImage imageNamed:@"CameraBtn_Pressed"] forState:UIControlStateNormal];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            filtersTableHolder.alpha = 0;
        } completion:^(BOOL finished) {
            filtersTableHolder.hidden = YES;
        }];
        [filtersButton setBackgroundImage:[UIImage imageNamed:@"CameraBtn"] forState:UIControlStateNormal];
    }
}
- (IBAction)flashButtonClicked:(UIControl*) sender;
{
    flashMode = stillCamera.inputCamera.flashMode + 1;
    if (flashMode > AVCaptureFlashModeAuto) flashMode = AVCaptureFlashModeOff;
    [stillCamera.inputCamera lockForConfiguration:nil];
    [stillCamera.inputCamera setFlashMode:flashMode];
    [stillCamera.inputCamera unlockForConfiguration];
    
    UIButton * button = (UIButton*) sender;
    if (flashMode == AVCaptureFlashModeAuto)
        [button setTitle:@"Auto" forState:UIControlStateNormal];
    if (flashMode == AVCaptureFlashModeOn)
        [button setTitle:@"On" forState:UIControlStateNormal];
    if (flashMode == AVCaptureFlashModeOff)
        [button setTitle:@"Off" forState:UIControlStateNormal];
}
- (IBAction)rotateButtonClicked
{
    frontCameraSelected = !frontCameraSelected;
    runOnMainQueueWithoutDeadlocking(^{
        [stillCamera rotateCamera];
        [stillCamera waitForFrame];
        rotateCameraButton.enabled = NO;
        int64_t delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            rotateCameraButton.enabled = YES;
        });
    });
    
}
// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:focusView];
    tapPoint = [focusView convertPoint:tapPoint toView:cameraView];

    blurFilter.blurPoint = CGPointMake(tapPoint.x / cameraView.frame.size.width, tapPoint.y / cameraView.frame.size.height);
    if (stillCamera.inputCamera.isFocusPointOfInterestSupported) {
        
        tapPoint = [gestureRecognizer locationInView:cameraView];
        CGPoint pointOfInterest = CGPointMake(tapPoint.y / cameraView.frame.size.height, 1.f - (tapPoint.x / cameraView.frame.size.width));
        
        AVCaptureDevice *device = stillCamera.inputCamera;
        [device lockForConfiguration:nil];
        [device setFocusPointOfInterest:pointOfInterest];
        [device setFocusMode:AVCaptureFocusModeAutoFocus];
        if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            
            [device setExposurePointOfInterest:pointOfInterest];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [device unlockForConfiguration];
        
        tapPoint = [gestureRecognizer locationInView:focusView];
        [self showRectOfSize:30 atPoint:tapPoint];
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if (stillCamera.inputCamera.isFocusPointOfInterestSupported)
    {
        AVCaptureDevice *device = stillCamera.inputCamera;
        [device lockForConfiguration:nil];
        [device setFocusPointOfInterest:CGPointMake(.5f, .5f)];
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            
            [device setExposurePointOfInterest:CGPointMake(.5f, .5f)];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [device unlockForConfiguration];
        
        CGPoint tapPoint = CGPointMake(CGRectGetWidth(focusView.frame) / 2, CGRectGetHeight(focusView.frame) / 2);
        [self showRectOfSize:100 atPoint:tapPoint];
    }
}
-(void) showRectOfSize:(CGFloat) rectSize atPoint:(CGPoint) center
{
    [focusSquareView removeFromSuperview];
    if (focusSquareView) kCancelFocus = YES;
    
    focusSquareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rectSize, rectSize)];
    focusSquareView.center = center;
    focusSquareView.backgroundColor = [UIColor clearColor];
    focusSquareView.layer.borderWidth = 1;
    focusSquareView.layer.borderColor = [[UIColor blueColor] CGColor];
    [focusView addSubview:focusSquareView];
    
    [UIView animateWithDuration:2 animations:^{
        focusSquareView.alpha = 2;
    } completion:^(BOOL finished) {
        if (!kCancelFocus)
        {
            [focusSquareView removeFromSuperview];
            focusSquareView = nil;
        }
        
        kCancelFocus = NO;
    }];
}
- (IBAction) blurButtonClicked:(id)sender
{
    blurTurnedOn = !blurTurnedOn;
    blurButton.selected = blurTurnedOn;
    [self turnFilterUpWithBlur];
    
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]])
    {
        if (!blurTurnedOn) return NO;
    }
    return YES;
}
-(void) blurPinchChanged:(UIPinchGestureRecognizer*) reco
{
    
    if (reco.state == UIGestureRecognizerStateChanged)
    {
        [blurFilter setExcludeCircleRadius:blurPointSize * reco.scale];
    }
    if (reco.state == UIGestureRecognizerStateEnded)
    {
        blurPointSize *= reco.scale;
    }
}
- (IBAction) captureButtonClicked
{
    
    UIView * flashView = [[UIView alloc] initWithFrame:self.view.frame];
    flashView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:flashView];
    
    [UIView animateWithDuration:0.5 animations:^{
        flashView.alpha = 0;
    } completion:^(BOOL finished) {
        [flashView removeFromSuperview];
    }];
    
    [photoCaptureButton setEnabled:NO];
    runSynchronouslyOnVideoProcessingQueue(^{
        
        [filter         removeAllTargets];
        [brightFilter   removeAllTargets];
        [stillCamera    removeAllTargets];
        [blurFilter     removeAllTargets];
        
        
        GPUImageOutput<GPUImageInput> * process = brightFilter;
        [process prepareForImageCapture];
        
        CGSize forceSize = CGSizeMake(1024, 1024.0f * 4/3);
        if (!frontCameraSelected)
            [process forceProcessingAtSize:forceSize];
        [stillCamera addTarget:process];
        [stillCamera waitForFrame];
        
        NSLog(@"Capture clicked");
        [self goCapture:process];
        
        
    });
    
}
-(void) goCapture:(GPUImageOutput<GPUImageInput> *) process
{
    runSynchronouslyOnVideoProcessingQueue(^{
        @autoreleasepool {
            [stillCamera waitForFrame];
            [stillCamera capturePhotoAsJPEGProcessedUpToFilter:process withCompletionHandler:^(UIImage *processedJPEG, NSError *error) {
                if (!processedJPEG.CGImage || processedJPEG.size.width == 0 || processedJPEG.size.height == 0)
                {
                    [self goCapture:process];
                    return;
                }
                CGPoint point = blurFilter.blurPoint;
                @autoreleasepool {
                    [self performSelector:@selector(clearAll) withObject:nil afterDelay:1];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoMadeEvent object:@{
                                                          kCameraImageKey : processedJPEG,
                                                         kCameraFilterKey : [NSNumber numberWithInt:filterNum],
                                                           kBlurFilterKey : [NSNumber numberWithBool:blurTurnedOn],
                                                            kBlurPointKey : [NSValue value:&point withObjCType:@encode(CGPoint)],
                                                             kBlurSizeKey : @(blurPointSize)}];
            }];
        }
    });
}

#pragma mark Filters

- (void) createFiltersView
{
    thumbsHolder = [FilterImagesHolder getInstance];
    CGRect recentRect = CGRectMake(0, 0, 320, 68);
    filtersView = [[EasyTableView alloc] initWithFrame:recentRect numberOfColumns:0 ofWidth:66];
    filtersView.delegate						= self;
	filtersView.tableView.backgroundColor       = [UIColor clearColor];
	filtersView.tableView.allowsSelection       = YES;
	filtersView.tableView.separatorColor		= [UIColor clearColor];
	filtersView.cellBackgroundColor             = [UIColor clearColor];
	filtersView.autoresizingMask				= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    filtersView.selectedMask                    = thumbsHolder.selectedFilterMask;
    filtersView.backgroundColor                 = [UIColor clearColor];
    [filtersTableHolder addSubview:filtersView];
    filtersTableHolder.hidden = YES;
}

-(NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section
{
    return thumbsHolder.filtersThumbs.count;
}
- (CGSize)   easyTableView:(EasyTableView *)easyTableView sizeForImageAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(65, 65);
}
- (UIImage*) easyTableView:(EasyTableView *)easyTableView imageForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return [thumbsHolder.filtersThumbs objectAtIndex:indexPath.row];
}
-(void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView
{
    [filtersView reloadData];
    [filter removeAllTargets];
    
    filterNum = indexPath.row;
    filter = [thumbsHolder getFilterAtIndex:filterNum];
    [self turnFilterUpWithBlur];
    
}
-(void) turnFilterUpWithBlur
{
    @autoreleasepool {
        [filter         removeAllTargets];
        [brightFilter   removeAllTargets];
        [stillCamera    removeAllTargets];
        [blurFilter     removeAllTargets];
        
       
        if (!blurTurnedOn)
        {
            [stillCamera        addTarget:brightFilter];
            if (filter)
            {
                [brightFilter   addTarget:filter];
                [filter         addTarget:cameraView];
            }
            else {
                [brightFilter   addTarget:cameraView];
            }
        }
        else
        {
            [stillCamera        addTarget:blurFilter];
            if (filter)
            {
                [blurFilter     addTarget:filter];
                [filter         addTarget:cameraView];
            }
            else
            {
                [blurFilter     addTarget:cameraView];
            }
        }
        [stillCamera waitForFrame];
    }
}


-(void)dealloc
{
    NSLog(@"deallocated cameracontroller");
    [self clearAll];
}
@end
