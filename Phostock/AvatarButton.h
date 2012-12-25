//
//  AvatarButton.h
//  Phostock
//
//  Created by Roman Truba on 24.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvatarButton : UIButton
{
@public
    IBOutlet UIImageView * avatarImageView;
    IBOutlet UIView * addProfilePictureView;
    IBOutletCollection(UILabel) NSArray * additionalLabels;
}
@property (nonatomic, strong) IBOutlet UIImageView * avatarImageView;
@property (nonatomic, strong) IBOutlet UIView * addProfilePictureView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray * additionalLabels;

-(void) setAvatarImageUrl:(NSString*) avatarImage;

@end
