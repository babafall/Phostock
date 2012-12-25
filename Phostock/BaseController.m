//
//  BaseController.m
//  Phostock
//
//  Created by Roman Truba on 28.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "BaseController.h"

@implementation BaseController
-(void) resetCoords
{
//    CGRect rectApp = [[UIScreen mainScreen] bounds];
//    self.view.frame = rectApp;
//    self.navigationController.view.frame = rectApp;
//    self.view.frame = self.view.bounds;
//    self.navigationController.view.frame = self.view.bounds;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.wantsFullScreenLayout = YES;
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetCoords];
}
//
//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self resetCoords];
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage * bg                        = [UIImage imageNamed:@"background"];
    self.view.backgroundColor           = [UIColor colorWithPatternImage:bg];
    self.secondaryView.backgroundColor  = [UIColor colorWithPatternImage:bg];
    self.secondaryView.frame = self.view.frame;
}
+ (BOOL)hasFourInchDisplay {
    
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}
- (void) configureInput:(UITextField*) input withImageName:(NSString*) imageName
{
    UIImage * defaultImage = [UIImage imageNamed:imageName];
    int cap = (int)(defaultImage.size.height / 2.2);
    UIImage * normalImage = [defaultImage stretchableImageWithLeftCapWidth:cap topCapHeight:cap];
    
    input.background = normalImage;
}
- (void) configureButton:(UIButton*) button withImageName:(NSString*) imageName
{
    
    UIImage * defaultImage = [UIImage imageNamed:imageName];
    int cap = (int)(defaultImage.size.height / 2.2);
    UIImage * normalImage = [defaultImage stretchableImageWithLeftCapWidth:cap topCapHeight:cap];
    UIImage * pressedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@_Pressed", imageName]] stretchableImageWithLeftCapWidth:cap topCapHeight:cap];
    UIImage * selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@_Active", imageName]] stretchableImageWithLeftCapWidth:cap topCapHeight:cap];
    
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    [button setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:(selectedImage ? selectedImage : pressedImage) forState:UIControlStateSelected];
}
- (UIImage *)scaleAndRotateImage:(UIImage *)image {
    int kMaxResolution = 2048; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}
+(UIImage*) cropToMask:(UIImage*) target targetSize:(CGSize) targetSize
{
    CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    // create a bitmap graphics context the size of the image
    mainViewContentContext = CGBitmapContextCreate (NULL, targetSize.width, targetSize.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    // free the rgb colorspace
    CGColorSpaceRelease(colorSpace);
    
    if (mainViewContentContext==NULL)
        return NULL;
    
    CGImageRef maskImage = [[UIImage imageNamed:@"CropFilterMask"] CGImage];
    CGContextClipToMask(mainViewContentContext, CGRectMake(0, 0, targetSize.width, targetSize.height), maskImage);
    CGContextDrawImage(mainViewContentContext, CGRectMake(-targetSize.width/2, -targetSize.height * 0.8, targetSize.width * 1.8, targetSize.height * 1.8), target.CGImage);
    
    UIImage * standardMask = [UIImage imageNamed:@"FilterMask"];
    CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, targetSize.width, targetSize.height), standardMask.CGImage);
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    // convert the finished resized image to a UIImage
    UIImage *theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
    // image is retained by the property setting above, so we can
    // release the original
    CGImageRelease(mainViewContentBitmapContext);
    
    // return the image
    return theImage;
}
@end
