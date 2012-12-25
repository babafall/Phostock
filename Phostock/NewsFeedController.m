//
//  NewsFeedController.m
//  Phostock
//
//  Created by Roman Truba on 19.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "NewsFeedController.h"

@implementation NewsFeedController

//Запустить сервис загрузки новостей
//Отобразить эту вкладку на основе запроса getFollowers
//+ отобразить на вкладке бейдж с количеством новых новостей с последнего просмотренного момента времени
//Загрузка каждую минуту
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self )
    {
        mostEarlyKey = [[NSUserDefaults standardUserDefaults] stringForKey:[self getKeyForSince]];
        [self loadLastNews];
        newsTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(loadLastNews) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullReload) name:@"userFollowUnfollow" object:nil];
        updateBadge = NO;
    }
    return self;
}
-(NSString*) getKeyForSince
{
    return kNewsMostEarlyKey;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self getSince:nil after:nil];
    shouldReloadOnAppear = NO;
    
    self.tableMainHeader.titleText = @"Newsfeed";
    
    __unsafe_unretained NewsFeedController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        weakSelf->pullToRefresh = YES;
        weakSelf->clearBeforeAdd = YES;
        [weakSelf getSince:weakSelf->mostEarlyKey after:nil];
        
    }];
    self.tableView.pullToRefreshView.arrowColor = [UIColor whiteColor];
    self.tableView.pullToRefreshView.textColor  = [UIColor whiteColor];
}
- (void) fullReload
{
    noMoreOlderPhotos = NO;
    updateBadge = YES;
    mostEarlyKey = nil;
    photosArray = nil;
    [self.tableView reloadData];
    [self getSince:nil after:nil];
}

- (void) loadLastNews
{
    //Если на экране - то загрузить фотки в нормальном режиме. Иначе посто загрузить количество
    if (isVisible)
    {
        [self getSince:mostEarlyKey after:nil];
    }
    else {
        ApiGetNewsfeed * method = [self getNewsMethod];
        method.since = mostEarlyKey;
        method.limit = 100;
        //Флаг, чтоб не парсил фотки
        method.fetchPhotoCount = YES;
        isLoading = YES;
        [method start:^(NSDictionary *users, PhotoResponse *photos) {
            [self.tabButton setBadgeValue:photos.totalPhotoCount];
            if (photos.totalPhotoCount > 0)
            {
                shouldReloadOnAppear = YES;
                [self markAsVisibleForever];
            }
        }];
    }
}
- (void) markAsVisibleForever
{
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs setBool:YES forKey:kNewsFeedVisible];
    [defs synchronize];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tabButton setBadgeValue:0];
    if (shouldReloadOnAppear) [self loadLastNews];
}
- (ApiGetNewsfeed*) getNewsMethod
{
    return [ApiGetNewsfeed new];
}
-(void) performNextLoadCheck
{
    if (isLoading || noMoreOlderPhotos) return;
    [self getSince:nil after:lastAfterKey];
}
- (void) getSince:(String) since after:(String) after
{
    ApiGetNewsfeed * method = [self getNewsMethod];
    method.since = since;
    method.after = after;
    isLoading = YES;
    [method start:^(NSDictionary *users, PhotoResponse *photos) {
        if (!since && !after)
        {
            mostEarlyKey = method.since;
            [self saveEarlyKey];
            lastAfterKey = method.after;
        }
        else if (since)  {
            mostEarlyKey = method.since;
            [self saveEarlyKey];
        }
        else if (after) {
            lastAfterKey = method.after;
        }
        noMoreOlderPhotos = method.noMorePhotos;
        //Логика такая - если задан ключ since (с какой даты, значит мы грузим новейшие фотки)
        [self processPhotosFromResponse:photos users:users isLastLoader:since ? YES : NO];
        
        if (updateBadge)
        {
            [self.tabButton setBadgeValue:photos.totalPhotoCount];
            if (photos.totalPhotoCount > 0)
            {
                shouldReloadOnAppear = YES;
                [self markAsVisibleForever];
            }
        }
    }];
}
- (void) saveEarlyKey
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:mostEarlyKey forKey:[self getKeyForSince]];
    [defaults synchronize];
}
- (void) processPhotosFromResponse:(PhotoResponse *)response users:(NSDictionary *)users
{
    [self processPhotosFromResponse:response users:users isLastLoader:NO];
}
- (void) processPhotosFromResponse:(PhotoResponse *)response users:(NSDictionary *)users isLastLoader:(BOOL) isLastNews
{
    NSMutableArray * nicks = [NSMutableArray arrayWithCapacity:users.count];
    for (NSDictionary * userId in users)
    {
        [nicks addObject:users[userId][@"login"]];
    }
    [[NetWorker sharedInstance] putUsers:nicks];
    isLoading = NO;
    totalPhotos = -1;
    if (response.photos.count == 0) {
        [self reload];
        return;
    }
    NSMutableArray * newArray = [response.photos mutableCopy];
    if (photosArray) {
        if (isLastNews) [newArray addObjectsFromArray:photosArray];
        else { [photosArray addObjectsFromArray:newArray]; newArray = photosArray; }
    }
    photosArray = newArray;
    
    [self reload];
}
- (void) clear
{
    [super clear];
    [newsTimer invalidate];
    newsTimer = nil;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:[self getKeyForSince]];
    [defaults synchronize];
}

@end
