//
//  LoginTextField.m
//  Phostock
//
//  Created by Roman Truba on 25.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "LoginTextField.h"
static int marginLeft = 110;
@implementation LoginTextField
- (void)awakeFromNib
{
    self.background = [self.background stretchableImageWithLeftCapWidth:20 topCapHeight:0];
}
- (CGRect)textRectForBounds:(CGRect)bounds {
    
    return CGRectMake(marginLeft, 0, bounds.size.width - marginLeft - 20, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    return CGRectMake(marginLeft, 0, bounds.size.width - marginLeft - 20, bounds.size.height);
}

@end
