//
//  ImageDrawerView.h
//  Phostock
//
//  Created by Roman Truba on 03.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "UIFastLabel.h"
@interface ImageDrawerView : UIView
{
    GPUImageAlphaBlendFilter * blendFilter;
//    GPUImageUIElement        * drawTagsElement;
    GPUImageUIElement        * drawCaptionElement;
    UIImage                  * imageToDraw;
    GPUImagePicture          * drawingPicture;
}
@property (nonatomic, strong) IBOutlet GPUImageView * imageView;
@property (nonatomic, strong) IBOutlet UIView       * textHolder;
@property (nonatomic, strong) IBOutlet UILabel  * captionLabel;


-(void)drawImage:(UIImage *)image withCaption:(NSString *)caption onComplete:(void(^)(UIImage * result)) onComplete;

@end
