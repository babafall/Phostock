//
//  ApiUpdateUserpic.m
//  Phostock
//
//  Created by Roman Truba on 11.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiUpdateUserpic.h"

@implementation ApiUpdateUserpic
-(NSDictionary*) getQueryParameters
{
    NSMutableDictionary * params = [@{} mutableCopy];
    if (self.photoId) params[@"id"] = self.photoId;
    return params;
}
-(NSString*) getMethodName
{
    return @"updateUserpic";
}
-(NSString*) getHttpMethod
{
    return @"GET";
}

@end
