//
//  CustomProgressBar.h
//  Phostock
//
//  Created by Roman Truba on 28.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomProgressBar : UIView
{
    UIImageView * loaderBack;
    UIImageView * progress;
    
    UIImage * backImage, *progressImage;
    
}
@property (nonatomic, assign) int min;
@property (nonatomic, assign) int max;
@property (nonatomic, assign) int value;

-(id) initWithFrame:(CGRect) frame backgroundImage:(UIImage*) bgImage progressImage:(UIImage*) progressImage;
-(void) makeView:(CGRect) frame backgroundImage:(UIImage*) bgImage progressImage:(UIImage*) psImage;
-(void) setValue:(int)value animated:(BOOL)animated;
@end
