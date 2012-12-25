//
//  FreeHandLabel.m
//  Phostock
//
//  Created by Roman Truba on 04.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "FreeHandLabel.h"

@implementation FreeHandLabel

-(void)awakeFromNib
{
    UIFont * pictoFont = [UIFont fontWithName:@"FreeHand521 BT" size:self.font.pointSize];
    [self setFont:pictoFont];
}


@end
