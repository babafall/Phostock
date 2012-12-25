//
//  PhotosParser.h
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotosParser : NSObject
{
    NSDateFormatter * dateFormatter;
    NSMutableDictionary * parsedUsers;
    NSRegularExpression * tagsRegexp;
    
    CGSize screenSize;
}

+ (PhotosParser*) instance;
+ (NSDictionary*) getUsers;
+ (void) parseUsersWithArray:(NSArray*)users;
+ (NSArray*) parsePhotosWithArray:(NSArray*)results queryIsGet:(BOOL)queryIsGet searchQuery:(NSString*) searchQuery;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (NSDictionary*) preparePhotoInfo:(NSDictionary*)photo highlightCaption:(NSString*) highlight;
@end
