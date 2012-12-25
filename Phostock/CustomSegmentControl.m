//
//  CustomSegmentControl.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "CustomSegmentControl.h"

@implementation CustomSegmentControl
@synthesize delegate, selectedIndex;
-(void)awakeFromNib
{
    [self initControl];
}

-(void) initControl
{
    int count = 1;
    for (UIView * buttonView in self.subviews) {
        UIButton * button = (UIButton*)buttonView;
        
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = count;
        
        UIImage * normalBg      = [button backgroundImageForState:UIControlStateNormal];
        UIImage * selectedBg    = [button backgroundImageForState:UIControlStateSelected];
        if (count == 1)
        {
            [button setBackgroundImage:[normalBg stretchableImageWithLeftCapWidth:14 topCapHeight:0] forState:UIControlStateNormal];
            [button setBackgroundImage:[selectedBg stretchableImageWithLeftCapWidth:14 topCapHeight:0] forState:UIControlStateSelected];
            [button setBackgroundImage:[selectedBg stretchableImageWithLeftCapWidth:14 topCapHeight:0] forState:UIControlStateHighlighted];
            
            [button setSelected:YES];
            lastSelected = button;
        }
        else if (count == self.subviews.count)
        {
            [button setBackgroundImage:[normalBg stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
            [button setBackgroundImage:[selectedBg stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateSelected];
            [button setBackgroundImage:[selectedBg stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateHighlighted];
        }
        else
        {
            [button setBackgroundImage:[normalBg stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateNormal];
            [button setBackgroundImage:[selectedBg stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateSelected];
            [button setBackgroundImage:[selectedBg stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateHighlighted];
        }
        
        button.titleLabel.font = [self fontForSegment:count-1];
        count++;
    }
    self.selectedIndex = 0;
}
-(UIFont*) fontForSegment:(int) segmentNum baseSize:(int)fontSize
{
    UIFont * buttonFont;
    switch (segmentNum) {
        case 0:
            buttonFont = [UIFont fontWithName:@"FreeHand521 BT" size:fontSize];
            break;
        case 1:
            buttonFont = [UIFont fontWithName:@"Ballpark" size:fontSize+3];
            break;
        case 2:
            buttonFont = [UIFont fontWithName:@"Lobster 1.4" size:fontSize];
            break;
        case 3:
            buttonFont = [UIFont fontWithName:@"CollegiateHeavyOutline" size:fontSize];
            break;
        case 4:
            buttonFont = [UIFont fontWithName:@"Complete in Him" size:fontSize+4];
            break;
        default:
            buttonFont = [UIFont systemFontOfSize:fontSize - 2];
            break;
    }
    return buttonFont;
}
-(UIFont*) fontForSegment:(int) segmentNum  {
    return [self fontForSegment:segmentNum baseSize:20];
}

-(void) buttonPressed:(id)sender
{
    [lastSelected setSelected:NO];
    [(UIButton*)sender setSelected:YES];
    lastSelected = (UIButton*)sender;
    self.selectedIndex = [self.subviews indexOfObject:sender];
    if ([self.delegate respondsToSelector:@selector(customSegmented:didSelectedSegment:)])
        [self.delegate customSegmented:self didSelectedSegment:self.selectedIndex];
}
-(void)dealloc
{
//    NSLog(@"Segment deallocated");
}
@end
