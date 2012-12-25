//
//  SingleViewer.m
//  Phostock
//
//  Created by Roman Truba on 09.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "SingleViewer.h"
#import "PhotoCells.h"

@implementation SingleViewer
@synthesize photoInfo;
-(void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [super viewDidLoad];
    
    viewer = [PhotoViewer getNew];
    viewer.frame = CGRectMake(0, 103, 320, 320);
    viewer.delegate = self.caller;
    
    [self.view addSubview:viewer];
    
    NSDictionary * userInfo = [photoInfo objectForKey:kUserInfo];
    header.timestampLabel.text = [photoInfo objectForKey:kDateStr];
    header.userAvatarView.dontUseProgressBar = YES;
    header.delegate = self;
    header.usernameLabel.text = [userInfo objectForKey:@"login"];
    [ header.usernameLabel sizeToFit ];
    NSDictionary * userPhotos = [userInfo objectForKey:@"photo"];
    if (userPhotos) {
        NSString * smallPhoto = [userPhotos objectForKey:@"photo_small"];
        if (smallPhoto && ![smallPhoto isEqualToString:@""]) {
            header.userAvatarView.highlightedImage = nil;
            [header.userAvatarView setImageWithURL:[NSURL URLWithString: smallPhoto] maskImage:[UIImage imageNamed:@"FeedAvatarMask"]];
        }
    }
    else {
        header.userAvatarView.image = [UIImage imageNamed:@"Avatar"];
        header.userAvatarView.highlightedImage = [UIImage imageNamed:@"Avatar_Pressed"];
    }
    
    header.replyAvatarView.hidden = YES;
    header.replyAvatarView.image = [UIImage imageNamed:@"Avatar"];
    header.replyAvatarView.highlightedImage = [UIImage imageNamed:@"Avatar_Pressed"];
    
    viewer.imagesArray = nil;
    viewer.historyCompleted = NO;
    NSMutableArray * photos = [NSMutableArray array];
    if (photoInfo)
        [photos addObject:photoInfo];
    NSDictionary * reply = [photoInfo objectForKey:kReplyPhoto];
    if (reply && [reply count])
    {
        [photos addObject:reply];
        header.replyAvatarView.hidden = NO;
        NSDictionary * photo = [[reply objectForKey:kUserInfo] objectForKey:@"photo"];
        if (photo)
        {
            NSString * smallPhoto = [photo objectForKey:@"photo_small"];
            if (smallPhoto && ![smallPhoto isEqualToString:@""]) {
                header.replyAvatarView.highlightedImage = nil;
                [header.replyAvatarView setImageWithURL:[NSURL URLWithString: smallPhoto] maskImage:[UIImage imageNamed:@"FeedAvatarMask"]];
            }
        }
    }
    
    viewer.imagesArray = photos;
    viewer.tableView.scrollsToTop = NO;
}
-(IBAction) pop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) headerSelectedUser:(NSString*) nick
{
    if (self.caller && [self.caller respondsToSelector:@selector(headerSelectedUser:)])
    {
        [self.caller headerSelectedUser:nick];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
