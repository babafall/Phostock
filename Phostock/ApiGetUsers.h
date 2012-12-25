//
//  GetUsers.h
//  Phostock
//
//  Created by Roman Truba on 26.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiMethod.h"

@interface ApiGetUsers : ApiMethod
{
    void(^onComplete)(NSDictionary * usersDictionary);
}
@property (nonatomic, strong) NSArray * users;

-(void) start:(void(^)(NSDictionary * usersDictionary))onComplete;
@end
