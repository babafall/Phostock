//
//  ApiSearch.h
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiGetPhotos.h"

@interface ApiSearch : ApiGetPhotos
@property (nonatomic, strong) NSString * query;

-(id) initWithQuery:(NSString*) searchQuery;
@end
