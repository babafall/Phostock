//
//  NewsFeedController.h
//  Phostock
//
//  Created by Roman Truba on 19.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "NetworkMainViewController.h"

@interface NewsFeedController : NetworkMainViewController
{
    NSTimer * newsTimer;
    
    String mostEarlyKey;
    String lastAfterKey;
    
    BOOL shouldReloadOnAppear, noMoreOlderPhotos, updateBadge;
}
- (void) loadLastNews;
@end
