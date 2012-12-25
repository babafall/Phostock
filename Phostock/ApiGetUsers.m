//
//  GetUsers.m
//  Phostock
//
//  Created by Roman Truba on 26.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiGetUsers.h"

static NSMutableDictionary * sharedUsersInfo = nil;
@implementation ApiGetUsers
+(NSMutableDictionary*) getUsersInfo
{
    if (!sharedUsersInfo) sharedUsersInfo = [NSMutableDictionary new];
    return sharedUsersInfo;
}
-(NSDictionary*) getQueryParameters
{
    NSMutableDictionary * dict = (NSMutableDictionary *)[super getQueryParameters];
    if (self.users) dict[@"id"] = [self.users componentsJoinedByString:@","];
    return dict;
}
-(NSString*) getMethodName
{
    return @"getUsers";
}
-(void) start:(void (^)(NSDictionary *))completeBlock
{
    self->onComplete = completeBlock;
    [self start];
}
-(void) processResponse:(id) JSON
{
    NSDictionary * body = [JSON objectForKey:@"response"];
    if (!body)
    {
        return;
    }
    NSMutableDictionary * shared = [ApiGetUsers getUsersInfo];
    for (NSDictionary * userInfo in [body objectForKey:@"users_info"])
    {
        [shared setObject:[userInfo mutableCopy] forKey:[userInfo objectForKey:@"user"]];
    }
    for (NSDictionary * userInfo in [body objectForKey:@"users"])
    {
        NSString * uid = [userInfo objectForKey:@"id"], * login = [userInfo objectForKey:@"login"];
        NSMutableDictionary * object = [shared objectForKey:uid];
        [object setObject:login forKey:@"login"];
        
        NSDictionary * photo = [userInfo objectForKey:@"photo"];
        if (photo)
        {
            [object setObject:[photo objectForKey:@"id"] forKey:kPhotoId];
        }
        [shared setObject:object forKey:login];
    }
    onComplete(shared);
}
-(void) processError:(id) JSON error:(NSError*) error response:(NSHTTPURLResponse*)response
{
    
}
-(void)clean
{
    self->onComplete = nil;
}
@end
