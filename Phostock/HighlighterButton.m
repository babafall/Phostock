//
//  HighlighterButton.m
//  Phostock
//
//  Created by Roman Truba on 07.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "HighlighterButton.h"

@implementation HighlighterButton

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    for (id view in self.viewsToHighlight)
    {
        if ([view respondsToSelector:@selector(setHighlighted:)])
            [view setHighlighted:highlighted];
    }
}

@end
