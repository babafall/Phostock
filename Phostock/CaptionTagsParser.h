//
//  CaptionTagsParser.h
//  Phostock
//
//  Created by Roman Truba on 02.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CaptionTagsParser : NSObject
{
    NSString * cutString;
}
+ (NSDictionary*) prepareCaptionTags:(NSString*) caption;
+ (NSDictionary*) prepareCaptionTags:(NSString*) caption tagsRegexp:(NSRegularExpression *) tagsRegexp highlight:(NSString*)searchQuery;
+ (NSString *)parseTags:(NSString *)src toArray:(NSMutableArray *)array;
+ (BOOL) findOptimalFontSize:(NSString*)text fontSizeRef:(int*) fontSize font:(UIFont*) font;

+ (void)setCutString:(NSString*) string;
@end
