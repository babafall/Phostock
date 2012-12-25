//
//  PassingView.m
//  Phostock
//
//  Created by Roman Truba on 30.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "PassingView.h"

@implementation PassingView
@synthesize nextView;
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [nextView touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [nextView touchesMoved:touches withEvent:event];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [nextView touchesCancelled:touches withEvent:event];

}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [nextView touchesEnded:touches withEvent:event];
}

@end
