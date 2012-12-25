//
//  PhotoCells.m
//  Phostock
//
//  Created by Roman Truba on 26.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "PhotoCells.h"
#import "UIImageView+AFNetworking.h"
#import "NetWorker.h"
static PhotoCells * sharedInstance = nil;

@implementation MainPhotoCell

@synthesize photoViewer;
-(void)awakeFromNib
{
    self.photoViewer = [PhotoViewer getNew];
    self.photoViewer.frame = CGRectMake(0, 45, 320, 320);
    [self.contentView addSubview:self.photoViewer];
}

-(void)showUploadMark
{
//    self.mainUniversalView.uploadedMarkView.hidden = NO;
//    self.mainUniversalView.uploadedMarkView.alpha = 1;
    [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        self.mainUniversalView.uploadedMarkView.alpha = 0;
    } completion:^(BOOL finished) {
//        self.mainUniversalView.uploadedMarkView.hidden = YES;
    }];
}

@end
@implementation PhotoHeader
@synthesize userAvatarView, usernameLabel, headerButton, timestampLabel;

-(IBAction) headerButtonClicked:(id)sender
{
    [self.delegate headerSelectedUser:self.usernameLabel.text];
}
@end

@implementation PhotoCells

+(PhotoCells*)instance
{
    if (!sharedInstance)
    {
        sharedInstance = [PhotoCells new];
    }
    return sharedInstance;
}

+(MainPhotoCell *)getMainPhotoCell
{
    [[NSBundle mainBundle] loadNibNamed:@"MainCell" owner:[PhotoCells instance] options:nil];
    return sharedInstance.mainPhotoCell;
}
+(PhotoHeader *)getSectionHeader
{
    [[NSBundle mainBundle] loadNibNamed:@"HeaderCell" owner:[PhotoCells instance] options:nil];
    return sharedInstance.sectionHeader;
}
+ (NSArray*)createAnimation:(NSString*)fileName {
    NSMutableArray *animationImages = [NSMutableArray array];
    
    for (int i = 1; i<25; i++) {
        [animationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%@%d", fileName, i] ] ];
    }
    
    return animationImages;
}

+(UITableViewCell *)getLoadingCell
{
    [[NSBundle mainBundle] loadNibNamed:@"PhotoCells" owner:[PhotoCells instance] options:nil];
    UIImageView * _activityIndicatorView = (UIImageView *)sharedInstance.loadingCell.contentView.subviews[0];
    _activityIndicatorView.animationImages = [self createAnimation:@"loader"];
    _activityIndicatorView.animationDuration = 1.0f;
    _activityIndicatorView.animationRepeatCount = 0;
    [_activityIndicatorView startAnimating];
    return sharedInstance.loadingCell;
}
+(UITableViewCell *)getEmptyCell
{
    [[NSBundle mainBundle] loadNibNamed:@"PhotoCells" owner:[PhotoCells instance] options:nil];
    return sharedInstance.emptyCell;
}
+(FollowersHeader *)getFollowersHeader
{
    [[NSBundle mainBundle] loadNibNamed:@"PhotoCells" owner:[PhotoCells instance] options:nil];
    return sharedInstance.followersHeader;
}
@end


@implementation FollowersHeader
@synthesize encounter, textLabel;
-(void) setCount:(int)count ofText:(NSString*) text
{
    encounter.text = [NSString stringWithFormat:@"%d", count];
    textLabel.text = text;
    
    [encounter sizeToFit];
    [textLabel sizeToFit];
    
    static int indent = 3;
    float sumW = RectWidth(encounter.frame) + RectWidth(textLabel.frame) + indent;
    float offset = (RectWidth(self.frame) - sumW) / 2;
    
    encounter.frame = RectSetX(encounter.frame, offset);
    textLabel.frame = RectSetX(textLabel.frame, offset + RectWidth(encounter.frame) + indent);
}

@end