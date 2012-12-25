//
//  ApiSearch.m
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "ApiSearch.h"

@implementation ApiSearch
@synthesize query = _query;
-(id) initWithQuery:(NSString*) searchQuery
{
    self = [super init];
    if (self)
    {
        self.query = searchQuery;
    }
    return self;
}
-(NSString*) getMethodName
{
    return @"searchPhotos";
}
-(NSString*) photosArrayKey { return @"results"; }
-(BOOL) isGetQuery { return NO; }
-(NSDictionary*) getQueryParameters
{
    NSMutableDictionary * dict = (NSMutableDictionary *)[super getQueryParameters];
    if (_query)      [dict setObject:_query   forKey:@"q"];
    return dict;
}
-(void)setQuery:(NSString *)newQuery
{
    _query = newQuery;
    self.highlight = _query;
}
@end
