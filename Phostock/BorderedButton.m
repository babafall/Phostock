//
//  BorderedButton.m
//  Phostock
//
//  Created by Roman Truba on 05.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "BorderedButton.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Glow.h"
@implementation BorderedButton

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        [self startGlowing];
    }
    else
    {
        [self stopGlowing];
    }
}

@end
