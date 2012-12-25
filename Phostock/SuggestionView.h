//
//  SuggestionView.h
//  Phostock
//
//  Created by Roman Truba on 08.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SuggestionsDelegate <NSObject>

-(void) suggestionSelected:(NSString*) suggestion;

@end

@interface SuggestionView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    NSArray * suggestionArray;
    UIFont * font;
}
@property (nonatomic, strong) IBOutlet UITableView * suggestionTable;
@property (nonatomic, unsafe_unretained) id<SuggestionsDelegate> delegate;

-(void) filterSuggestions:(NSString*) filter;
@end
