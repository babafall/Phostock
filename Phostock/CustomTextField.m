//
//  CustomTextField.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField
- (void)awakeFromNib
{
    self.background = [self.background stretchableImageWithLeftCapWidth:15 topCapHeight:0];
}
- (CGRect)textRectForBounds:(CGRect)bounds {
    
    return CGRectInset( bounds , 8 , 8 );
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    return CGRectInset( bounds , 8 , 5 );
}

-(void) nilSelection
{
//    _selectionRange.location = _selectionRange.location + _selectionRange.length;
//    _selectionRange.length = 0;
}
@end
