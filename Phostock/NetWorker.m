//
//  NetWorker.m
//  Phostock
//
//  Created by Roman Truba on 25.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "NetWorker.h"
#import "IPAddress.h"
#import "NSString+MD5.h"
#import "PhotoResponse.h"
#import "SDURLCache.h"
#import "UIImageView+AFNetworking.h"
#import "UIFastLabel.h"
#import "CaptionTagsParser.h"
#import "UIImageView+AFNetworking.h"
static NetWorker * sharedNetworkerInstance;
@implementation NetWorker
+(NetWorker *)sharedInstance
{
    if (!sharedNetworkerInstance) sharedNetworkerInstance = [NetWorker new];
    return sharedNetworkerInstance;
}
+(void) setAccessToken:(NSString*)accessToken userName:(NSString*) username
{
    self.sharedInstance->accessToken = accessToken;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:kAccessTokenKey];
    [defaults setObject:username forKey:@"kUsernameKey"];
    [defaults synchronize];
}
-(id) init
{
    self = [super init];
    if (self)
    {
        NSURL *url = [NSURL URLWithString:@"https://api.airshipdock.com/1/"];
        httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        
        accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:kAccessTokenKey];
//        NSLog(@"accessToken: %@", accessToken );
        
        //Cache
        SDURLCache *URLCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024*2 diskCapacity:1024*1024*200 diskPath:[SDURLCache defaultCachePath]];
        [URLCache setIgnoreMemoryOnlyStoragePolicy:YES];
        [NSURLCache setSharedURLCache:URLCache];
    }
    return self;
}
-(AFHTTPRequestOperation*) startMethodLoading:(ApiMethod*) method
{
    if (!loadingMethods) loadingMethods = [NSMutableArray new];
    [loadingMethods addObject:method];
    NSMutableDictionary * params = (NSMutableDictionary *)[method getQueryParameters];
    if (params && accessToken) [params setObject:accessToken forKey:@"access_token"];
    NSMutableURLRequest *request = [httpClient requestWithMethod:[method getHttpMethod] path:[method getMethodName] parameters:params];
    NSLog(@"Request: %@", request);
    return [self performJsonOperation:request processBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (response.statusCode == 200)
        {
            [method processResponse:JSON];
        }
        else
        {
            [method processError:JSON error:error response:response];
        }
        [method clean];
    } progressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        [method progressPerform:totalBytesWritten expected:totalBytesExpectedToWrite];
    }];
}

-(void)putUsers:(NSArray *)users
{
    if (!knownUsers) knownUsers = [NSMutableSet new];
    [knownUsers addObjectsFromArray:users];
}
-(NSSet *)getKnownUSers
{
    return knownUsers;
}

-(BOOL) loggedIn
{
    return accessToken != nil;
}
-(void) logout
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:kAccessTokenKey];
    NSString * token = [defaults objectForKey:@"pushToken"];
    [defaults setObject:nil forKey:@"pushToken"];
    [defaults synchronize];
    
    ApiUnregisterDevice * ureg = [[ApiUnregisterDevice alloc] init];
    ureg.token = token;
    [ureg start];
}
-(NSString*) getMacHash
{
    if (macHash) return macHash;
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        static unsigned long localHost = 0x7F000001;        // 127.0.0.1
        unsigned long theAddr;
        
        theAddr = ip_addrs[i];
        
        if (theAddr == 0) break;
        if (theAddr == localHost) continue;

        if (strcmp(ip_names[i], "127.0.0.1") == 0)
        {
            continue;
        }
        NSLog(@"%s", hw_addrs[i]);
        macHash = [[[NSString stringWithCString:hw_addrs[i] encoding:NSUTF8StringEncoding] uppercaseString] MD5Hash];
    }
    return macHash;
}

//Выполнение заданной операции по запросу
-(AFJSONRequestOperation *) performJsonOperation:(NSURLRequest*) request
                processBlock:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)) process
               progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressListener
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request , NSHTTPURLResponse *response, id JSON) {
                                                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                        process(request, response, nil, JSON);
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                        process(request, response, error, JSON);
                                                    }];
    if (progressListener)
    {
        [operation setUploadProgressBlock:progressListener];
        [operation setDownloadProgressBlock:progressListener];
    }
    
    
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [operation start];
    return operation;
}

-(BOOL) uploadPhoto:(UIImage*)photo caption:(NSString*)caption replyId:(NSString*) replyId isPublic:(BOOL) isPublic uploadingView:(UploadingView*) progressView complete:(void(^)(NSDictionary * users, PhotoResponse * photos))onComplete
{
    NSData *imageData = UIImageJPEGRepresentation(photo, 0.9);
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/uploadPhoto" parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        NSLog(@"Photo upload: caption --- %@\nreply: %@\nreply_to_feed: %@", caption, replyId, isPublic ? @"1" : @"0");
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
        [formData appendPartWithFormData:[caption dataUsingEncoding:NSUTF8StringEncoding] name:@"caption"];
        [formData appendPartWithFormData:[accessToken dataUsingEncoding:NSUTF8StringEncoding] name:@"access_token"];
        if (replyId)
        {
            [formData appendPartWithFormData:[replyId dataUsingEncoding:NSUTF8StringEncoding] name:@"reply_to"];
            if (isPublic)
                [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] name:@"reply_to_feed"];
        }
    }];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progressView.progressBar.value = (int)(1.0f * totalBytesWritten / totalBytesExpectedToWrite * 100);
    }];
    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         onComplete(nil, nil);
//         if (operation.response.statusCode == 200)
//         {
//             NSDictionary * jsonBody = [responseObject valueForKey:@"response"];
//             if (!jsonBody)
//             {
//                 onComplete(nil, nil);
//                 return;
//             }
//             
//         }
//         else {
//             onComplete(nil, nil);
//         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"error: %@",  operation.responseString);
         onComplete(nil, nil);
     }
     ];
    [progressView setOnCancelBlock:^{
        [operation cancel];
    }];
    [progressView setUploadingImage:photo];
    [operation start];
    return YES;
}
-(BOOL) deletePhoto:(NSString*) photoId complete:(void(^)(BOOL success))onComplete
{
    if (!accessToken) return NO;
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/deletePhotos"
                                                      parameters:@{@"id" : photoId, @"access_token" : accessToken }];
    
    AFJSONRequestOperation * operation = [self performJsonOperation:request processBlock:nil progressBlock:nil];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@", operation.responseString);
        if (operation.response.statusCode == 200)
        {
            onComplete(YES);
        }
        else {
            onComplete(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        onComplete(NO);
    }];
    return YES;
}

-(void) getImageForUrl:(NSString*) imageUrl onComplete:(void(^)(UIImage * resultImage)) onComplete onFailed:(void(^)(NSError * resultImage)) onFailed
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    UIImage *cachedImage = [[UIImageView af_sharedImageCache] cachedImageForURL:request.URL];
    if (cachedImage) {
        onComplete(cachedImage);
    } else {
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:request];
        [requestOperation setQueuePriority:NSOperationQueuePriorityLow];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[UIImageView af_sharedImageCache] setImage:responseObject forURL:request.URL];
            if (onComplete) {
                onComplete(responseObject);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (onFailed) {
                onFailed(error);
            }
            
        }];
    }
}
@end
