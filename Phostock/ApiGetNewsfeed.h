//
//  ApiGetNewsfeed.h
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiMethod.h"

@interface ApiGetNewsfeed : ApiMethod
{
    void(^onComplete)(NSDictionary *,  PhotoResponse *);
}
@property (nonatomic, strong) String since;
@property (nonatomic, strong) String after;
@property (nonatomic, assign) int    limit;
@property (nonatomic, assign) BOOL   fetchPhotoCount;
@property (nonatomic, assign) BOOL   noMorePhotos;

-(void) start:(void(^)(NSDictionary * users,  PhotoResponse * photos)) completeBlock;

@end
