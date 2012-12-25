//
//  ApiGetPhotos.m
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiGetPhotos.h"
#import "PhotosParser.h"
#import "CaptionTagsParser.h"
@implementation ApiGetPhotos
@synthesize user_id, offset, limit, highlight, userPics;
-(id) initWithUserId:(NSString*) userId
{
    self = [super init];
    if (self)
    {
        self.user_id = userId;
        self.userPics = NO;
    }
    return self;
}
-(NSDictionary*) getQueryParameters
{
    NSMutableDictionary * dict = [NSMutableDictionary new];
    if (user_id)      [dict setObject:user_id    forKey:@"user_id"];
    if (offset > 0)   [dict setObject:@(offset)  forKey:@"offset"];
    if (limit  > 0)   [dict setObject:@(limit)   forKey:@"limit"];
    if (userPics)     [dict setObject:@"userpic" forKey:@"filter"];
    return dict;
}
-(NSString*) getMethodName
{
    return @"getPhotos";
}
-(NSString*) getHttpMethod
{
    return @"GET";
}
-(NSString*) photosArrayKey { return @"photos"; }
-(BOOL) isGetQuery { return YES; }
-(void) processResponse:(id) JSON
{
    NSDictionary * jsonBody = [JSON valueForKey:@"response"];
    if (!jsonBody)
    {
        onComplete(nil, nil);
    }
    //Сначала распарсить пользователей, потом можно оставить на них ссылки
    [PhotosParser parseUsersWithArray:[jsonBody objectForKey:@"users"]];
    
    PhotoResponse * newResponse = [PhotoResponse new];
    NSArray * results = [jsonBody objectForKey:[self photosArrayKey]];
    int count;
    if ([jsonBody objectForKey:@"count"] != nil && [jsonBody objectForKey:@"count"] != [NSNull null])
        count = [[jsonBody objectForKey:@"count"] intValue];
    else
    {
        count = results.count;
    }
    newResponse.totalPhotoCount = count;
    if (userPics)
    {
        [CaptionTagsParser setCutString:@"#me"];
    }
    newResponse.photos = [PhotosParser parsePhotosWithArray:results queryIsGet:[self isGetQuery] searchQuery:highlight];
    [CaptionTagsParser setCutString:nil];
    onComplete([PhotosParser getUsers], newResponse);
}
-(void) processError:(id) JSON error:(NSError*) error response:(NSHTTPURLResponse*)response
{
    onError(error);
}

-(void)start:(void (^)(NSDictionary * users, PhotoResponse * photos))completeBlock onError:(void (^)(NSError *))errorBlock
{
    onComplete = completeBlock; onError = errorBlock;
    [self start];
}
-(void)clean
{
    self->onComplete = nil;
    self->onError = nil;
}
@end
