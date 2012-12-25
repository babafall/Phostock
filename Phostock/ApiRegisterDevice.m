//
//  ApiRegisterDevice.m
//  Phostock
//
//  Created by Roman Truba on 07.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiRegisterDevice.h"

@implementation ApiRegisterDevice

-(NSDictionary*) getQueryParameters
{
    NSMutableDictionary * dict = (NSMutableDictionary*)[super getQueryParameters];
    
    dict[@"token_type"] = @"apns";
#ifdef DEBUG
    dict[@"app_sandbox"] = @"1";
#endif
    if (self.token) dict[@"token"] = self.token;
    return dict;
}
-(NSString*) getMethodName
{
    return @"registerDevice";
}

-(void) processResponse:(id) JSON
{
    if (onSuccess)
        onSuccess(YES);
}

-(void) processError:(id) JSON error:(NSError*) error response:(NSHTTPURLResponse*)response
{
    if (onSuccess)
        onSuccess(NO);
}
@end
