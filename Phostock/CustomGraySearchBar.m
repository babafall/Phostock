//
//  CustomGraySearchBar.m
//  Phostock
//
//  Created by Roman Truba on 26.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "CustomGraySearchBar.h"

static int margin = 8;
@implementation CustomGraySearchBar
@synthesize cancelButton, textInput, background;
-(void)awakeFromNib
{
    UIImage * cancelNormal = [[cancelButton backgroundImageForState:UIControlStateNormal] stretchableImageWithLeftCapWidth:8 topCapHeight:0],
            * cancelHigh   = [[cancelButton backgroundImageForState:UIControlStateHighlighted] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
    
    [cancelButton setBackgroundImage:cancelNormal forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:cancelHigh forState:UIControlStateHighlighted];
    
    cancelButton.alpha = 0;
    
    textInput.frame = CGRectMake(margin, 6, 320 - margin*2, 32);
    [textInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateAppear];
    
    if (textInput.text.length == 0 && [self.delegate respondsToSelector:@selector(searchBarDidBeginEditing:textField:)])
    {
        [self.delegate searchBarDidBeginEditing:self textField:textField];
    }
}
-(void)textFieldDidChange:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)])
    {
        [self.delegate searchBar:self textDidChange:textInput.text];
    }
}
-(void) animateAppear {
    [UIView animateWithDuration:0.3 animations:^{
        textInput.frame = CGRectMake(margin, 6, 320 - margin*3 - cancelButton.frame.size.width, 32);
        cancelButton.alpha = 1;
    }];
}

-(IBAction) cancelButtonClicked:(id)sender
{
    textInput.text = @"";
    [textInput resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        textInput.frame = CGRectMake(margin, 6, 320 - margin*2, 32);
        cancelButton.alpha = 0;
    } completion:^(BOOL finished) {
        [textInput resignFirstResponder];
    }];
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)])
    {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}
-(void) setText:(NSString*) text
{
    self.textInput.text = text;
    if (text.length && cancelButton.alpha == 0)
    {
        [self animateAppear];
    }
}
@end
