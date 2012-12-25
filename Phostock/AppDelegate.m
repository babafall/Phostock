//
//  AppDelegate.m
//  Phostock
//
//  Created by Roman Truba on 21.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "AppDelegate.h"
#import "DefaultViewController.h"
#import "FilterImagesHolder.h"
#import "TestFlight.h"

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);    
    [TestFlight takeOff:@"3af0fefc6e687143bed5ab149e3a961e_MTQwMzk0MjAxMi0xMC0wNyAwMjo1ODowNC4zMzgyOTk"];
    [FilterImagesHolder getInstance];
    
    float height = [BaseController hasFourInchDisplay] ? 568.0f : 480.0f;
    
    self.window.frame = CGRectMake(0, 0, 320.0, height);
    self.navigationController.view.frame = CGRectMake(0, 0, 320.0, height);
    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    [self.window makeKeyAndVisible];
    
    [self simulateFading];
    

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}
- (void)simulateFading
{
    self.defaultScreen = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if ([BaseController hasFourInchDisplay])
    {
        self.defaultScreen.image = [UIImage imageNamed:@"Default-568h"];
    }
    else
    {
        self.defaultScreen.image = [UIImage imageNamed:@"Default"];
    }
    [self.window addSubview:self.defaultScreen];
    [UIView animateWithDuration:0.5 animations:^{
        self.defaultScreen.alpha = 0;
    } completion:^(BOOL finished) {
        self.defaultScreen.hidden = YES;
    }
     ];
}
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    token = [NSMutableString stringWithString:[token lowercaseString]];
    
    ApiRegisterDevice * reg = [[ApiRegisterDevice alloc] init];
    reg.token = token;
    [reg start];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"pushToken"];
    [defaults synchronize];
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    for (NSString * key in userInfo)
//    {
//        NSLog(@"Notify: %@=%@", key, userInfo[key]);
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserMentionedNotification object:nil];
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@", error);
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (!loaded)
    {
        loaded = YES;
        return;
    }
    if ([self.rootController isKindOfClass:[DefaultViewController class]])
    {
        ((DefaultViewController*)self.rootController)->becomeActive = YES;
        [self.rootController viewDidAppear:NO];
    }

    [self checkBadgeAndSendNotification];
}
-(void) checkBadgeAndSendNotification
{
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0)
    {   
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserMentionedNotification object:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
