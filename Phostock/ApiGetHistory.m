//
//  ApiGetHistory.m
//  Phostock
//
//  Created by Roman Truba on 09.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiGetHistory.h"

@implementation ApiGetHistory
-(NSDictionary *)getQueryParameters
{
    NSMutableDictionary * data = (NSMutableDictionary *)[super getQueryParameters];
    if (self.photoId) data[@"id"] = self.photoId;
    return data;
}
-(NSString *)getMethodName
{
    return @"getHistory";
}
-(void)processResponse:(id)JSON
{
    self.complete = ![[[JSON objectForKey:@"response"] objectForKey:@"incomplete"] boolValue];
    [super processResponse:JSON];
}
@end
