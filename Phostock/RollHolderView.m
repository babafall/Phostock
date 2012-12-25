//
//  RollHolderView.m
//  Phostock
//
//  Created by Roman Truba on 11.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "RollHolderView.h"

@implementation RollHolderView

-(void)activateTop
{
    self.buttonTop.hidden = NO;
    self.buttonBottom.hidden = YES;
    
    self.rollView.frame = RectSetY(self.rollView.frame, 46);
}
-(void)activateBottom
{
    self.buttonTop.hidden = YES;
    self.buttonBottom.hidden = NO;
    
    self.rollView.frame = RectSetY(self.rollView.frame, 0);
}

@end
