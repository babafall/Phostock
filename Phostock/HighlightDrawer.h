//
//  HighlightDrawer.h
//  Phostock
//
//  Created by Roman Truba on 09.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighlightDrawer : UIView
{
    NSMutableArray * images;
    NSMutableArray * rects;
}

-(void) addImage:(UIImage*) image drawInRect:(CGRect) rect;
@end
