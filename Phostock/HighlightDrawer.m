//
//  HighlightDrawer.m
//  Phostock
//
//  Created by Roman Truba on 09.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "HighlightDrawer.h"

@implementation HighlightDrawer

-(void)addImage:(UIImage *)image drawInRect:(CGRect)rect
{
    if (!images)
    {
        images = [NSMutableArray new];
        rects  = [NSMutableArray new];
    }
    [images addObject:image];
    NSValue * rectVal = [NSValue value:&rect withObjCType:@encode(CGRect)];
    [rects addObject:rectVal];
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    for (int i = 0; i < images.count; i++)
    {
        UIImage * image = images[i];
        NSValue * rectVal = rects[i];
        
        CGRect rect;
        [rectVal getValue:&rect];
        
        [image drawInRect:rect];
        
    }
}

@end
