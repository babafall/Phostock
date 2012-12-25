//
//  HighlighterButton.h
//  Phostock
//
//  Created by Roman Truba on 07.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighlighterButton : UIButton

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray * viewsToHighlight;

@end
