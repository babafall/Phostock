//
//  AppDelegate.h
//  Phostock
//
//  Created by Roman Truba on 21.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL loaded;
}
@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet UINavigationController * navigationController;
@property (strong, nonatomic) IBOutlet UIViewController       * rootController;

@property (strong, nonatomic) IBOutlet UIImageView       * defaultScreen;
@end
