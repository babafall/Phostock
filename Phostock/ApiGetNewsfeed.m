//
//  ApiGetNewsfeed.m
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiGetNewsfeed.h"
#import "PhotosParser.h"
@implementation ApiGetNewsfeed
-(NSDictionary*) getQueryParameters
{
    NSMutableDictionary * dict = (NSMutableDictionary *)[super getQueryParameters];
    if (self.since) dict[@"since"] = self.since;
    if (self.after) dict[@"after"] = self.after;
    if (self.limit) dict[@"limit"] = @(self.limit);
    return dict;
}
-(NSString*) getMethodName
{
    return @"getNewsfeed";
}
-(NSString*) arrayKey
{
    return @"news";
}
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
    NSArray * results = [jsonBody objectForKey:self.arrayKey];
    int count;
    if ([jsonBody objectForKey:@"count"] != nil && [jsonBody objectForKey:@"count"] != [NSNull null])
        count = [[jsonBody objectForKey:@"count"] intValue];
    else
    {
        count = results.count;
    }
    newResponse.totalPhotoCount = count;
    
    if (!self.fetchPhotoCount)
    {
        newResponse.photos = [PhotosParser parsePhotosWithArray:results queryIsGet:YES searchQuery:nil];
    }
    else
    {
        newResponse.totalPhotoCount = results.count;
    }
    id since = [jsonBody objectForKey:@"since"], after = [jsonBody objectForKey:@"after"];
    if (since && [since isKindOfClass:[NSString class]])
        self.since = since;
    else
        self.since = nil;
    if (after && [after isKindOfClass:[NSString class]])
        self.after = after;
    else
        self.noMorePhotos = YES;
    onComplete([PhotosParser getUsers], newResponse);
}
-(void) processError:(id) JSON error:(NSError*) error response:(NSHTTPURLResponse*)response
{
    NSLog(@"Loading error %@", error);
    onComplete(nil, nil);
}
-(void) start:(void(^)(NSDictionary * users,  PhotoResponse * photos)) completeBlock
{
    onComplete = completeBlock;
    [self start];
}
-(void)clean
{
    self->onComplete = nil;
}
@end
