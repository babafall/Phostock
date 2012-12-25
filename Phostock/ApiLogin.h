//
//  ApiLogin.h
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiMethod.h"

@interface ApiLogin : ApiMethod
{
    void(^completeBlock)(int);
}
@property (nonatomic, strong) NSString * login;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * api_id;
@property (nonatomic, strong) NSString * api_hash;

-(id) initWithLogin:(NSString*) uLogin;
-(void) start:(void(^)(int))completeBlock;

@end
