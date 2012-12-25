//
//  MegafonView.h
//  Phostock
//
//  Created by Roman Truba on 09.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MegafonView : UIView
{
    BOOL selected;
}

@property (nonatomic, strong) IBOutlet UIImageView * background;
@property (nonatomic, strong) IBOutlet UIButton * megafon;

-(BOOL) isSelected;

@end
