//
//  ApiGetFollowers.h
//  Phostock
//
//  Created by Roman Truba on 11.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiMethod.h"

@interface ApiGetFollowers : ApiMethod
{
    void (^onFollowersComplete)(NSArray* usersArray);
    
    @public
    int followers_back_count, following_count, followers_count;
}
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * filter;
@property (nonatomic, assign) int offset;

-(void)startForUsers:(void (^)(NSArray* usersArray))onComplete;
@end
