//
//  AllPhotosController.h
//  Phostock
//
//  Created by Roman Truba on 28.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkMainViewController.h"

@interface AllPhotosController : NetworkMainViewController
{
    CGFloat lastOffset;
    BOOL searchBarHidden;
}

@end
