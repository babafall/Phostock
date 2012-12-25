//
//  SubviewingButton.m
//  Phostock
//
//  Created by Roman Truba on 11.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "SubviewingButton.h"

@implementation SubviewingButton

-(void)awakeFromNib
{
    for (UIView * v in self.viewsToSubview)
    {
        v.frame = RectSetX(v.frame, RectX(v.frame) - RectX(self.frame));
        [self addSubview:v];
    }
}
-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    for (id v in self.viewsToSubview)
    {
        if ([v respondsToSelector:@selector(setHighlighted:)])
        {
            [v setHighlighted:highlighted];
        }
    }
}
@end
