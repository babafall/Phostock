//
//  MainHeader.h
//  Phostock
//
//  Created by Roman Truba on 22.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LobsterLabel.h"
#import "UniversalImageView.h"
#import "UploadingView.h"
typedef enum EncounterButtonMode {
    EncounterButtonSetMyPhoto = 1,
    EncounterButtonFollow,
    EncounterButtonFollowing,
    EncounterButtonBlocked,
    EncounterButtonLeftFollowers,
    EncounterButtonLeftPhotos,
    } EncounterButtonMode;
//Верхняя плашка
@interface MainHeader : UIView <LobsterButtonDelegate>
{
    NSString * _titleText;
    
    void(^onBackButtonClick)(void);
    void(^onGridClicked)(BOOL);
}
@property (nonatomic, strong) IBOutlet UIImageView   * highlightImage;
@property (nonatomic, strong) IBOutlet LobsterButton * titleButton;
@property (nonatomic, strong) IBOutlet UIButton      * backButton;
@property (nonatomic, strong) IBOutlet UIButton      * gridButton;


@property (readwrite) NSString * titleText;

+(MainHeader*) getNewHeader;
-(void) showBackButton:(void(^)(void))onClick;
-(void) setGridCallback:(void(^)(BOOL))onClick;
@end

@interface UserPhotoView : UIView
@property (nonatomic, strong) IBOutlet UILabel * labelText;
@property (nonatomic, strong) PhotoViewer   * photosTable;
@property (nonatomic, strong) NSArray       * photoList;
@end

@protocol UserEncounterDelegate <NSObject>

-(void) follow;
-(void) unfollow;
-(void) unblockUser;
-(void) setMyPhoto;
-(void) showFollowers;
-(void) showPhotos;
-(void) showMentions;

@end

@interface UserEncounterView : UIView
{
    IBOutlet UILabel * followersLabel;
    IBOutlet UILabel * mentionsLabel;

    IBOutlet UILabel * leftTitle;
    IBOutlet UILabel * rightTitle;

    
    IBOutlet UIButton * mainButton;
    IBOutlet UIButton * unblockButton;
    
    EncounterButtonMode buttonMode;
    EncounterButtonMode leftButtonMode;
    
    int followersCount, mentionsCount;
}

@property (nonatomic, unsafe_unretained) id<UserEncounterDelegate> delegate;

-(void) setFollowersCount:(int) followersCount;
-(void) setMentionsCount:(int) mentionsCount;

-(void) setFollow:(BOOL) isFollowing;
-(void) setMyPhotoButton;

-(void) setLeftButtonPhotos:(int) count;
@end


@protocol UsersHeaderDelegate <NSObject>

-(void) usersHeaderResized;
-(void) userButtonClicked;
-(void) setUserPhoto;

-(void) showFollowers;
-(void) showPhotos;
-(void) showMentions;
@end

@interface UsersHeader : UIView <UserEncounterDelegate>
{
    NSString * username, * currentProfilePhotoId;
    
    BOOL following, followerOfMe, blocked, canFollow;
    
    int followersCount, followingCount, mentionsCount, totalPhotosCount;
}
@property (nonatomic, strong) MainHeader * mainHeader;
@property (nonatomic, strong) UserPhotoView * photoView;
@property (nonatomic, strong) UserEncounterView * encounterView;
@property (nonatomic, unsafe_unretained) id<UsersHeaderDelegate> delegate;

+(UsersHeader*) createUserHeader:(NSString*)userName;
-(void) loadUserInfo;
-(void) setEncounterPhotos;
-(void) setEncounterFollowers;
@end