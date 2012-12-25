//
//  MainHeader.m
//  Phostock
//
//  Created by Roman Truba on 22.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "MainHeader.h"
#import "UniversalImageView.h"
#import "UploadingView.h"

@implementation UserEncounterView (private)
-(NSString*) getFormattedStringForCount:(int) count
{
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSize:3];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@" "];
    
    return [formatter stringFromNumber:@(count)];
}
-(void) setMainButtonText:(NSString*)text
{
    [mainButton setTitle:text forState:UIControlStateNormal];
    CGRect mRect = mainButton.frame;
    [mainButton sizeToFit];
    CGRect tempRect = mainButton.frame;
    mainButton.frame = mRect;
    mRect = tempRect;
    
    //Calculations
    mRect = RectSetWidth(mRect, mRect.size.width + 24);
    mRect = RectSetX(mRect, self.center.x - mRect.size.width / 2);
    
    CGFloat wDiff = RectWidth(mRect) - RectWidth(mRect);
    mainButton.frame = CGRectMake(RectX(mainButton.frame) + wDiff/2, RectY(mRect),
                                  RectWidth(mainButton.frame), RectHeight(mainButton.frame));
    mainButton.frame                = mRect;
}

@end

@implementation UserPhotoView
@synthesize photoList = _photoList;
-(void)awakeFromNib
{
    self.photosTable = [PhotoViewer getNew];
    self.photosTable.tableView.scrollsToTop = NO;
    self.photosTable.hidden = YES;
    [self addSubview:self.photosTable];
    self.backgroundColor = [UIColor clearColor];
}
-(void)setPhotoList:(NSArray *)photoList
{
    _photoList = photoList;
    self.photosTable.imagesArray = photoList;
    if (_photoList.count > 0) {
        self.photosTable.hidden = NO;
        self.photosTable.frame = CGRectMake(0, 0, 320, 320);
    }
}
-(void) setSelectedPhoto:(int) index
{
    if (self.photosTable.imagesArray.count <= index) return;
    [self.photosTable.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

@end

@implementation UserEncounterView

-(void)awakeFromNib
{
    buttonMode = EncounterButtonSetMyPhoto;
    leftButtonMode = EncounterButtonLeftFollowers;
    [self setFollowersCount:0];
    [self setMentionsCount:0];
    [self setMyPhotoButton];
}

-(void) setFollowersCount:(int) fCount
{
    followersCount = fCount;
    followersLabel.text = [self getFormattedStringForCount:followersCount];
    leftTitle.text = @"FOLLOWERS";
}

-(void) setMentionsCount:(int) mCount
{
    mentionsCount = mCount;
    mentionsLabel.text = [self getFormattedStringForCount:mentionsCount];
}
 
-(void) setFollow:(BOOL) isFollowing
{
    mainButton.hidden = NO;
    unblockButton.hidden = YES;
    mainButton.enabled = YES;
    if (!isFollowing)
    {
        [self setMainButtonText:@"Follow"];
        mainButton.selected = NO;
        buttonMode = EncounterButtonFollow;
    }
    else
    {
        [self setMainButtonText:@"Following"];
        mainButton.selected = YES;
        buttonMode = EncounterButtonFollowing;
    }
}
-(void) setBlocked
{
    mainButton.hidden = YES;
    unblockButton.hidden = NO;
}
-(void) setMyPhotoButton
{
    [self setMainButtonText:@"Set my photo"];
    mainButton.selected = NO;
    buttonMode = EncounterButtonSetMyPhoto;
}

-(IBAction) mainButtonPressed:(id)sender
{
    switch (buttonMode) {
        case EncounterButtonSetMyPhoto:
            [self.delegate setMyPhoto];

            break;
        case EncounterButtonFollow:
            [self.delegate follow];
            [self setFollowersCount:followersCount+1];
            mainButton.enabled = NO;
            break;
        case EncounterButtonFollowing:
            [self.delegate unfollow];
            [self setFollowersCount:followersCount-1];
            mainButton.enabled = NO;
            break;
        default:
            break;
    }
}
-(IBAction) unblockPressed:(id)sender
{
    [self.delegate unblockUser];
}

-(IBAction) leftButtonClicked:(id)sender
{
    switch (leftButtonMode) {
        case EncounterButtonLeftFollowers:
            [self.delegate showFollowers];
            break;
        case EncounterButtonLeftPhotos:
            [self.delegate showPhotos];
            break;
        default:
            break;
    }
}
-(IBAction) rightButtonClicked:(id)sender
{
    [self.delegate showMentions];
}
-(void) setLeftButtonPhotos:(int) count
{
    leftButtonMode = EncounterButtonLeftPhotos;
    [self setFollowersCount:count];
    leftTitle.text = @"PHOTOS";
}
-(void) setLeftButtonFollowers:(int) count
{
    leftButtonMode = EncounterButtonLeftFollowers;
    [self setFollowersCount:count];
}
@end

@implementation MainHeader

+(MainHeader *)getNewHeader
{
    MainHeader * h = ( MainHeader * )[[[NSBundle mainBundle] loadNibNamed:@"MainHeader" owner:nil options:nil] objectAtIndex:0];
    return h;
}
-(void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    [self.titleButton setTitle:_titleText forState:UIControlStateNormal];
    
    [self.titleButton sizeToFit];
    self.titleButton.frame = RectSetWidth(self.titleButton.frame, RectWidth(self.titleButton.frame) + 10);
    self.titleButton.frame = CGRectMake((RectWidth(self.frame) - RectWidth(self.titleButton.frame)) / 2, 0,
                                        RectWidth(self.titleButton.frame), RectHeight(self.frame));
    CGSize size = self.titleButton.frame.size;
    [self.titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -size.width-10)];
    [self.titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, self.titleButton.imageView.image.size.width - 5)];
    
}
-(NSString *)titleText
{
    return _titleText;
}
-(void) showBackButton:(void(^)(void))onClick
{
    onBackButtonClick = onClick;
    self.backButton.hidden = NO;
    [self.backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}
-(void) backButtonClicked
{
    if (onBackButtonClick) onBackButtonClick();
}

-(void)buttonHighlighted:(BOOL)highlight
{
    self.highlightImage.hidden = !highlight;
}
-(void)setGridCallback:(void (^)(BOOL))onClick
{
    onGridClicked = onClick;
}
-(IBAction) gridClicked:(id)sender
{
    self.gridButton.selected = !self.gridButton.selected;
    if (onGridClicked) onGridClicked(self.gridButton.selected);
}
@end

@implementation UsersHeader

+(UsersHeader *)createUserHeader:(NSString*) userName
{
    NSArray * items = [[NSBundle mainBundle] loadNibNamed:@"MainHeader" owner:nil options:nil];
    UsersHeader * v = [[UsersHeader alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    v.backgroundColor = [UIColor clearColor];
    v->username = userName;
    
    v.mainHeader = items[0];
    v.mainHeader.titleText = userName;
    v.mainHeader.backButton.hidden = YES;
    v.mainHeader.titleButton.delegate = v.mainHeader;
    
    [v.mainHeader.titleButton addTarget:v action:@selector(userButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [v.mainHeader.titleButton setImage:[UIImage imageNamed:@"HeaderArrow"] forState:UIControlStateNormal];
    [v.mainHeader.titleButton setImage:[UIImage imageNamed:@"HeaderArrow_active"] forState:UIControlStateHighlighted];
    [v.mainHeader.titleButton setImage:[UIImage imageNamed:@"HeaderArrow_active"] forState:UIControlStateSelected];
    [v addSubview:v.mainHeader];
    v.photoView = items[1];
    v.photoView.frame = RectSetY(v.photoView.frame, 44);
    [v addSubview:v.photoView];
    v.encounterView = items[2];
    v.encounterView.frame = RectSetY(v.encounterView.frame, 184);
    v.encounterView.delegate = v;
    [v addSubview:v.encounterView];
    
    [v loadUserInfo];
    return v;
}
-(void) setUserInfo:(NSDictionary*) userInfo
{
    currentProfilePhotoId = [userInfo objectForKey:kPhotoId];
    followersCount = [[userInfo objectForKey:@"followers_count"] intValue];
    [self.encounterView setFollowersCount:followersCount];
    
    mentionsCount = [[userInfo objectForKey:@"mentions_count"] intValue];
    [self.encounterView setMentionsCount:mentionsCount];
    
    followingCount = [[userInfo objectForKey:@"following_count"] intValue];
    totalPhotosCount = [[userInfo objectForKey:@"photos_count"] intValue];
    
    canFollow = [[userInfo objectForKey:@"can_follow"] boolValue];
    blocked = [[userInfo objectForKey:@"blocked"] boolValue];
    
    if ([username isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUsernameKey]])
    {
        [self.encounterView setMyPhotoButton];
    }
    else
    {
        NSArray * connections = [userInfo objectForKey:@"connections"];
        for (NSString * cn in connections) {
            if ([cn isEqualToString:@"following"])
            {
                following = YES;
            }
            else if ([cn isEqualToString:@"follower"])
            {
                followerOfMe = YES;
            }
        }
        [self.encounterView setFollow:following];
    }
    if (blocked)
    {
        [self.encounterView setBlocked];
    }
}
-(void) loadUserInfo
{
    if (![username isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUsernameKey]])
    {
        [self.encounterView setFollow:NO];
    }
    ApiGetUsers * gu = [[ApiGetUsers alloc] init];
    gu.users = @[username];
    [gu start:^(NSDictionary *usersDictionary) {
        NSDictionary * current = [usersDictionary objectForKey:username];
        [self setUserInfo:current];
    }];
    [self loadPhotos];
}
-(void) loadPhotos
{
    ApiGetPhotos * gp = [[ApiGetPhotos alloc] initWithUserId:username];
    gp.userPics = YES;
    [gp start:^(NSDictionary *users, PhotoResponse *photos) {
        NSLog(@"Loaded photos for user: %@. Photos count: %d", username, photos.totalPhotoCount);
        NSDictionary * userInfo = [users objectForKey:username];
//        NSLog(@"%@", userInfo);
        
        currentProfilePhotoId = [[userInfo objectForKey:@"photo"] objectForKey:@"id"];
        
        if (photos.totalPhotoCount > 0)
        {
            CGRect eRect = self.encounterView.frame,
                   pRect = self.photoView.frame,
                   sRect = self.frame;
            pRect = RectSetHeight(pRect, 320);
            eRect = RectSetY(eRect, RectY(pRect) + 320);
            sRect = RectSetHeight(sRect, RectY(eRect) + RectHeight(eRect));
            self.frame = sRect;
            [self.delegate usersHeaderResized];
            [UIView animateWithDuration:0.3 animations:^{
                self.encounterView.frame    = eRect;
                self.photoView.frame        = pRect;
                
            } completion:^(BOOL finished) {
                
            }];
        }
        
        self.photoView.photoList = photos.photos;
        
        int selectedPhoto = 0;
        for (NSDictionary * curInf in photos.photos)
        {
            NSString * photoId = [curInf objectForKey:kPhotoId];

            if ([photoId isEqualToString:currentProfilePhotoId])
            {
                break;
            }
            selectedPhoto++;
        }
        [self.photoView setSelectedPhoto:selectedPhoto];
    } onError:^(NSError * error) {
        [self performSelector:@selector(loadPhotos) withObject:nil afterDelay:1 ];
    }];
}
-(void) follow
{
    ApiFollowUser * follow = [[ApiFollowUser alloc] init];
    follow.user_id = username;
    [follow start:^(BOOL followed) {
        [self.encounterView setFollow:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userFollowUnfollow" object:nil];
    }];
}
-(void) unfollow
{
    ApiUnfollowUser * follow = [[ApiUnfollowUser alloc] init];
    follow.user_id = username;
    [follow start:^(BOOL followed) {
        [self.encounterView setFollow:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userFollowUnfollow" object:nil];
    }];
}
-(void) unblockUser
{
    ApiUnblockUser * unblock = [[ApiUnblockUser alloc] init];
    unblock.userId = username;
    [unblock start:^(BOOL success) {
        if (success)
        {
            [self.encounterView setFollow:NO];
        }
    }];
}

-(void)setMyPhoto
{
    [self.delegate setUserPhoto];
}

-(void) userButtonPressed
{
    self.mainHeader.titleButton.selected = !self.mainHeader.titleButton.selected;
    [self.delegate userButtonClicked];
}

-(void)showFollowers
{
    [self.delegate showFollowers];
}
-(void)showPhotos
{
    [self.delegate showPhotos];
}
-(void)showMentions
{
    [self.delegate showMentions];
}
-(void) setEncounterPhotos
{
    [self.encounterView setLeftButtonPhotos:totalPhotosCount];
}
-(void) setEncounterFollowers
{
    [self.encounterView setLeftButtonFollowers:followersCount];
}

@end