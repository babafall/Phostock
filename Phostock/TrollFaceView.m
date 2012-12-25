//
//  TrollFaceView.m
//  Phostock
//
//  Created by Roman Truba on 06.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "TrollFaceView.h"

@implementation TrollFaceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setClipsToBounds:YES];
    if (self) {
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [self addGestureRecognizer:pinchGesture];
        
        UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
        [self addGestureRecognizer:rotateGesture];
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        [swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:rotateGesture];
        
        swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:rotateGesture];
        
        lastDragScale = currentDragScale = 1.0f;
        canDragImage = YES;
        
        lastInteractObject = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        [lastInteractObject setImage:[UIImage imageNamed:@"trollface"] forState:UIControlStateNormal];
        [lastInteractObject addTarget:self action:@selector(imageMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        lastInteractObject.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        
        [self addSubview:lastInteractObject];
    }
    return self;
}

#pragma mark ImagesMove
- (IBAction) imageMoved:(id) sender withEvent:(UIEvent *) event
{
    if ([[event allTouches] count] > 1) return;
    CGPoint point = [[[event allTouches] anyObject] locationInView:self];
    [self moveImageToPoint:point];
    
}
-(void) moveImageToPoint:(CGPoint) point
{
    if (!canDragImage) return;
    if (point.x < CGRectGetMinX(self.frame) - CGRectGetHeight(lastInteractObject.frame) / 4) point.x = CGRectGetMinX(self.frame) - CGRectGetWidth(lastInteractObject.frame) / 4;
    if (point.y < CGRectGetMinY(self.frame) - CGRectGetWidth(lastInteractObject.frame) / 4) point.y = CGRectGetMinY(self.frame) - CGRectGetHeight(lastInteractObject.frame) / 4;
    if (point.x > CGRectGetMaxX(self.frame) - CGRectGetWidth(lastInteractObject.frame) / 4) point.x = CGRectGetMaxX(self.frame) - CGRectGetWidth(lastInteractObject.frame) / 4;
    if (point.y > CGRectGetMaxY(self.frame) - CGRectGetHeight(lastInteractObject.frame) / 4) point.y = CGRectGetMaxY(self.frame) - CGRectGetHeight(lastInteractObject.frame) / 4;
    lastInteractObject.center = point;
    
    if ([self.delegate respondsToSelector:@selector(trollfaceViewChanged)])
    {
        //[self.delegate trollfaceViewChanged];
    }
    
}
-(void)handlePinch:(UIPinchGestureRecognizer*) gestureRecogniter
{
    CGSize size = self.frame.size;
    CGFloat nextScale = (currentDragScale + gestureRecogniter.scale - lastDragScale);
    if (size.width * nextScale > 100 && nextScale < 3)
    {
        currentDragScale += gestureRecogniter.scale - lastDragScale;
        lastDragScale = gestureRecogniter.scale;
    }
    if (gestureRecogniter.state == UIGestureRecognizerStateBegan)
    {
        canDragImage = NO;
    }
    if (gestureRecogniter.state == UIGestureRecognizerStateEnded)
    {
        canDragImage = YES;
        lastDragScale = 1;
    }
    [self makeDragTransform];
}
-(void)handleRotate:(UIRotationGestureRecognizer*) gestureRecogniter
{
//    NSLog(@"Rotate: %f", gestureRecogniter.rotation);
    currentRotation = gestureRecogniter.rotation + lastRotation;
    if (gestureRecogniter.state == UIGestureRecognizerStateEnded)
    {
        lastRotation = currentRotation;
    }
    
    [self makeDragTransform];
}
-(void)handleSwipe:(UISwipeGestureRecognizer*) gestureRecogniter
{
    dragMirrored = !dragMirrored;
    
    [self makeDragTransform];
}
-(void) makeDragTransform
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, (dragMirrored ? -1 : 1) * currentDragScale, currentDragScale);
    transform = CGAffineTransformRotate(transform, currentRotation);
    lastInteractObject.transform = transform;
    
    if ([self.delegate respondsToSelector:@selector(trollfaceViewChanged)])
    {
        //[self.delegate trollfaceViewChanged];
    }
}

@end
