//
//  UISearchBarTextField+ClearButton.m
//  Phostock
//
//  Created by Roman Truba on 26.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "SearchTextField.h"

@implementation SearchTextField
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    self.background = [self.background stretchableImageWithLeftCapWidth:15 topCapHeight:0];
}
- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width - 33, 1, 30, 30);
}
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(30, 0, bounds.size.width - 40, bounds.size.height);
}
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(30, 0, bounds.size.width - 40, bounds.size.height);
}
@end
