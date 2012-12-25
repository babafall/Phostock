//
//  StreachableImageButton.m
//  Phostock
//
//  Created by Roman Truba on 25.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "StreachableImageButton.h"

@implementation StreachableImageButton

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UIImage * img = [self backgroundImageForState:UIControlStateNormal],
        * hImg = [self backgroundImageForState:UIControlStateHighlighted],
        * sImg = [self backgroundImageForState:UIControlStateSelected];
        
        img = [img stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
        hImg = [hImg stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
        sImg = [sImg stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
        
        [self setBackgroundImage:img forState:UIControlStateNormal];
        [self setBackgroundImage:hImg forState:UIControlStateHighlighted];
        [self setBackgroundImage:hImg forState:UIControlStateSelected];

    }
    return self;
}

@end
