//
//  ImageDrawerView.m
//  Phostock
//
//  Created by Roman Truba on 03.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ImageDrawerView.h"
#import "CaptionTagsParser.h"
#import "NetWorker.h"
@implementation ImageDrawerView

-(void)awakeFromNib
{
    [self recreateBlend];
//    drawTagsElement = [[GPUImageUIElement alloc] initWithView:self.tagsLabel];
//    [drawTagsElement prepareForImageCapture];
//    [self.tagsLabel removeFromSuperview];
    
    drawCaptionElement = [[GPUImageUIElement alloc] initWithView:self.textHolder];
    [drawCaptionElement prepareForImageCapture];
    [self.textHolder removeFromSuperview];
    
    self.captionLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.captionLabel.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.captionLabel.layer.shadowOpacity = 1.0f;
    self.captionLabel.layer.shadowRadius = 1.0f;

}
-(void) recreateBlend
{
    [blendFilter removeAllTargets];
    blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    [blendFilter prepareForImageCapture];
    blendFilter.mix = 1.0f;
    [blendFilter addTarget:self.imageView];
    
}
-(void)drawImage:(UIImage *)image withCaption:(NSString *)caption onComplete:(void(^)(UIImage * result)) onComplete
{
    imageToDraw = image;
    
    NSDictionary * captionInfo = [CaptionTagsParser prepareCaptionTags:caption];
    [self setCaptionTags:captionInfo];
    drawingPicture = [[GPUImagePicture alloc] initWithImage:imageToDraw];
    [drawingPicture prepareForImageCapture];
    
    [self recreateBlend ];
    
    [drawingPicture addTarget:blendFilter];
    [drawCaptionElement addTarget:blendFilter];
    
    [blendFilter addTarget:self.imageView];
    [drawingPicture processImage];
    [drawCaptionElement update];
    
    __unsafe_unretained GPUImageAlphaBlendFilter * blendWeak = blendFilter;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        UIImage * image = [blendWeak imageFromCurrentlyProcessedOutput];
        onComplete(image);
    });
}
-(void) setCaptionTags:(NSDictionary*) captionInfo
{
    UIFont * font = [UIFont fontWithName:kLobsterFont size:MAX_FONT_SIZE];
    FastAttributedString * string = [captionInfo objectForKey:kCaption];
    if ((id)string != [NSNull null]) {
        self.captionLabel.text = string.originalString;
        
        int fontSize = MAX_FONT_SIZE;
        [CaptionTagsParser findOptimalFontSize:string.originalString fontSizeRef:&fontSize font:font];
        
        self.captionLabel.font = [font fontWithSize:fontSize];
        [self.captionLabel setTextColor:[UIColor whiteColor]];
    }
    else
    {
        self.captionLabel.text = nil;
    }
    
}
@end
