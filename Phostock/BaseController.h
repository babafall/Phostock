//
//  BaseController.h
//  Phostock
//
//  Created by Roman Truba on 28.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )

#define PhotoSavedEvent @"PhotoSavedNotificationEvent"
#define PhotoCreatedEvent @"PhotoCreatedNotificationEvent"
#define PhotoUploadedEvent @"PhotoUploadedNotificationEvent"

#define SCREEN_H [UIScreen mainScreen].applicationFrame.size.height
#define SCREEN_HF [UIScreen mainScreen].bounds.size.height

@interface BaseController : UIViewController

@property (nonatomic, strong) IBOutlet UIView * secondaryView;
+ (BOOL) hasFourInchDisplay;
- (void) configureButton:(UIButton*) button withImageName:(NSString*) imageName;
- (UIImage*) scaleAndRotateImage:(UIImage *)image;
+ (UIImage*) cropToMask:(UIImage*) target targetSize:(CGSize) targetSize;
@end
