//
//  TabButton.h
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NetworkTabbedController;
@interface BadgeLabel : UIView
@property (nonatomic, strong) UILabel * valueLabel;
@property (nonatomic, strong) UIImageView * backgroundImage;

-(void)setValue:(int)value;
@end

@interface TabButton : UIButton
{
    UIImageView * selectImageView;
}
@property (nonatomic, unsafe_unretained) NetworkTabbedController * parentController;
@property (nonatomic, assign) BOOL isVisible;

-(void) setBadgeValue:(int)value;

@end
