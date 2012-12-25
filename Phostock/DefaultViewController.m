//
//  DefaultViewController.m
//  Phostock
//
//  Created by Roman Truba on 26.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DefaultViewController.h"
#import "CameraController.h"
#import "PhotoEditController.h"
#import "UIImageView+AFNetworking.h"
#import "NetWorker.h"
static int SECOND_VIEW_MARGIN = 431;
@implementation DefaultViewController
@synthesize appTitle, recentPhotosView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.rollHolder activateBottom];
    becomeActive = NO;
    loggedIn = NO;
    
    self.secondaryView.backgroundColor = [UIColor clearColor];
    SECOND_VIEW_MARGIN = self.view.frame.size.height - self.postButton.frame.size.height + 5;
    self.secondaryView.frame = CGRectMake(0, self.view.frame.size.height, 320, self.secondaryView.frame.size.height);
    [self.view addSubview:self.secondaryView];
    
    if ([[NetWorker sharedInstance] loggedIn])
    {
        [self loadedAndLoggedIn:NO];
    }
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedOnce"])
//    {
        CGRect fr = self.secondaryView.frame;
        fr.origin.y = SECOND_VIEW_MARGIN;
        [self.postButton setTitle:@"Login to Phostock" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 delay:3 options:0 animations:^{
            self.secondaryView.frame = fr;
        } completion:^(BOOL finished) {
            
        }];
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoSaved:) name:PhotoSavedEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsUpdated) name:ALAssetsLibraryChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraMadePhoto:) name:kPhotoMadeEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkFailed:) name:kNetWorkerErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoCreated:) name:PhotoCreatedEvent object:nil];
    
    [self configureButton:self.takePhotoButton withImageName:@"ShootBtn"];
    [self configureButton:self.loginButton withImageName:@"ShootBtn"];
    
    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        self.takePhotoButton.hidden = YES;
    }
    
    [self.recentPhotosView performSelectorInBackground:@selector(fetchAssets) withObject:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) viewWillAppear:(BOOL)animated
{
    if (becomeActive && !recentPhotosView.errorView.hidden)
    {
        [recentPhotosView performSelectorInBackground:@selector(fetchAssetsAfterActivity) withObject:nil];
    }
    [self.networkController viewWillAppear:animated];
}
- (void) viewDidAppear:(BOOL)animated
{
    if (becomeActive && !recentPhotosView.errorView.hidden)
    {
        [recentPhotosView performSelectorInBackground:@selector(fetchAssetsAfterActivity) withObject:nil];;
    }
    [self.networkController viewWillAppear:animated];
}
- (void) photoSaved:(UIEvent*) event
{
    becomeActive = NO;
}

-(IBAction) cameraTake:(id)sender
{
    if (!cameraController)
    {
        cameraController = [CameraController instance];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController pushViewController:cameraController animated:YES];
    cameraController = nil;
}
-(IBAction) cameraRollClicked:(id)sender
{
    [self.networkController closePhotoPicker:sender];
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

-(void)recentPhotosView:(RecentPhotosView *)recentView didFailWithError:(NSError *)error
{

}
-(void)recentPhotosView:(RecentPhotosView *)recentView didSelectAsset:(ALAsset *)asset
{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Try to load asset at mediaURL
    [library assetForURL:asset.defaultRepresentation.url resultBlock:^(ALAsset *asset) {
        if (asset) {
            [self.networkController closePhotoPicker:nil];
            UIImageOrientation orientation = UIImageOrientationUp;
            NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
            if (orientationValue != nil) {
                orientation = [orientationValue intValue];
            }
            
            UIImage *img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
            img = [UIImage imageWithCGImage:img.CGImage scale:1 orientation:orientation];
            [self prepareEditControllerWithImage:img];
            photoEditController.canRetake = NO;
            [self pushPhotoEditController];
        } else {
            [recentPhotosView performSelectorInBackground:@selector(fetchAssetsAfterActivity) withObject:nil];;
        }
    } failureBlock:^(NSError *error) {
        [recentPhotosView performSelectorInBackground:@selector(fetchAssetsAfterActivity) withObject:nil];;
    }];
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}
-(void)didReceiveMemoryWarning
{
    [self.recentPhotosView clear];
    photoEditController = nil;
    cameraController = nil;
}
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((__bridge CFStringRef)(mediaType), kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        [self prepareEditControllerWithImage:imageToUse];
        
        [self performSelector:@selector(pushPhotoEditController) withObject:nil afterDelay:0.1];
    }
    [self dismissModalViewControllerAnimated: YES];
}
-(void) prepareEditControllerWithImage:(UIImage*) imageToUse
{
    if (!photoEditController)
    {
        photoEditController = [[PhotoEditController alloc] initWithNibName:@"PhotoEditController" bundle:[NSBundle mainBundle]];
    }
    PhotoEditController * vc = photoEditController;
    vc.fromCamera = NO;
    vc.workingImage = imageToUse;
    vc.cameraBlurIsOn = NO;
    if (self.networkController)
    {
        vc.makeUserPic          = self.networkController.shouldMakeAvatarPhoto;
        vc.photoInfoForResponse = self.networkController.photoInfoForReply;
    }
}
-(void) pushPhotoEditController
{
    if (photoEditController)
    {

        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        
        [self.navigationController pushViewController:photoEditController animated:YES];
        photoEditController = nil;
    }
}
-(void) assetsUpdated
{
    [recentPhotosView performSelectorInBackground:@selector(fetchAssetsAfterActivity) withObject:nil];;
}
-(void)cameraMadePhoto:(NSNotification*) notification
{
    UIImage * image = [notification.object objectForKey:kCameraImageKey];
    NSNumber * filterNum = [notification.object objectForKey:kCameraFilterKey];
    BOOL blurTurnedOn = [[notification.object objectForKey:kBlurFilterKey] boolValue];
    NSValue * blurPointValue = [notification.object objectForKey:kBlurPointKey];
    NSNumber * blurSize     = [notification.object objectForKey:kBlurSizeKey];
    CGPoint blurPoint;
    [blurPointValue getValue:&blurPoint];
    
    [self prepareEditControllerWithImage:image];
    photoEditController.canRetake = YES;
    photoEditController.filterNum = filterNum.intValue;
    photoEditController.fromCamera = YES;
    photoEditController.cameraBlurIsOn = blurTurnedOn;
    photoEditController.cameraBlurPoint = blurPoint;
    photoEditController.cameraBlurSize = blurSize.floatValue;
    [self pushPhotoEditController];
}

#pragma mark SecondScreen
-(IBAction)postButtonClicked
{
    CGFloat marginTop = SECOND_VIEW_MARGIN;
    CGRect main = self.mainView.frame, second = self.secondaryView.frame;
    self.errorLabel.hidden = YES;
    if (main.origin.y == 0)
    {
        self.loadActivity.hidden = YES;
        main.origin.y = -marginTop;
        second.origin.y = 0;
        [UIView animateWithDuration:0.5 animations:^{
            self.mainView.frame = main;
            self.secondaryView.frame = second;
            self.errorLabel.alpha = 1;
            [self.postButton setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
            [self.postButton setImage:[UIImage imageNamed:@"Cancel_Acitve"] forState:UIControlStateHighlighted];
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [self.loginInput resignFirstResponder];
        main.origin.y = 0;
        second.origin.y = marginTop;
        [self.postButton setImage:[UIImage imageNamed:@"DownArrow"] forState:UIControlStateNormal];
        [self.postButton setImage:[UIImage imageNamed:@"DownArrow_Acitve"] forState:UIControlStateHighlighted];
        [UIView animateWithDuration:0.5 animations:^{
            self.mainView.frame = main;
            self.secondaryView.frame = second;
            
        }];
    }
}
-(IBAction)loginButtonClicked
{
    [self makeLogin];
}
-(void) setErrorLabelText:(NSString*) text
{
    if ([text isEqualToString:@""])
    {
        self.errorLabel.hidden = YES;
        return;
    }
    BOOL animate = self.errorLabel.hidden == YES;
    self.errorLabel.text = text;
    if (animate)
    {
        self.errorLabel.hidden = NO;
        self.errorLabel.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.errorLabel.alpha = 1;
        }];
    }
}
-(void) makeLogin
{
    if (self.loginInput.text.length < 4)
    {
        [self setErrorLabelText:@"Username should be 4 letters minimum"];
        return;
    }
    [self.loginInput resignFirstResponder];
    ApiLogin * login = [[ApiLogin alloc] initWithLogin:self.loginInput.text];
    [login start:^(int response) {
        self.loadActivity.hidden = YES;
        
        switch (response) {
            case kLoginSuccessful:
            {
                self.errorLabel.hidden = YES;
                [self loadedAndLoggedIn:YES];
                
                int64_t delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                     [self postButtonClicked];
                });

            }
            break;
            case kLoginUserExists:
            {
                [self setErrorLabelText:@"Sorry, this username is already taken"];
                self.errorLabel.hidden = NO;
                break;
            }
            case kLoginConnectionFailed:
            {
                [self networkFailed:nil];
            }
            default:
            {
                break;
            }
        }
        
    }];
    self.loadActivity.hidden = NO;
    [self.loadActivity startAnimating];
}
-(void) prepareLogoff
{
    CGRect rollFrame = self.rollHolder.frame;
    rollFrame.origin.y = 133;
    self.rollHolder.frame = rollFrame;
    [self.rollHolder activateBottom];
    [self.mainView addSubview:self.rollHolder];
    
    self.postButton.avatarImageView.image = nil;
    [self.postButton setTitle:@"Login to Phostock" forState:UIControlStateNormal];
    loggedIn = NO;
    [UIView animateWithDuration:0.5 animations:^{
         self.networkController.view.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self.networkController.view removeFromSuperview];
        [self madeLogoff];
    }];
}
-(void) madeLogoff
{
    [self.networkController clear];
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs setBool:NO forKey:kNewsFeedVisible];
    [defs setBool:NO forKey:kMentionsVisible];
    [defs synchronize];
    self.networkController = nil;
}

-(void)networkFailed:(NSNotification*) notify
{
    self.loadActivity.hidden = YES;
    [self setErrorLabelText:@"Sorry, server unavailable"];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self makeLogin];
    return YES;
}
#define ACCEPTABLE_CHARECTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([string isEqualToString:@""]) return YES;
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];

    if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
        return NO;
    }
    return YES;
}
-(void) loadedAndLoggedIn:(BOOL) shouldMakeMargin
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"loggedOnce"];
    [defaults synchronize];
    
    loggedIn = YES;
    self.loadActivity.hidden = YES;
//    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
//    NSLog(@"status: %f", statusBarFrame.size.height);
    //Далее работать внутри NetworkTabbedController
    if (!self.networkController)
    {
        self.networkController = [[NetworkTabbedController alloc] initWithNibName:@"NetworkTabbedController" bundle:nil];
        self.networkController.mainController = self;
        self.networkController.cNavigationController = self.navigationController;
    }
    
   
    self.networkController.view.frame = self.view.frame;
    [self.view addSubview:self.networkController.view];
    if (shouldMakeMargin)
    {
        [self.networkController viewWillAppear:YES];
        self.networkController.view.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            self.networkController.view.alpha = 1;
        }];
    }
    
   
}

//Только если не залогинен
-(void) photoCreated:(NSNotification*) notification
{
    
    if (loggedIn) return;
        
    [self savePhoto:notification.object toCameraRoll:^(BOOL okay, UIImage * resultImage) {
        firstPostImage = [notification.object objectForKey:kPhoto];
        firstPostCaption = [notification.object objectForKey:kCaption];
        
        UIImage * image = resultImage;
        UIImage * maskImage = [UIImage imageNamed:@"FeedAvatarMask"];
        if (maskImage)
        {
            image = [UIImageView makeMaskedImage:image mask:maskImage];
        }
        
        self.postButton.avatarImageView.image = image;
        [self.postButton setTitle:@"Post to Phostock" forState:UIControlStateNormal];
        if (self.secondaryView.frame.origin.y == self.view.frame.size.height)
        {
            CGRect fr = self.secondaryView.frame;
            fr.origin.y = SECOND_VIEW_MARGIN;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.secondaryView.frame = fr;
            }];
        }
    }];
}
-(void) savePhoto:(NSDictionary*) photoInfo toCameraRoll:(void(^)(BOOL okay, UIImage * resultImage)) onComplete
{
    
//    void (^printXAndY)(int)
    void (^saveblock)(UIImage*, NSString*) = ^(UIImage * toSave, NSString * caption){
        runOnMainQueueWithoutDeadlocking(^{
            [self.photoDrawer drawImage:toSave withCaption:caption onComplete:^(UIImage *result) {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageToSavedPhotosAlbum:result.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
                    onComplete(error == nil, result);
                }];
            }];
        });
    };
    
    
    id photo = [photoInfo objectForKey:kPhoto];
    
    id caption = [photoInfo objectForKey:kCaption];
    if ([caption isKindOfClass:[FastAttributedString class]])
    {
        caption = [(FastAttributedString*)caption originalString];
    }
    if ([photo isKindOfClass:[UIImage class]]) {
        saveblock(photo, caption);
    }
    else
    {
        [[NetWorker sharedInstance] getImageForUrl:photo onComplete:^(UIImage *resultImage) {
            saveblock(resultImage, caption);
        } onFailed:^(NSError *resultError) {
//            NSLog(@"Failed to load image %@", resultError);
        }];
    }
}

@end
