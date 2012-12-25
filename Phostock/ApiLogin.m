//
//  ApiLogin.m
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiLogin.h"

@implementation ApiLogin
@synthesize login, password, api_hash, api_id;
-(id) initWithLogin:(NSString*) uLogin
{
    self = [super init];
    if (self)
    {
        self.login = uLogin;
        self.password = [[NetWorker sharedInstance] getMacHash];
        self.api_id = @"10";
        self.api_hash = @"26768aec2f79ca8d4c";
    }
    return self;
}
-(NSDictionary*) getQueryParameters
{
    NSMutableDictionary * dict = [NSMutableDictionary new];
    if (login)      [dict setObject:login       forKey:@"login"];
    if (password)   [dict setObject:password    forKey:@"password"];
    if (api_hash)   [dict setObject:api_hash    forKey:@"api_hash"];
    if (api_id)     [dict setObject:api_id      forKey:@"api_id"];
    return dict;
}
-(NSString*) getMethodName
{
    return @"login";
}
-(void) processResponse:(id) JSON
{
    NSDictionary * responseJson = [JSON objectForKey:@"response"];
    NSString * accessToken = [[responseJson objectForKey:@"credentials"] objectForKey:@"access_token"];
    //Если успешно залогинились - сохраним токен в дефолты (для посл. использования) и отправим уведомление
    [NetWorker setAccessToken:accessToken userName:login];
    completeBlock(kLoginSuccessful);
}
-(void) processError:(id) JSON error:(NSError*) error response:(NSHTTPURLResponse*)response
{
    if (response.statusCode == 400)
    {
        completeBlock(kLoginUserExists);
    }
    else if (error){
        completeBlock(kLoginConnectionFailed);
    }
}
-(void)start:(void (^)(int returnCode))cBlock
{
    self->completeBlock = cBlock;
    [self start];
}
-(void)clean
{
    self->completeBlock = nil;
}
@end
