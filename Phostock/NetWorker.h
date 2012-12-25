//
//  NetWorker.h
//  Phostock
//
//  Created by Roman Truba on 25.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "PhotoResponse.h"
#import "ApiMethod.h"
#import "UploadingView.h"

static NSString * kNetWorkerErrorNotification       = @"kNetWorkerErrorNotification";
static NSString * kNetWorkerProgressNotification    = @"kNetWorkerProgressNotification";
static NSString * kNetWorkerCompleteNotification    = @"kNetWorkerCompleteNotification";
static NSString * kNetWorkerDidLoginNotification    = @"kNetWorkerDidLoginNotification";
static NSString * kSearchUserMentionNotification    = @"kSearchUserMentionNotification";
static NSString * kAccessTokenKey                   = @"kAccessTokenKey";
static NSString * kUsernameKey                      = @"kUsernameKey";
static NSString * kUserId                           = @"kUserId";
static NSString * kUserInfo                         = @"kUserInfo";
static NSString * kUserPhoto                        = @"kUserPhoto";
static NSString * kPhotoId                          = @"kPhotoId";
static NSString * kTimestamp                        = @"kTimestamp";
static NSString * kDateStr                          = @"kDateStr";
static NSString * kCaption                          = @"kCaption";
static NSString * kCaptionSize                      = @"kCaptionSize";
static NSString * kCaptionMini                      = @"kCaptionMini";
static NSString * kCaptionSizeMini                  = @"kCaptionSizeMini";

static NSString * kPhoto                            = @"kPhoto";
static NSString * kMinPhoto                         = @"kMinPhoto";
static NSString * kMaxPhoto                         = @"kMaxPhoto";
static NSString * kRawPhoto                         = @"kRawPhoto";
static NSString * kReplyPhoto                       = @"kReplyPhoto";
static NSString * kReplyId                          = @"kReplyId";
static NSString * kIsPublic                         = @"kIsPublic";

static NSString * kWillBeRemoved                    = @"kWillBeRemoved";
static NSString * kWillBeLoaded                     = @"kWillBeLoaded";

static NSString * kLobsterFont                      = @"Lobster 1.4";

static NSString * kNewsFeedVisible      = @"kNewsFeedVisible";
static NSString * kMentionsVisible      = @"kMentionsVisible";
static NSString * kNewsMostEarlyKey     = @"kNewsMostEarlyKey";
static NSString * kMentionsMostEarlyKey = @"kMentionsMostEarlyKey";
static NSString * kUserMentionedNotification    = @"kUserMentionedNotification";

static const int kLoginSuccessful         = 1001;
static const int kLoginUserExists         = 1002;
static const int kLoginConnectionFailed   = 1003;

#define MAX_FONT_SIZE 34
#define MIN_FONT_SIZE 15
#define MINI_FONT_SIZE 15
#define PHOTOS_PER_PAGE 21

@interface NetWorker : NSObject
{
    NSString * macHash;
    NSString * accessToken;
    AFHTTPClient *httpClient;
    
    AFJSONRequestOperation * lastSearchOperation;
    
    NSMutableArray * loadingMethods;
    NSMutableSet * knownUsers;
}
+(NetWorker*) sharedInstance;
+(void) setAccessToken:(NSString*)accessToken userName:(NSString*) username;

-(AFHTTPRequestOperation*) startMethodLoading:(ApiMethod*) method;
-(NSString*) getMacHash;
-(void) putUsers:(NSArray*) users;
-(NSSet*) getKnownUSers;
-(BOOL) loggedIn;
-(BOOL) uploadPhoto:(UIImage*)photo caption:(NSString*)caption replyId:(NSString*) replyId isPublic:(BOOL) isPublic uploadingView:(UploadingView*) progressView complete:(void(^)(NSDictionary * users, PhotoResponse * photos))onComplete;
-(BOOL) deletePhoto:(NSString*) photoId complete:(void(^)(BOOL success))onComplete;
-(void) getImageForUrl:(NSString*) imageUrl onComplete:(void(^)(UIImage * resultImage)) onComplete onFailed:(void(^)(NSError * resultImage)) onFailed;
-(void) logout;

@end
