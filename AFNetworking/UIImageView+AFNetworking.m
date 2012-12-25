// UIImageView+AFNetworking.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define UI_IMAGE_VIEW_ACTIVITY_INDICATOR 777

#if __IPHONE_OS_VERSION_MIN_REQUIRED


#import "UIImageView+AFNetworking.h"

#pragma mark -

static char kAFImageRequestOperationObjectKey;

@interface UIImageView (_AFNetworking)
@property (readwrite, nonatomic, retain, setter = af_setImageRequestOperation:) AFImageRequestOperation *af_imageRequestOperation;
@end

@implementation UIImageView (_AFNetworking)
@dynamic af_imageRequestOperation;
@end

#pragma mark -

@implementation UIImageView (AFNetworking)
@dynamic progressBar;
- (void)setProgressBar:(CustomProgressBar*)aObject
{
    objc_setAssociatedObject(self, @"customProgressBar", aObject, OBJC_ASSOCIATION_RETAIN);
}
- (CustomProgressBar*)progressBar
{
    return objc_getAssociatedObject(self,  @"customProgressBar");
}
- (void)setDontUseProgressBar:(BOOL)dontUseProgressBar
{
    objc_setAssociatedObject(self, @"dontUseProgressBar", @(dontUseProgressBar), OBJC_ASSOCIATION_RETAIN);
}
- (BOOL) dontUseProgressBar
{
    return [objc_getAssociatedObject(self,  @"dontUseProgressBar") boolValue];
}

- (AFHTTPRequestOperation *)af_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFImageRequestOperationObjectKey);
}

- (void)af_setImageRequestOperation:(AFImageRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kAFImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_imageRequestOperationQueue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_af_imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    
    return _af_imageRequestOperationQueue;
}

+ (JMImageCache *)af_sharedImageCache {
    return [JMImageCache sharedCache];
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url maskImage:nil];   
}
- (void)setImageWithURL:(NSURL *)url callback:(void(^)(BOOL successfull))onComplete {
    if (!url || (id)url == [NSNull null]) return;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
IF_IOS5_OR_GREATER(
    [request setHTTPShouldUsePipelining:YES];
                   );
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self setImageWithURLRequest:request maskImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (onComplete) onComplete(YES);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (onComplete) onComplete(NO);
    }];
}

- (void)setImageWithURL:(NSURL *)url 
              maskImage:(UIImage *)maskImage
{
    if (!url || (id)url == [NSNull null]) return;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
IF_IOS5_OR_GREATER(
    [request setHTTPShouldUsePipelining:YES];
                   );
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:request maskImage:maskImage success:nil failure:nil];
}
- (void)setImageWithURL:(NSURL *)url
              maskImage:(UIImage *)maskImage
               callback:(void(^)(BOOL successfull))onComplete
{
    if (!url || (id)url == [NSNull null]) return;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
IF_IOS5_OR_GREATER(
    [request setHTTPShouldUsePipelining:YES];
                   );
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:request maskImage:maskImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        onComplete(YES);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        onComplete(NO);
    }];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest 
                     maskImage:(UIImage *)maskImage 
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [(NSMutableURLRequest*)urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [self cancelImageRequestOperation];
    if (self.progressBar)
        self.progressBar.hidden = YES;
    
    NSURL * cacheUrl = urlRequest.URL;
    UIImage *cachedImage = [[[self class] af_sharedImageCache] cachedImageForURL:cacheUrl];
    if (cachedImage && maskImage)
    {
        dispatch_async(dispatch_get_current_queue(), ^{
            UIImage * result = [UIImageView makeMaskedImage:cachedImage mask:maskImage];
            self.image = result;
            self.af_imageRequestOperation = nil;
            if (success) {
                success(nil, nil, result);
            }
        });
        return;
    }
    
    

    if (cachedImage) {
        self.image = cachedImage;
        self.af_imageRequestOperation = nil;
        
        if (success) {
            success(nil, nil, cachedImage);
        }
    } else {
        if (!self.progressBar)
        {
            int imageMargin = self.frame.size.width / 10;
            static int loaderH = 14;
            self.progressBar = [[CustomProgressBar alloc] initWithFrame:CGRectMake(imageMargin, (RectHeight(self.frame) - loaderH) / 2, RectWidth(self.frame) - imageMargin * 2, loaderH)
                                                        backgroundImage:[UIImage imageNamed:@"Uploading_2"]
                                                          progressImage:[UIImage imageNamed:@"UploadingProgress_2"]];
            [self addSubview:self.progressBar];
        }
        if (!self.dontUseProgressBar)
            self.progressBar.hidden = NO;
        else
            self.progressBar.hidden = YES;
        [self.progressBar setValue:0 animated:NO];
        self.image = nil;
        AFImageRequestOperation *requestOperation = [[[AFImageRequestOperation alloc] initWithRequest:urlRequest] autorelease];
        [requestOperation setQueuePriority:NSOperationQueuePriorityLow];
        [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            self.progressBar.min = 0;
            self.progressBar.max = totalBytesExpectedToRead;
            self.progressBar.value = totalBytesRead;
        }];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.progressBar.hidden = YES;
            if ([[urlRequest URL] isEqual:[[self.af_imageRequestOperation request] URL]]) {
                UIImage * image = (UIImage *)responseObject;
                if (maskImage)
                {
                    image = [UIImageView makeMaskedImage:image mask:maskImage];
                }               
                
                self.af_imageRequestOperation = nil;
                
                //Custom code
IF_IOS5_OR_GREATER(
                self.alpha = 0;
                [UIView animateWithDuration:0.3 animations:^{
                    self.alpha = 1;
                }];
                   );
                
                self.image = image;
                UIImage * downloadedImage = responseObject;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                         (unsigned long)NULL), ^(void) {
                    [[[self class] af_sharedImageCache] writeImage:downloadedImage toCache:cacheUrl];
                });
                
            }
            if (success) {
                success(operation.request, operation.response, responseObject);
            } 

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[urlRequest URL] isEqual:[[self.af_imageRequestOperation request] URL]]) {
                self.af_imageRequestOperation = nil;
                
                //Repeat
                [self setImageWithURLRequest:urlRequest maskImage:maskImage success:success failure:failure];
            }

            if (failure) {
                failure(operation.request, operation.response, error);
            }
            
        }];
        
        self.af_imageRequestOperation = requestOperation;
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}
+(AFImageRequestOperation *) preloadImage:(NSString*) imageUrl progressBar:(CustomProgressBar*) progressBar success:(void (^)(void))success
{

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl] ];
    [request setHTTPShouldHandleCookies:NO];
    IF_IOS5_OR_GREATER(
                       [request setHTTPShouldUsePipelining:YES];
                       );
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    UIImage *cachedImage = [[self af_sharedImageCache] cachedImageForURL:request.URL];
    if (cachedImage) {
        progressBar.hidden = YES;
        if (success) success();
        return nil;
    }
    
    AFImageRequestOperation *requestOperation = [[[AFImageRequestOperation alloc] initWithRequest:request] autorelease];
    [requestOperation setQueuePriority:NSOperationQueuePriorityLow];
    [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        progressBar.min = 0;
        progressBar.max = totalBytesExpectedToRead;
        progressBar.value = totalBytesRead;
    }];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        progressBar.hidden = YES;
        [[self af_sharedImageCache] writeImage:(UIImage *)responseObject toCache:[request URL]];
        if (success) success();
        NSLog(@"SUCCESSSSSS");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        progressBar.hidden = YES;
        NSLog(@"FAILURE");
    }];
    requestOperation.customProgressBar = progressBar;
    
    progressBar.hidden = NO;
    [progressBar setValue:0 animated:NO];
    [[self af_sharedImageRequestOperationQueue] addOperation:requestOperation];
    return requestOperation;
}

- (UIImage*)imageByScalingAndCroppingImage:(UIImage*)image forSize:(CGSize)targetSize
{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)cancelImageRequestOperation {
    [self.af_imageRequestOperation cancel];
    self.af_imageRequestOperation = nil;
}

+ (UIImage*) makeMaskedImage:(UIImage*) image mask:(UIImage*) maskImage
{
    UIImage * result = nil;
    CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGSize targetSize = CGSizeMake(maskImage.size.width * 2, maskImage.size.height * 2);
    // create a bitmap graphics context the size of the image
    mainViewContentContext = CGBitmapContextCreate (NULL, targetSize.width, targetSize.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    // free the rgb colorspace
    CGColorSpaceRelease(colorSpace);
    
    if (mainViewContentContext!=NULL) {
        
        CGRect rect = CGRectMake(0, 0, targetSize.width, targetSize.height);
        CGContextClipToMask(mainViewContentContext, rect, maskImage.CGImage);
//        [image drawInRect:rect];
        CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, targetSize.width, targetSize.height), image.CGImage);
        
        CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
        CGContextRelease(mainViewContentContext);
        
        // convert the finished resized image to a UIImage
        result = [UIImage imageWithCGImage:mainViewContentBitmapContext];
        CGImageRelease(mainViewContentBitmapContext);
    }
    return result;
}

@end

#pragma mark -

static inline NSString * AFImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

#endif
