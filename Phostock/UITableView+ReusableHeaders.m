//
//  UITableView+ReusableHeaders.m
//  Phostock
//
//  Created by Roman Truba on 27.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//
#import <objc/runtime.h>
#import "UITableView+ReusableHeaders.h"

static char reusableKey;

@implementation UITableView (ReusableHeaders)

- (NSMutableDictionary *)reusableHeaders
{
    return objc_getAssociatedObject(self, &reusableKey);
}

- (void)setReusableHeaders:(NSMutableDictionary *)array
{
    objc_setAssociatedObject(self, &reusableKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)registerHeader:(UIView *)header forReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self.reusableHeaders == nil)
    {
        self.reusableHeaders = [[NSMutableDictionary alloc] init];  //creates a storage dictionary if one doesn’t exist
    }
    
    NSMutableArray *arrayForIdentifier = [self.reusableHeaders objectForKey:reuseIdentifier];
    if (arrayForIdentifier == nil)
    {
        arrayForIdentifier = [[NSMutableArray alloc] init]; //creates an array to store views sharing a reuse identifier if one does not exist
        [self.reusableHeaders setObject:arrayForIdentifier forKey:reuseIdentifier];
    }
    
    [arrayForIdentifier addObject:header];
}
- (UIView *)reusableHeaderForReuseIdentifier:(NSString *)reuseIdentifier;
{
    
    NSArray *arrayOfViewsForIdentifier = [self.reusableHeaders objectForKey:reuseIdentifier];
    
    if (arrayOfViewsForIdentifier == nil)
    {
        return nil;  //We don’t have any of this kind!
    }
    
    NSInteger indexOfAvailableController = [arrayOfViewsForIdentifier indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        return  [obj superview] == nil;   //If my view doesn’t have a superview, it’s not on-screen.
    }];
    
    if (indexOfAvailableController != NSNotFound)
    {
        UIView *availableView = [arrayOfViewsForIdentifier objectAtIndex:indexOfAvailableController];
        return availableView;
    }
    
    return nil;
    
}
@end
