//
//  SubviewingButton.h
//  Phostock
//
//  Created by Roman Truba on 11.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubviewingButton : UIButton
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray * viewsToSubview;
@end
