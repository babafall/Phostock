//
//  HeaderMovePannel.m
//  Phostock
//
//  Created by Roman Truba on 08.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "HeaderMovePannel.h"

@implementation HeaderMovePannel
-(void)awakeFromNib
{
    visible = NO;
}
-(void) move:(BOOL) down
{
    CGRect pr = self.movePannel.frame;
    float targetAlpha = 0;
    if (down) {
        self.movePannel.frame = RectSetY(pr, -RectHeight(pr));
        pr = RectSetY(pr, 0);
        self.alpha = 0;
        targetAlpha = 1;
    }
    else
    {
        self.movePannel.frame = RectSetY(pr, 0);
        pr = RectSetY(pr, -RectHeight(pr));
        self.alpha = 1;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.movePannel.frame = pr;
        self.alpha = targetAlpha;
    } completion:^(BOOL finished) {
        if (!down) [self removeFromSuperview];

    }];
}

-(void)show
{
    [self move:YES];
}

-(void)hide
{
    [self move:NO];
}
-(BOOL)toggle
{
    visible = !visible;
    [self move:visible];
    return visible;
}
@end
