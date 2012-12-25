//
//  CaptionTagsParser.m
//  Phostock
//
//  Created by Roman Truba on 02.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "CaptionTagsParser.h"
#import "UIFastLabel.h"
#import "NetWorker.h"

static CaptionTagsParser * instance;

@implementation CaptionTagsParser
+ (void)setCutString:(NSString*) string
{
    if (!instance) instance = [[CaptionTagsParser alloc] init];
    instance->cutString = string;
}
+ (NSDictionary*) prepareCaptionTags:(NSString*) caption
{
    if (!caption) return nil;
    NSString *expression = @"#[a-zA-Zа-яА-Я0-9._-]+";
    NSRegularExpression * tagsRegexp = [NSRegularExpression regularExpressionWithPattern:expression options:0 error:NULL];
    return [CaptionTagsParser prepareCaptionTags:caption tagsRegexp:tagsRegexp highlight:nil];
}

+ (NSDictionary*) prepareCaptionTags:(NSString*) caption tagsRegexp:(NSRegularExpression *) tagsRegexp highlight:(NSString*)searchQuery
{
    if (instance && instance->cutString)
    {
        caption = [caption stringByReplacingOccurrencesOfString:instance->cutString withString:@""];
    }
    FastAttributedString * captionAttrString = nil, * captionMiniString = nil;
    FastAttributedStringSize captionAttrSize, captionMiniSize;
        
    int captionSize = MAX_FONT_SIZE, miniSize = MINI_FONT_SIZE;
    UIFont * font = [UIFont fontWithName:kLobsterFont size:MAX_FONT_SIZE];
    if (![self findOptimalFontSize:caption fontSizeRef:&captionSize font:font])
    {
        captionSize = MIN_FONT_SIZE;
    }
    font = [font fontWithSize:miniSize];
    if (![self findOptimalFontSize:caption fontSizeRef:&miniSize font:font frameSize:CGSizeMake(90, 300)])
    {
        miniSize = MINI_FONT_SIZE;
    }
    NSMutableArray * tagsArray = [NSMutableArray new], * mentionsArray = [NSMutableArray new];
    [CaptionTagsParser parseTags:caption toArray:tagsArray];
    [CaptionTagsParser parseMentions:caption toArray:mentionsArray];
    [tagsArray addObjectsFromArray:mentionsArray];
    
    //Основная строка
    captionAttrString = [UIFastLabel buildAttributedString:caption
                                           withFont:[UIFont fontWithName:kLobsterFont size:captionSize]
                                     andCustomLinks:tagsArray
                                       andHighlight:searchQuery];
    
    captionAttrSize = [UIFastLabel calculateSizeForAttributedString:captionAttrString withMaxPortraitWidth:300];
    captionAttrString.drawSizePortrait = captionAttrSize.portraitSize;
    captionAttrString.originalString = caption;

    NSValue * attrSizeVal = [NSValue value:&captionAttrSize withObjCType:@encode(FastAttributedStringSize)];
    if (!attrSizeVal) attrSizeVal = [NSValue new];
    if (!captionAttrString) captionAttrString = (FastAttributedString *)[NSNull null];
    
    //Мини строка
    captionMiniString = [UIFastLabel buildAttributedString:caption
                                                  withFont:[UIFont fontWithName:kLobsterFont size:miniSize]
                                            andCustomLinks:tagsArray
                                              andHighlight:searchQuery];
    
    captionMiniSize = [UIFastLabel calculateSizeForAttributedString:captionMiniString withMaxPortraitWidth:90];
    captionMiniString.drawSizePortrait = captionMiniSize.portraitSize;
    captionMiniString.originalString = caption;
    
    NSValue * attrSizeMiniVal = [NSValue value:&captionMiniSize withObjCType:@encode(FastAttributedStringSize)];
    if (!attrSizeMiniVal) attrSizeMiniVal = [NSValue new];
    if (!captionMiniString) captionMiniString = (FastAttributedString *)[NSNull null];
    
    return @{
        kCaption : captionAttrString, kCaptionSize : attrSizeVal,
    kCaptionMini : captionMiniString, kCaptionSizeMini : attrSizeMiniVal
    };
}


+ (NSString *)parseTags:(NSString *)src toArray:(NSMutableArray *)array
{
    if(!src)
        return src;
    NSRegularExpression *expUser = [NSRegularExpression regularExpressionWithPattern:@"#[a-zA-Zа-яА-Я0-9._-]+" options:NSRegularExpressionSearch error:nil];
    int searchPos = 0;
    while(true)
    {
        NSTextCheckingResult *match = [expUser firstMatchInString:src options:0 range:NSMakeRange(searchPos, src.length - searchPos)];
        if(!match.numberOfRanges)
            break;
        NSString *result = [src substringWithRange:match.range];
        
        FastAttributedStringCustomLink *link = [[FastAttributedStringCustomLink alloc] init];
        link.stringUrl = result;
        link.range = NSMakeRange(match.range.location, match.range.length);
        link.resultType = NSTextCheckingTypeLink;
        [array addObject:link];
        searchPos = match.range.location + match.range.length;
    }
    return src;
}
+ (NSString *)parseMentions:(NSString *)src toArray:(NSMutableArray *)array
{
    if(!src)
        return src;
    NSRegularExpression *expUser = [NSRegularExpression regularExpressionWithPattern:@"@[a-zA-Zа-яА-Я0-9._-]+" options:NSRegularExpressionSearch error:nil];
    int searchPos = 0;
    while(true)
    {
        NSTextCheckingResult *match = [expUser firstMatchInString:src options:0 range:NSMakeRange(searchPos, src.length - searchPos)];
        if(!match.numberOfRanges)
            break;
        NSString *result = [src substringWithRange:match.range];
        
        FastAttributedStringCustomLink *link = [[FastAttributedStringCustomLink alloc] init];
        link.stringUrl = result;
        link.range = NSMakeRange(match.range.location, match.range.length);
        link.resultType = NSTextCheckingTypeLink;
        [array addObject:link];
        searchPos = match.range.location + match.range.length;
    }
    return src;
}
+(BOOL) findOptimalFontSize:(NSString*)text fontSizeRef:(int*) fontSize font:(UIFont*) font
{
    return [self findOptimalFontSize:text fontSizeRef:fontSize font:font frameSize:CGSizeMake(280, 300)];
}
+(BOOL) findOptimalFontSize:(NSString*)text fontSizeRef:(int*) fontSize font:(UIFont*) font frameSize:(CGSize) frameSize
{
    if ((id)text == [NSNull null] || text == nil) return NO;
    int curSize = *fontSize, minSize = curSize > MIN_FONT_SIZE ? MIN_FONT_SIZE : MINI_FONT_SIZE ;
    for (int i = curSize; i >= minSize; i--)
    {
        font = [font fontWithSize:i];
        CGSize size = [text sizeWithFont:font
                       constrainedToSize:frameSize
                           lineBreakMode:UILineBreakModeWordWrap]; // default mode
        float numberOfLines = size.height / font.lineHeight;
        if (numberOfLines < 2 ||
            (numberOfLines < 3 && i == minSize)) {
            *fontSize = i;
            return YES;
        }
    }
    return NO;
}
@end
