//
//  ApiFollowUser.m
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiFollowUser.h"

@implementation ApiFollowUser
@synthesize user_id;
-(NSDictionary*) getQueryParameters
{
    NSMutableDictionary * dict = (NSMutableDictionary*)[super getQueryParameters];
    if (user_id) dict[@"user_id"] = user_id;
    return dict;
}
-(NSString*) getMethodName
{
    return @"followUser";
}
-(NSString*) getHttpMethod
{
    return @"POST";
}
-(void) processResponse:(id) JSON
{
    if ([JSON valueForKey:@"response"])
        onSuccess(YES);
    else
        onSuccess(NO);
}

-(void) processError:(id) JSON error:(NSError*) error response:(NSHTTPURLResponse*)response
{
    onSuccess(NO);
}

@end
