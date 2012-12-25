//
//  UploadingView.h
//  Phostock
//
//  Created by Roman Truba on 10.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomProgressBar.h"
@interface UploadingView : UIView
{
    void (^cancelationBlock)(void);
}
@property (nonatomic, strong) IBOutlet UIButton * cancelButton;
@property (nonatomic, strong) IBOutlet UIImageView * imageView;
@property (nonatomic, strong) IBOutlet CustomProgressBar * progressBar;

+(UploadingView*) getNew;

-(void) setUploadingImage:(UIImage*) uploadingImage;
-(void) setOnCancelBlock:(void(^)(void)) onCancel;
@end
