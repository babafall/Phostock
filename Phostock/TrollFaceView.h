//
//  TrollFaceView.h
//  Phostock
//
//  Created by Roman Truba on 06.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TrollFaceDelegate <NSObject>


@end

@interface TrollFaceView : UIView
{
    UIButton * lastInteractObject;
    CGFloat lastDragScale, currentDragScale, currentRotation, lastRotation, dragMirrored;
    BOOL canDragImage;
}
@property (nonatomic, unsafe_unretained) id delegate;
@end
