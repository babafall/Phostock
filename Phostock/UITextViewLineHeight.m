//
//  UITextView+LineHeight.m
//  Phostock
//
//  Created by Roman Truba on 30.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "UITextViewLineHeight.h"

@interface UITextView ()

- (id)styleString;

@end


@implementation UITextViewLineHeight
-(void)awakeFromNib
{
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.layer.shadowOpacity = 1.0f;
    self.layer.shadowRadius = 1.0f;
    self.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}
- (id)styleString {
    return [[super styleString] stringByAppendingString:@"; line-height: 1.1em"];
}


@end
