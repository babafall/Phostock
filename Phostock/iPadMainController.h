//
//  iPadMainController.h
//  Phostock
//
//  Created by Roman Truba on 21.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
enum FilterNum {
    Sepia = 0,
    Saturation,
    Contrast,
    Brightness,
    Hue,
    Exposure,
    Gamma,
    WhiteBalance,
    Highlights,
    Shadows,
    Luminance,
    Red,
    Green,
    Blue,
    VignetteStart,
    VignetteEnd,
    Grayscale,
    Pixelate,
    Prewit,
    Sketch,
    Emboss,
    Pinch
    
};

@interface FilterDef : NSObject
{
    @public
    NSString * filterName;
    BOOL active;
    int numSliders;
    int sliderStartTag;
    float sliderValue;
    GPUImageOutput * createdFilter;
    
    
}
+(FilterDef*) defWithName:(NSString*)name startTag:(int) tag sliders:(int) sliders andFilter:(GPUImageOutput*) filter;

@end

@interface iPadMainController : UISplitViewController <UITableViewDataSource, UITableViewDelegate>
{
    UIImage * basicImage;
    NSMutableArray * tableFiltersObjects;
    GPUImagePicture * gpuPicture;
    NSDictionary * filterByKey;
    
    int lastEnableFiltersCount;
    int curPhoto;
    
}
@property (nonatomic, strong) IBOutlet UITextView * logTextView;
@property (nonatomic, strong) IBOutlet UIImageView * testCaseImageView;
@property (nonatomic, strong) IBOutlet GPUImageView * gpuImageView;
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UINavigationController * navigationController;
@property (nonatomic, strong) IBOutlet UITableViewController * tableViewController;
@end
