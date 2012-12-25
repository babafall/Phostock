//
//  CustomGraySearchBar.h
//  Phostock
//
//  Created by Roman Truba on 26.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchTextField.h"

@class CustomGraySearchBar;
@protocol CustomSearchBarDelegate <NSObject>
@optional
-(void)searchBar:(CustomGraySearchBar *)searchBar textDidChange:(NSString *)searchText;
-(void)searchBarDidBeginEditing:(CustomGraySearchBar *) searchBar textField:(UITextField*)field;
-(void)searchBarCancelButtonClicked:(CustomGraySearchBar *) searchBar;

@end

@interface CustomGraySearchBar : UIView <UITextFieldDelegate>
{
    
    IBOutlet UIImageView        * background;
    IBOutlet UIButton           * cancelButton;
    IBOutlet SearchTextField    * textInput;
}

@property (nonatomic, unsafe_unretained) IBOutlet id<CustomSearchBarDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIImageView        * background;
@property (nonatomic, strong) IBOutlet UIButton           * cancelButton;
@property (nonatomic, strong) IBOutlet SearchTextField    * textInput;

-(void) setText:(NSString*) text;
@end
