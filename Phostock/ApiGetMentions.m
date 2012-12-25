//
//  ApiGetMentions.m
//  Phostock
//
//  Created by Roman Truba on 19.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiGetMentions.h"

@implementation ApiGetMentions
-(NSString*) getMethodName
{
    return @"getMentions";
}
-(NSString*) arrayKey
{
    return @"feedback";
}
@end
