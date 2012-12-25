//
//  ApiBlockUser.m
//  Phostock
//
//  Created by Roman Truba on 08.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiBlockUser.h"

@implementation ApiBlockUser
-(NSDictionary*) getQueryParameters
{
    NSMutableDictionary * data = [NSMutableDictionary new];
    if (self.userId) data[@"id"] = self.userId;
    return data;
}
-(NSString*) getMethodName
{
    return @"blockUser";
}
-(NSString*) getHttpMethod
{
    return @"POST";
}

@end

@implementation ApiUnblockUser

-(NSString*) getMethodName
{
    return @"unblockUser";
}

@end