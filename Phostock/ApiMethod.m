//
//  ApiMethod.m
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiMethod.h"
#import "NetWorker.h"
@implementation ApiMethod

-(NSDictionary*) getQueryParameters
{
    return [@{} mutableCopy];
}
-(NSString*) getMethodName
{
    NSAssert(false, @"This method shoul be implemented");
    return nil;
}
-(NSString*) getHttpMethod
{
    return @"GET";
}
-(void) start
{
    operation = [[NetWorker sharedInstance] startMethodLoading:self];
}
-(void)start:(void (^)(BOOL))onComplete
{
    self->onSuccess = onComplete;
    [self start];
}
-(void) processResponse:(id) JSON
{
    if (onSuccess) onSuccess(YES);
}
-(void) processError:(id) JSON error:(NSError*) error response:(NSHTTPURLResponse*)response
{
    if (onSuccess) onSuccess(NO);
}
-(void) progressPerform:(long long) bytesComplete expected:(long long) bytesTotal
{
    
}
-(void) stop
{
    [operation cancel];
}
-(void)clean
{
    self->onSuccess = nil;
}
@end
