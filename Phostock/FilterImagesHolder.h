//
//  FilterImagesHolder.h
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MASK_TAG           804
@interface FilterImagesHolder : NSObject
@property (nonatomic, strong) NSArray * filtersThumbs;
@property (nonatomic, strong) UIImageView * selectedFilterMask;

+(FilterImagesHolder *) getInstance;
-(GPUImageOutput<GPUImageInput> *) getFilterAtIndex:(int) index;
@end
