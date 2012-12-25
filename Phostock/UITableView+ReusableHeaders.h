//
//  UITableView+ReusableHeaders.h
//  Phostock
//
//  Created by Roman Truba on 27.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (ReusableHeaders)
@property (strong, nonatomic)  NSMutableDictionary * reusableHeaders;

- (void)registerHeader:(UIView *)header forReuseIdentifier:(NSString *)reuseIdentifier;
- (UIView *)reusableHeaderForReuseIdentifier:(NSString *)reuseIdentifier;
@end
