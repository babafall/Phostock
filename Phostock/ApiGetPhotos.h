//
//  ApiGetPhotos.h
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiMethod.h"

@interface ApiGetPhotos : ApiMethod
{
    void(^onComplete)(NSDictionary *,  PhotoResponse *);
    void(^onError)(NSError*);
}
@property (nonatomic, strong) NSString * user_id;
@property (nonatomic, strong) NSString * highlight;
@property (nonatomic, assign) int offset;
@property (nonatomic, assign) int limit;
@property (nonatomic, assign) BOOL userPics;

-(id) initWithUserId:(NSString*) userId;
-(void)start:(void (^)(NSDictionary * users, PhotoResponse * photos))completeBlock onError:(void (^)(NSError *))errorBlock;
@end
