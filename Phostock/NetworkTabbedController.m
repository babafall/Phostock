//
//  NSTabbedController.m
//  Phostock
//
//  Created by Roman Truba on 28.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "NetworkTabbedController.h"
#import "NetworkMainViewController.h"
#import "UITabBarController+HideTabBar.h"
#import "AllPhotosController.h"
#import "UserPhotosController.h"
#import "CameraController.h"
#import "DefaultViewController.h"
#import "NewsFeedController.h"
#import "RepliesViewController.h"


@implementation NetworkTabbedController
@synthesize mainController, selectedControllerIndex;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.wantsFullScreenLayout = YES;
    }
    return self;
}
-(void)viewDidLoad
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    [super viewDidLoad];
    self.bottomTabs.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bottom"]];
    
    usersController = [[UserPhotosController alloc] initWithNibName:@"UserPhotosController" bundle:[NSBundle mainBundle]];
    usersController.bottomTabs = self.bottomTabs;
    usersController.tabbedController = self;
    if (mainController->firstPostImage)
    {
        [self uploadPhoto:mainController->firstPostImage
              withCaption:mainController->firstPostCaption
                  replyId:nil isPublic:NO];
        mainController->firstPostImage = nil;
        mainController->firstPostCaption = nil;
    }
    
    AllPhotosController * controller2 = [[AllPhotosController alloc] initWithNibName:@"AllPhotosController" bundle:[NSBundle mainBundle]];
    controller2.bottomTabs = self.bottomTabs;
    controller2.tabbedController = self;
    
    allPhotosController = [[UINavigationController alloc] initWithRootViewController:controller2];
    allPhotosController.navigationBarHidden = YES;
    allPhotosController.delegate = self;
    
    homeConroller = [[NewsFeedController alloc] initWithNibName:@"NewsFeedController" bundle:[NSBundle mainBundle]];
    homeConroller.bottomTabs = self.bottomTabs;
    homeConroller.tabbedController = self;
    homeNavigationConroller = [[UINavigationController alloc] initWithRootViewController:homeConroller];
    homeNavigationConroller.navigationBarHidden = YES;
    homeNavigationConroller.delegate = self;
    
    repliesController = [[RepliesViewController alloc] initWithNibName:@"RepliesViewController" bundle:[NSBundle mainBundle]];
    repliesController.bottomTabs = self.bottomTabs;
    repliesController.tabbedController = self;
    repliesNavigationController = [[UINavigationController alloc] initWithRootViewController:repliesController];
    repliesNavigationController.navigationBarHidden = YES;
    repliesNavigationController.delegate = self;
    
    viewControllers = @[homeNavigationConroller, allPhotosController, repliesNavigationController, usersController];
    
    for (int index = 0; index < viewControllers.count; index++)
    {
        UIViewController * vc = viewControllers[index];
        if (![vc isKindOfClass:[NetworkMainViewController class]])
        {
            vc = [[(UINavigationController*)vc viewControllers] objectAtIndex:0];
        }
        TabButton * tb = [self.bottomTabs buttonAtIndex:index];
        [(NetworkMainViewController*)vc setTabButton:tb];
        tb.parentController = self;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameUpdated:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoCreated:) name:PhotoCreatedEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userMentionsSearch:) name:kSearchUserMentionNotification object:nil];
    
    //Photopicker
    self.selectPhotosView.frame = RectSetY(self.selectPhotosView.frame, 20);
    UIImage * bg = [UIImage imageNamed:@"background"];
    [[self.selectPhotosView.subviews objectAtIndex:1] setBackgroundColor: [UIColor colorWithPatternImage:bg] ];
    
    [self configureButton:self.shootBtn withImageName:@"ShootBtn"];
    [self configureButton:self.cancelBtn withImageName:@"RollBtn"];
    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        self.shootBtn.hidden = YES;
    }
    
    RollHolderView * roll = mainController.rollHolder;
    roll.frame = self.rollPlaceholder.frame;
    
    self.rollPlaceholder.hidden = YES;
    [self.rollPlaceholder.superview addSubview:roll];
    self.rollHolder = roll;
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    
    if (![defs boolForKey:kNewsFeedVisible])
    {
        [self hideTabButton:0 animated:NO];
        
    }
    if (![defs boolForKey:kMentionsVisible])
    {
        [self hideTabButton:2 animated:NO];
    }
    [self selectControllerAtIndex:[viewControllers indexOfObject:usersController]];
    if ([defs boolForKey:kNewsFeedVisible])
    {
        [self selectControllerAtIndex:0];
    }
}


-(IBAction) allPhotosPressed:(id)sender
{
    if (!allPhotosController.view.hidden)
    {
        if (allPhotosController.viewControllers.count > 1)
        {
            lastUserController = allPhotosController.viewControllers.lastObject;
            [allPhotosController popViewControllerAnimated:YES];
            [self.bottomTabs selectButtonAtIndex:1];
            return;
        }
        else
        {
            NetworkMainViewController * nc = (NetworkMainViewController*)[allPhotosController.viewControllers objectAtIndex:0];
            [nc resetSearch];
        }
    }
    if (!allPhotosController.view.hidden && [allPhotosController viewControllers].count > 1)
    {
        [self.bottomTabs unselectAll];
    }
}
-(void) selectControllerAtIndex:(int) index
{
    UIViewController * vc = viewControllers[index];
    
    [self.bottomTabs selectButtonAtIndex:index];

    if (index == selectedControllerIndex)
    {

        if ([vc isKindOfClass:[UINavigationController class]])
        {
            UINavigationController * nvc = (UINavigationController*)vc;
            if (!vc.view.hidden)
            {
                if (nvc.viewControllers.count > 1)
                {
                    lastUserController = nvc.viewControllers.lastObject;
                    [nvc popViewControllerAnimated:YES];
                    [self.bottomTabs selectButtonAtIndex:index];
                }
                else
                {
                    NetworkMainViewController * nc = (NetworkMainViewController*)[nvc.viewControllers objectAtIndex:0];
                    if ([nc isKindOfClass:[AllPhotosController class]])
                    {
                         [nc resetSearch];
                    }
                    
                }
            }
        }
        return;
    }
    else if ([vc isKindOfClass:[UINavigationController class]])
    {
        UINavigationController * nvc = (UINavigationController*)vc;
        if (nvc.viewControllers.count > 1)
        {
            [self.bottomTabs unselectAll];
        }
    }
    if (![[viewControllers[index] view] superview])
    {
        [self.view insertSubview:[viewControllers[index] view] atIndex:0];
    }
    
    [viewControllers[selectedControllerIndex] viewWillDisappear:NO];
    [viewControllers[index] viewWillAppear:NO];
    
    [[viewControllers[selectedControllerIndex] view] setHidden:YES];
    [[viewControllers[index] view] setHidden:NO];
    
    [viewControllers[index] viewDidAppear:NO];
    [viewControllers[selectedControllerIndex] viewDidDisappear:NO];
    
    selectedControllerIndex = index;

    
    [[viewControllers[index] view] addSubview:self.bottomTabs];
}
-(void)buttonPressed:(id)sender
{
    int index = [self.bottomTabs indexOfButton:sender];
    [self selectControllerAtIndex:index];
}
-(NetworkMainViewController*) showSearchController
{
    [self selectControllerAtIndex:1];
    return [allPhotosController.viewControllers objectAtIndex:0];
}
-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [super viewWillAppear:animated];
    [self statusBarFrameUpdated:nil];
    [viewControllers[selectedControllerIndex] viewWillAppear:animated];
    [viewControllers[selectedControllerIndex] viewDidAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [super viewDidAppear:animated];
    [self statusBarFrameUpdated:nil];
    [viewControllers[selectedControllerIndex] viewDidAppear:animated];
}
-(void) statusBarFrameUpdated:(NSNotification*) notification
{

    CGRect sf = self.view.frame;
    sf.origin.y = 20;
    sf.size.height = [BaseController hasFourInchDisplay] ? 568 : 480;
    self.view.frame = sf;
}
-(void) showPhotoPickerForReply:(NSDictionary*) photoInfo
{
    self.photoInfoForReply = photoInfo;
    [self photoPickerAva:NO];
}
-(IBAction) showPhotoPicker:(id)sender
{
    self.photoInfoForReply = nil;
    [self photoPickerAva:NO];
}
-(void) photoPickerAva:(BOOL) ava
{
    self.shouldMakeAvatarPhoto = ava;
    UIView * parent = self.view.superview;
    
    if (self.photoInfoForReply)
    {
        self.selectReplyView.hidden = NO;
        [self.replyPhotoView setImageWithURL:[NSURL URLWithString:[self.photoInfoForReply objectForKey:kPhoto] ] maskImage:[UIImage imageNamed:@"PhotoReplyMaskPhoto"]];
        [self.rollHolder activateTop];
    }
    else
    {
        self.selectReplyView.hidden = YES;
        [self.rollHolder activateBottom];
    }
    
    [parent addSubview:self.selectPhotosView];
    UIView * bg = [self.selectPhotosView.subviews objectAtIndex:0];
    UIView * picker = [self.selectPhotosView.subviews objectAtIndex:1];
    bg.alpha = 0;
    CGRect viewFr = self.selectPhotosView.frame, pickerFr = picker.frame;
    picker.frame = CGRectMake(0, CGRectGetHeight(viewFr), CGRectGetWidth(viewFr), CGRectGetHeight(pickerFr));
    
    [UIView animateWithDuration:0.3 animations:^{
        picker.frame = CGRectMake(0, CGRectGetHeight(viewFr) - CGRectGetHeight(pickerFr), CGRectGetWidth(viewFr), CGRectGetHeight(pickerFr));
        bg.alpha = 1;
    }];
}

-(IBAction) closePhotoPicker:(id)sender
{
    UIView * bg = [self.selectPhotosView.subviews objectAtIndex:0];
    UIView * picker = [self.selectPhotosView.subviews objectAtIndex:1];
    CGRect viewFr = self.selectPhotosView.frame, pickerFr = picker.frame;
    [UIView animateWithDuration:0.3 animations:^{
        picker.frame = CGRectMake(0, CGRectGetHeight(viewFr), CGRectGetWidth(viewFr), CGRectGetHeight(pickerFr));
        bg.alpha = 0;
    }  completion:^(BOOL finished) {
        [self.selectPhotosView removeFromSuperview];
    }];
}

-(IBAction) takePhotoClicked:(id)sender
{
    [self closePhotoPicker:nil];
    [mainController cameraTake:sender];
}
-(IBAction) cameraRollClicked:(id)sender
{
    [self closePhotoPicker:nil];
    [mainController cameraRollClicked:sender];
}
-(IBAction) logoutClicked:(id)sender
{
    [mainController prepareLogoff];
    [[NetWorker sharedInstance] logout];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self closePhotoPicker:nil];
}

-(void) showPhotoPickerForAvatar:(BOOL) forAvatar
{
    self.photoInfoForReply = nil;
    [self photoPickerAva:forAvatar];
}
-(void) hideTabButton:(int) index animated:(BOOL) animated
{
    TabButton * tabToHide = tabButtons[index];
    tabToHide.isVisible = NO;
    TabButton * tabToLeave = nil;
    CGRect hideRect = tabToHide.frame, leaveRect;
    if (index < 2) {
        int moveIndex = index == 0 ? 1 : 0;
        tabToLeave = tabButtons[index == 0 ? 1 : 0];
        leaveRect = RectSetOrigin(tabToLeave.frame, (120 - RectWidth(tabToLeave.frame)) / 2, 0);
        if (moveIndex == 0)
        {
            hideRect = RectSetOrigin(hideRect, 60, RectHeight(hideRect));
        }
        else
        {
            hideRect = RectSetOrigin(hideRect, 0, RectHeight(hideRect));
        }
        
    }
    else {
        int moveIndex = index == 2 ? 3 : 2;
        tabToLeave = tabButtons[index == 2 ? 3 : 2];
        leaveRect = RectSetOrigin(tabToLeave.frame, 200 + (120 - RectWidth(tabToLeave.frame)) / 2, 0);
        if (moveIndex == 2)
        {
            hideRect = RectSetOrigin(hideRect, 260, RectHeight(hideRect));
        }
        else
        {
            hideRect = RectSetOrigin(hideRect, 200, RectHeight(hideRect));
        }
    }
//    hideRect  = RectSetOrigin(hideRect, RectX(hideRect), RectHeight(hideRect));
    
    [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
        tabToHide.frame = hideRect;
        tabToLeave.frame = leaveRect;
    }];
    
}
-(void) showTabButton:(int) index animated:(BOOL) animated
{
    TabButton * tabToShow = tabButtons[index];
    tabToShow.isVisible = YES;
    TabButton * tabToMove = nil;
    CGRect showRect = tabToShow.frame, moveRect;
    if (index < 2) {
        int moveIndex = index == 0 ? 1 : 0;
        tabToMove = tabButtons[moveIndex];
        moveRect = tabToMove.frame;
        if (moveIndex == 1)
        {
            moveRect = RectSetOrigin(moveRect, 60, 0);
            showRect = RectSetOrigin(showRect, 0, 0);
        }
        else
        {   
            moveRect = RectSetOrigin(moveRect, 0, 0);
            showRect = RectSetOrigin(showRect, 60, 0);
        }
    }
    else {
        int moveIndex = index == 2 ? 3 : 2;
        tabToMove = tabButtons[index == 2 ? 3 : 2];
        moveRect = tabToMove.frame;
        if (moveIndex == 3)
        {
            moveRect = RectSetOrigin(moveRect, 260, 0);
            showRect = RectSetOrigin(showRect, 200, 0);
        }
        else
        {
            moveRect = RectSetOrigin(moveRect, 200, 0);
            showRect = RectSetOrigin(showRect, 260, 0);
        }
    }

    [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
        tabToShow.frame = showRect;
        tabToMove.frame = moveRect;
    }];
}
-(void) showTabButton:(TabButton *) button
{
    [self showTabButton:[self.bottomTabs indexOfButton:button] animated:YES];
}
-(void) hideTabButton:(TabButton *) button
{
    [self hideTabButton:[self.bottomTabs indexOfButton:button] animated:YES];
}
-(void) cleanControllers:(NSArray*) vControllers
{
    for (UIViewController * c in vControllers)
    {
        if ([c isKindOfClass:[UINavigationController class]])
        {
            [self cleanControllers:[(UINavigationController*)c viewControllers]];
        }
        else if ([c isKindOfClass:[NetworkMainViewController class]])
        {
            [(NetworkMainViewController*)c clear];
        }
    }
}
-(void) clear
{
    if (self.view)
    {
        for (UIView * v in self.view.subviews)
        {
            [v removeFromSuperview];
        }
    }
    
    [[NSNotificationCenter defaultCenter ] removeObserver:self];
    [self cleanControllers:viewControllers];
    
    for (UIViewController * uc in viewControllers)
    {
        if ([uc isKindOfClass:[UINavigationController class]])
        {
            UINavigationController * nc = (UINavigationController *)uc;
            [nc popToRootViewControllerAnimated:NO];
            [(NetworkMainViewController*)[allPhotosController.viewControllers objectAtIndex:0] setTabbedController:nil];
        }
        else if ([uc isKindOfClass:[NetworkMainViewController class]])
        {
            [(NetworkMainViewController*)uc setTabbedController:nil];
        }
    }
    viewControllers = nil;
}
-(void)dealloc
{
    NSLog(@"Dealloc: %@", self);
}
-(void) photoCreated:(NSNotification*) notification
{
    UIImage  * photo     = [notification.object objectForKey:kPhoto];
    NSString * caption  = [notification.object objectForKey:kCaption];
    NSString * replyId  = [notification.object objectForKey:kReplyId];
    BOOL       isPublic = [[notification.object objectForKey:kIsPublic] boolValue];
    
    [self uploadPhoto:photo withCaption:caption replyId:replyId isPublic:isPublic];
    
}
-(void) uploadPhoto:(UIImage*) photo withCaption:(NSString*)caption replyId:(NSString*) replyId isPublic:(BOOL) isPublic
{
    UploadingView * uv = [UploadingView getNew];
    [self.view addSubview:uv];
    [[NetWorker sharedInstance] uploadPhoto:photo caption:caption replyId:replyId isPublic:isPublic uploadingView:uv complete:^(NSDictionary *users, PhotoResponse *photos) {
        [uv removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:PhotoUploadedEvent object:nil];
        //        self->loadingPhotoNow = NO;
        //        [photoDescr setValuesForKeysWithDictionary:[photos.photos objectAtIndex:0]];
        //        [photoDescr setObject:[NSNumber numberWithBool:NO] forKey:kWillBeLoaded];
        //
        //        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        //        NSDictionary * user = nil;
        //        for (NSString * userId in users.allKeys)
        //        {
        //            user = [users objectForKey:userId];
        //            NSDictionary * userPhoto = [user objectForKey:@"photo"];
        //            if (userPhoto && (id)userPhoto != [NSNull null] ) {
        //                NSString * photo_small = [userPhoto objectForKey:@"photo_small"];
        //                if (photo_small) {
        //                    [defaults setObject:photo_small forKey:kUserPhoto];
        //                }
        //            }
        //        }
        //        [defaults synchronize];
        //        isLoading = NO;
        //
        //        if (self.tabbedController.shouldMakeAvatarPhoto && user && isMyPage)
        //        {
        //            for (NSMutableDictionary * photoDescr in photosArray) {
        //                [photoDescr setObject:user forKey:kUserInfo];
        //            }
        //        }
        //        [self.tableView reloadData];
        //        
        //        if (shouldLoadFeed)
        //        {
        //            replaceFirst = YES;
        //            [self loadFeedForUser];
        //        }
    }];
}
-(void) userMentionsSearch:(NSNotification*) notification
{
    [self selectControllerAtIndex:1];
    NSString * nickname = [@"@" stringByAppendingString: notification.object];
    NSLog(@"Nickname %@", nickname);
    [(AllPhotosController*)(allPhotosController.viewControllers[0]) searchByText:nickname];
}
@end
