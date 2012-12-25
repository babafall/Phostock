//
//  BlackLettersLabel.m
//  Phostock
//
//  Created by Roman Truba on 04.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "BlackLettersLabel.h"

@implementation BlackLettersLabel
@synthesize isBorderOn;
- (void)drawTextInRect:(CGRect)rect {
    
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();

    if (isBorderOn) {
        CGContextSetLineWidth(c, 2);
        CGContextSetLineJoin(c, kCGLineJoinRound);
        CGContextSetTextDrawingMode(c, kCGTextStroke);
        self.textColor = [UIColor blackColor];
        [super drawTextInRect:rect];
    }
         
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
}

@end
