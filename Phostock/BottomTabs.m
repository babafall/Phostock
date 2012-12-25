//
//  BottomTabs.m
//  Phostock
//
//  Created by Roman Truba on 28.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "BottomTabs.h"

@implementation BottomTabs
-(TabButton *)buttonAtIndex:(int)index
{
    return self.buttons[index];
}
-(void)selectButtonAtIndex:(int)index
{
    [self unselectAll];
    [[self.buttons objectAtIndex:index] setSelected:YES];
    [[self.highlights objectAtIndex:index] setHidden:NO];
}
-(void)unselectAll
{
    for (int i = 0; i < self.buttons.count; i++)
    {
        [[self.buttons objectAtIndex:i] setSelected:NO];
        [[self.highlights objectAtIndex:i] setHidden:YES];
    }
}
-(int)indexOfButton:(id)button
{
    return [self.buttons indexOfObject:button];
}
@end
