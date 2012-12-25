//
//  FilterImagesHolder.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "FilterImagesHolder.h"
#import "BaseController.h"
#import "StandardFilters.h"
static FilterImagesHolder * instance = nil;
static int FILTERS_TOTAL_COUNT = 16;
@implementation FilterImagesHolder
@synthesize filtersThumbs, selectedFilterMask;
-(id)init
{
    NSAssert(instance == nil, @"Can be only one object instance");
    if (self = [super init])
    {
        instance = self;
        [instance createFiltersThumb];
        
    }
    return self;
}
+(FilterImagesHolder *)getInstance
{
    if (!instance)
    {
        instance = [[FilterImagesHolder alloc] init];
    }
    return instance;
}
-(void) createFiltersThumb
{
    NSMutableArray * temp = [NSMutableArray new];
    [temp addObject:[BaseController cropToMask:[UIImage imageNamed:@"nofilter"] targetSize:CGSizeMake(130, 132)]];
    for (int i = 0; i < FILTERS_TOTAL_COUNT; i++)
    {
        UIImage * img = [UIImage imageNamed:[NSString stringWithFormat:@"filter%d", (i % FILTERS_TOTAL_COUNT) + 1]];
        [temp addObject:[BaseController cropToMask:img targetSize:CGSizeMake(130, 132)]];
    }
    filtersThumbs = temp;
    
    selectedFilterMask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FilterMask_Active"]];
    CGRect fr = selectedFilterMask.frame;
    selectedFilterMask.frame = CGRectMake(1, 0, fr.size.width, fr.size.height);
    selectedFilterMask.tag = MASK_TAG;
}
-(GPUImageOutput<GPUImageInput> *) getFilterAtIndex:(int) index
{
    GPUImageOutput<GPUImageInput> * filter;
    switch (index) {
        case 1:
            filter = [[StandardFilter1 alloc] init];
            break;
        case 2:
            filter = [[StandardFilter2 alloc] init];
            break;
        case 3:
            filter = [[StandardFilter3 alloc] init];
            break;
        case 4:
            filter = [[StandardFilter4 alloc] init];
            break;
        case 5:
            filter = [[StandardFilter5 alloc] init];
            break;
        case 6:
            filter = [[StandardFilter6 alloc] init];
            break;
        case 7:
            filter = [[StandardFilter7 alloc] init];
            break;
        case 8:
            filter = [[StandardFilter8 alloc] init];
            break;
        case 9:
            filter = [[EightBitsFilter alloc] init];
            break;
        case 10:
            filter = [[UfoFilter alloc] init];
            break;
        case 11:
            filter = [[TrasholdFilter alloc] init];
            break;
        case 12:
            filter = [[VinnyFilter alloc] init];
            break;
        case 13:
            filter = [[PenSketchFilter alloc] init];
            break;
        case 14:
            filter = [[FishEyeFilter alloc] init];
            break;
        case 15:
            filter = [[EdgeeFilter alloc] init];
            break;
        case 16:
            filter = [[MakeMeTallFilter alloc] init];
            break;
        default:
            filter = [[GPUImageBrightnessFilter alloc] init];
            [filter prepareForImageCapture];
            break;
    }
    return filter;
}
@end
