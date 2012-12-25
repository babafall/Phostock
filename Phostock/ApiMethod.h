//
//  ApiMethod.h
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface ApiMethod : NSObject
{
    void(^onSuccess)(BOOL);
    AFHTTPRequestOperation * operation;
}
-(NSDictionary*) getQueryParameters;
-(NSString*) getMethodName;
-(NSString*) getHttpMethod;

-(void) start;
-(void) start:(void(^)(BOOL success))onComplete;
-(void) processResponse:(id) JSON;
-(void) processError:(id) JSON error:(NSError*) error response:(NSHTTPURLResponse*)response;
-(void) progressPerform:(long long) bytesComplete expected:(long long) bytesTotal;
-(void) stop;
-(void) clean;
@end
