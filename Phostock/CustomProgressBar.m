//
//  CustomProgressBar.m
//  Phostock
//
//  Created by Roman Truba on 28.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "CustomProgressBar.h"

@implementation CustomProgressBar
@synthesize value = _value;
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self makeView:frame backgroundImage:[UIImage imageNamed:@"Uploading_2"]
                               progressImage:[UIImage imageNamed:@"UploadingProgress_2"]];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self makeView:self.frame backgroundImage:[UIImage imageNamed:@"Uploading_2"] progressImage:[UIImage imageNamed:@"UploadingProgress_2"]];
    }
    return self;
}
-(id) initWithFrame:(CGRect) frame backgroundImage:(UIImage*) bgImage progressImage:(UIImage*) psImage;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self makeView:frame backgroundImage:bgImage progressImage:psImage];
    }
    return self;
}
-(void) makeView:(CGRect) frame backgroundImage:(UIImage*) bgImage progressImage:(UIImage*) psImage
{
    for (UIView * v in self.subviews) [v removeFromSuperview];
    self.backgroundColor = [UIColor clearColor];
    frame = RectSetOrigin(frame, 0, 0);
    backImage = bgImage;
    frame.size.height = backImage.size.height;
    loaderBack = [[UIImageView alloc] initWithFrame:frame];
    loaderBack.image = [backImage stretchableImageWithLeftCapWidth:floor(backImage.size.width / 2) topCapHeight:0];
    [self addSubview:loaderBack];
    
    progressImage = psImage;
    progress = [[UIImageView alloc] initWithFrame:CGRectMake(0, backImage.size.height - progressImage.size.height,
                                                             progressImage.size.width, progressImage.size.height)];
    progress.image = [progressImage stretchableImageWithLeftCapWidth:floor(progressImage.size.width / 2) topCapHeight:0];
    [self addSubview:progress];
    self.min = 0;
    self.max = 100;
    self.value = 0;

}
-(void)setValue:(int)value
{
    [self setValue:value animated:YES];
}
-(void)setValue:(int)value animated:(BOOL)animated
{
    _value = value;
    CGFloat w = ((float)value / (self.max - self.min)) * RectWidth(loaderBack.frame);
    if (w < progressImage.size.width) w = progressImage.size.width;
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        progress.frame = RectSetWidth(progress.frame, w);
    }];
    
}
@end
