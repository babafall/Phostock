//
//  MegafonView.m
//  Phostock
//
//  Created by Roman Truba on 09.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "MegafonView.h"

@implementation MegafonView

-(void)awakeFromNib
{
    self.background.image = [self.background.image stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    self.background.highlightedImage = [self.background.highlightedImage stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicked:)];
    [self addGestureRecognizer:tap];

    selected = NO;
    [self setSelected:NO animated:NO];
    [self.megafon addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.megafon addTarget:self action:@selector(buttonDown) forControlEvents:UIControlEventTouchDown];
    [self.megafon addTarget:self action:@selector(buttonCanceled) forControlEvents:UIControlEventTouchUpOutside];
    [self.megafon addTarget:self action:@selector(buttonCanceled) forControlEvents:UIControlEventTouchCancel];
}
-(void) buttonDown
{
    [self setHighligted:!selected];
}
-(void) buttonCanceled
{
    [self setHighligted:selected];
}
-(void) buttonClicked
{
    [self setSelected:!selected];
}
-(void) clicked:(UITapGestureRecognizer*) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self setHighligted:!selected];
    }
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self setHighligted:!selected];
        [self setSelected:!selected];
    }
    if (sender.state == UIGestureRecognizerStateCancelled)
    {
        [self setHighligted:selected];
    }
}
-(void)setHighligted:(BOOL) value
{
    self.background.highlighted = value;
    self.megafon.selected = value;
}
-(void)setSelected:(BOOL) value
{
    [self setSelected:value animated:YES];
}
-(void)setSelected:(BOOL) value animated:(BOOL)animated
{
    selected = value;
    CGRect rect;
    if (selected)
    {
        rect = RectSetWidth(self.frame, 255);
    }
    else
    {
        rect = RectSetWidth(self.frame, 42);
    }
    self.megafon.selected = selected;
    [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
        self.frame = rect;
    }];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setHighligted:!selected];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setHighligted:selected];
}

-(BOOL)isSelected { return selected; }

@end
