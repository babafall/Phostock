//
//  ApiBlockUser.h
//  Phostock
//
//  Created by Roman Truba on 08.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiMethod.h"

@interface ApiBlockUser : ApiMethod
@property (nonatomic, strong) NSString * userId;
@end

@interface ApiUnblockUser : ApiBlockUser

@end
