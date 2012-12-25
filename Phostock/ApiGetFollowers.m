//
//  ApiGetFollowers.m
//  Phostock
//
//  Created by Roman Truba on 11.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiGetFollowers.h"
#import "CaptionTagsParser.h"

@implementation ApiGetFollowers
-(NSDictionary*) getQueryParameters
{
    NSMutableDictionary * params = [@{} mutableCopy];
    if (self.userId) params[@"user_id"] = self.userId;
    if (self.filter) params[@"filter"] = self.filter;
    if (self.offset) params[@"offset"] = @(self.offset);
    
    return params;
}
-(NSString*) getMethodName
{
    return @"getFollowers";
}
-(NSString*) getHttpMethod
{
    return @"GET";
}
-(void)startForUsers:(void (^)(NSArray* usersArray))onComplete
{
    self->onFollowersComplete = onComplete;
    [self start];
}
-(void) processResponse:(id) JSON
{
    NSDictionary * response = [JSON objectForKey:@"response"];
    if (!response)
        if (onFollowersComplete) onFollowersComplete(nil);
    
    self->followers_back_count = [response[@"followed_back_count"] intValue];
    self->followers_count = [response[@"followers_count"] intValue];
    self->following_count = [response[@"following_count"] intValue];
    
    NSArray * rawList = [response objectForKey:@"list"];
    NSMutableArray * userList = [NSMutableArray arrayWithCapacity:rawList.count];
    for (NSDictionary * rawUser in rawList)
    {
        NSMutableDictionary * user = [rawUser[@"user"] mutableCopy];
        user[@"loginA"] = [CaptionTagsParser prepareCaptionTags:user[@"login"]];
        [userList addObject:user];
    }
    if (onFollowersComplete) onFollowersComplete(userList);
}
-(void) processError:(id) JSON error:(NSError*) error response:(NSHTTPURLResponse*)response
{
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self startForUsers:onFollowersComplete];
    });
}
-(void)clean
{
    self->onFollowersComplete = nil;
}
@end
