//
//  BottomTabs.h
//  Phostock
//
//  Created by Roman Truba on 28.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TabButton;
@interface BottomTabs : UIView

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray * buttons;
@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray * highlights;

-(int) indexOfButton:(id) button;
-(TabButton*) buttonAtIndex:(int) index;
-(void) selectButtonAtIndex:(int) index;
-(void) unselectAll;
@end
