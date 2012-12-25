//
//  RepliesViewController.m
//  Phostock
//
//  Created by Roman Truba on 19.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "RepliesViewController.h"

@implementation RepliesViewController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newReply) name:kUserMentionedNotification object:nil];
    }
    return self;
}
-(void) newReply
{
    updateBadge = YES;
    [self loadLastNews];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.tableMainHeader.titleText = @"Replies";
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

-(NSString*) getKeyForSince
{
    return kMentionsMostEarlyKey;
}

- (ApiGetNewsfeed*) getNewsMethod
{
    return [ApiGetMentions new];
}

- (void) markAsVisibleForever
{
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs setBool:YES forKey:kMentionsVisible];
    [defs synchronize];
}

@end
