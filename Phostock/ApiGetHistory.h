//
//  ApiGetHistory.h
//  Phostock
//
//  Created by Roman Truba on 09.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiGetPhotos.h"

@interface ApiGetHistory : ApiGetPhotos
@property (nonatomic, strong) NSString * photoId;
@property (nonatomic, assign) BOOL complete;
@end
