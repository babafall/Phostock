//
//  PhotosParser.m
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "PhotosParser.h"
#import "CaptionTagsParser.h"

static PhotosParser * sharedInstance = nil;

@implementation PhotosParser

-(id) init
{
    self = [super init];
    if (self)
    {
        NSDateFormatter * formatter = [NSDateFormatter new];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_en"]];
        [formatter setDateFormat:@"h:mm a"];
        self->dateFormatter = formatter;
        self->parsedUsers = [NSMutableDictionary new];
        sharedInstance = self;
        
        NSString *expression = @"#[a-zA-Zа-яА-Я0-9._-]+";
        tagsRegexp = [NSRegularExpression regularExpressionWithPattern:expression options:0 error:NULL];
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    }
    return self;
}
+(PhotosParser*) instance
{
    if (!sharedInstance) sharedInstance = [[PhotosParser alloc] init];
    return sharedInstance;
}
+(NSDictionary *)getUsers
{
    return [self instance]->parsedUsers;
}
+(void) parseUsersWithArray:(NSArray*)users
{
    NSMutableDictionary * mutableUsers = [self instance]->parsedUsers;
    for (NSDictionary * user in users)
    {
        NSString * userId = [user objectForKey:@"id"];
        NSString * login = [user objectForKey:@"login"];
        [mutableUsers setObject:user forKey:userId ];
        [mutableUsers setObject:user forKey:login ];
    }
}

+(NSArray*) parsePhotosWithArray:(NSArray*)results queryIsGet:(BOOL)queryIsGet searchQuery:(NSString*) searchQuery
{
    NSMutableArray * photosArray = [NSMutableArray arrayWithCapacity:results.count];
    
    for (NSDictionary * result in results) {
        
        NSDictionary * photo = result;
        if ([result objectForKey:@"photo"])
        {
             photo = [result objectForKey:@"photo"];
        }
        
        if (photo == nil && queryIsGet) continue;
        else if (photo == nil && !queryIsGet)
        {
            NSString * userId = [result objectForKey:@"user_id"];
            NSDictionary * userInfo = [[self instance]->parsedUsers objectForKey:userId];
            
            if (!userId) userId = @"";
            if (!userInfo) userInfo = @{};
            NSDictionary * photoDictionaryInfo = @{
                kUserId : userId, kUserInfo : userInfo, kPhoto : @""
            };
            
            [photosArray addObject:photoDictionaryInfo];
            continue;
        }
        NSDictionary * resultPhoto = [self preparePhotoInfo:photo highlightCaption:searchQuery];
        [photosArray addObject: resultPhoto];
    }
    return photosArray;
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+ (NSDictionary*) preparePhotoInfo:(NSDictionary*)photo highlightCaption:(NSString*) highlight
{
    NSArray * sizes = [photo objectForKey:@"sizes"];
    
    NSNumber     * userId    = [photo objectForKey:@"user"];
    NSDictionary * userInfo  = [[self instance]->parsedUsers objectForKey:userId];
    NSString     * photoId   = [photo objectForKey:@"id"];
    NSNumber     * timestamp = [photo objectForKey:@"date"];
    if (!timestamp) timestamp = @(0);
    NSString     * dateStr   = nil;
    {
        NSDate   * date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
        NSString * time = [[self instance]->dateFormatter stringFromDate:date];
        
        int days = [self daysBetweenDate:date andDate:[NSDate date]];
        NSString * day = nil;
        if (days == 0) day = @"today";
        else if (days == 1) day = @"yesterday";
        else
        {
            NSDateComponents * dayCompo = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
            if (days < 365)
                day = [NSString stringWithFormat:@"%d.%d", dayCompo.day, dayCompo.month];
            else
                day = [NSString stringWithFormat:@"%d.%d.%d", dayCompo.day, dayCompo.month, dayCompo.year];
        }
        
        dateStr = [[NSString stringWithFormat:@"%@ at %@", day, time] lowercaseString];
    }
    
    NSString     * caption   = ([photo objectForKey:@"caption"] != nil && [photo objectForKey:@"caption"] != [NSNull null]) ? [photo objectForKey:@"caption"] : @"";
    
    NSString     * optimalPhotoUrl  = @"";
    NSString     * minPhotoUrl      = @"";
    NSString     * maxPhotoUrl      = @"";
    
    int minSize = 1000, maxSize = 0;
    if (sizes.count != 0)
    {
        for (NSDictionary * size in sizes)
        {
            int curSize = [[size objectForKey:@"w"] intValue];
            if (curSize < minSize)
            {
                minPhotoUrl = [size objectForKey:@"location"];;
                minSize = curSize;
            }
            if (curSize > maxSize)
            {
                maxPhotoUrl = [size objectForKey:@"location"];
            }
            
            if (curSize == (int)[self instance]->screenSize.width)
            {
                optimalPhotoUrl = maxPhotoUrl;
            }
        }
    }
    if ([optimalPhotoUrl isEqualToString:@""])
    {
        optimalPhotoUrl = maxPhotoUrl;
    }
    
    NSDictionary * replyToPhoto = @{};
    if ([photo objectForKey:@"reply_to_photo"])
    {
        replyToPhoto = [self preparePhotoInfo:[photo objectForKey:@"reply_to_photo"] highlightCaption:highlight];
    }
    
    if (!userId) userId = [NSNumber numberWithInt:0];
    if (!userInfo) userInfo = @{};
    if (!photoId) photoId = @"";
    
    NSDictionary * photoDictionaryInfo = @{
        kUserId : userId, kUserInfo : userInfo, kPhotoId : photoId,
        kTimestamp : timestamp, kDateStr : dateStr,
        kPhoto : optimalPhotoUrl, kMinPhoto : minPhotoUrl, kMaxPhoto : maxPhotoUrl,
        kReplyPhoto : replyToPhoto
    };
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:photoDictionaryInfo];
    [result setValuesForKeysWithDictionary:[CaptionTagsParser prepareCaptionTags:caption tagsRegexp:[self instance]->tagsRegexp highlight:highlight]];
    return result;
}
@end
