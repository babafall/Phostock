//
//  CustomSegmentControl.h
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomSegmentControl;

@protocol CustomSegmentControlDelegate <NSObject>

@optional
-(void) customSegmented:(CustomSegmentControl*) control didSelectedSegment:(NSInteger) segment;

@end

@interface CustomSegmentControl : UIView
{
    UIButton * lastSelected;
}
@property (nonatomic, unsafe_unretained) IBOutlet id delegate;
@property (nonatomic, assign) int selectedIndex;
-(UIFont*) fontForSegment:(int) segmentNum;
-(UIFont*) fontForSegment:(int) segmentNum baseSize:(int)fontSize;
@end
