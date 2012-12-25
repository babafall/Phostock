//
//  PhotoCells.h
//  Phostock
//
//  Created by Roman Truba on 26.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UniversalImageView.h"
@protocol PhotoHeaderDelegate <NSObject>

-(void) headerSelectedUser:(NSString*) nick;

@end
@interface PhotoHeader : UIView
@property (nonatomic, strong) IBOutlet UILabel * usernameLabel;
@property (nonatomic, strong) IBOutlet UILabel * timestampLabel;
@property (nonatomic, strong) IBOutlet UIButton * headerButton;
@property (nonatomic, strong) IBOutlet UIImageView * userAvatarView;
@property (nonatomic, strong) IBOutlet UIImageView * replyAvatarView;

@property (nonatomic, unsafe_unretained) id<PhotoHeaderDelegate> delegate;
@end

@interface MainPhotoCell : UITableViewCell

@property (nonatomic, strong) IBOutlet PhotoHeader  * photoHeader;
@property (nonatomic, strong) IBOutlet PhotoViewer  * photoViewer;

@property (nonatomic, assign) BOOL dontHideActivity;

-(void) showUploadMark;
@end

@interface FollowersHeader : UIView

@property (nonatomic, strong) IBOutlet UILabel * encounter;
@property (nonatomic, strong) IBOutlet UILabel * textLabel;

-(void) setCount:(int)count ofText:(NSString*) text;

@end

@interface PhotoCells : NSObject
@property (nonatomic, unsafe_unretained) IBOutlet MainPhotoCell * mainPhotoCell;
@property (nonatomic, unsafe_unretained) IBOutlet PhotoHeader   * sectionHeader;
@property (nonatomic, unsafe_unretained) IBOutlet UITableViewCell * loadingCell;
@property (nonatomic, unsafe_unretained) IBOutlet UITableViewCell * emptyCell;
@property (nonatomic, unsafe_unretained) IBOutlet FollowersHeader * followersHeader;

+(MainPhotoCell*) getMainPhotoCell;
+(PhotoHeader*) getSectionHeader;
+(UITableViewCell*) getLoadingCell;
+(UITableViewCell*) getEmptyCell;
+(FollowersHeader*) getFollowersHeader;
@end


