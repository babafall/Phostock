//
//  UploadingView.m
//  Phostock
//
//  Created by Roman Truba on 10.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UploadingView.h"


@implementation UploadingView

+(UploadingView *)getNew
{
    return [[[NSBundle mainBundle] loadNibNamed:@"UploadingView" owner:nil options:nil] objectAtIndex:0];
}

-(void)awakeFromNib
{
    [self.progressBar makeView:self.progressBar.frame
               backgroundImage:[UIImage imageNamed:@"Uploading_1"]
                 progressImage:[UIImage imageNamed:@"UploadingProgress_1"]];
}
-(void) setUploadingImage:(UIImage*) uploadingImage
{
    UIImage * maskI = [UIImage imageNamed:@"PhotoUploadMask"];
    UIGraphicsGetCurrentContext();
    // draw image
    UIGraphicsBeginImageContext(maskI.size);
    [uploadingImage drawInRect:CGRectMake(0, 0, maskI.size.width, maskI.size.height)];
    
    uploadingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imageView.image = uploadingImage;
    
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[maskI CGImage];
    mask.frame = CGRectMake(0, 0, maskI.size.width, maskI.size.height);
    self.imageView.layer.mask = mask;
    self.imageView.layer.masksToBounds = YES;
}

-(void)setOnCancelBlock:(void (^)(void))onCancel
{
    self->cancelationBlock = onCancel;
}
-(IBAction) onCancelButtonClick:(id)sender
{
    if (cancelationBlock) cancelationBlock();
    [self removeFromSuperview];
}
@end
