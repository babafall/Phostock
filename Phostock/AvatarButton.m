//
//  AvatarButton.m
//  Phostock
//
//  Created by Roman Truba on 24.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "AvatarButton.h"
#import "UIImageView+AFNetworking.h"
@implementation AvatarButton
@synthesize additionalLabels, addProfilePictureView, avatarImageView;
-(void)awakeFromNib
{
    [super awakeFromNib];
    if (!avatarImageView) {
        avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 6, 35, 35)];
        avatarImageView.userInteractionEnabled = NO;
        [self addSubview:avatarImageView];
    }
    
    
    if (addProfilePictureView)
        [self addSubview:addProfilePictureView];
}
-(void)setHighlighted:(BOOL)highlighted
{
    UIImage * hl = [self backgroundImageForState:UIControlStateHighlighted], *normal = [self backgroundImageForState:UIControlStateNormal];
    [super setHighlighted:highlighted];
    [avatarImageView setHighlighted:highlighted];
    
    if (hl == normal) return;
    if (additionalLabels.count)
    {
        for (UILabel * label in additionalLabels) {
            [label setHighlighted:highlighted];
        }
    }
}
-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [avatarImageView setHighlighted:selected];
}
-(UIImage*) drawImage:(UIImage*) img withBorder:(UIImage*) border
{
    CGSize newSize = border.size;
    UIGraphicsBeginImageContext( newSize );
    
    CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height), imgRect = CGRectMake(0, 0, newSize.width, newSize.height);
    
    imgRect.origin.x += 2;
    imgRect.origin.y += 2;
    imgRect.size.width -= 4;
    imgRect.size.height -= 4;
    [img drawInRect:imgRect];
    
    [border drawInRect:rect];
    
    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

-(void) setAvatarImageUrl:(NSString*) avatarImage
{
    if (avatarImage) {
        self.addProfilePictureView.hidden = YES;
        self.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        self.avatarImageView.highlightedImage = nil;
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:avatarImage]
                                maskImage:[UIImage imageNamed:@"FeedAvatarMask"]
                                 callback:^(BOOL successfull) {
//                                     if (successfull)
//                                     {
//                                         UIImage * img = self.avatarImageView.image;
//                                         UIImage * border = [UIImage imageNamed:@"PostPhoto"];
//                                         UIImage * borderActive = [UIImage imageNamed:@"PostPhoto_active"];
//                                         
//                                         border = [weakSelf drawImage:img withBorder:border];
//                                         borderActive = [weakSelf drawImage:img withBorder:borderActive];
//                                         
//                                         weakSelf.avatarImageView.image = border;
//                                         weakSelf.avatarImageView.highlightedImage = borderActive;
//                                     }
                                 }];
        
    }
    else
    {
        self.addProfilePictureView.hidden = NO;
        self.titleEdgeInsets = UIEdgeInsetsMake(-27, 0, 0, 0);
        self.avatarImageView.image = [UIImage imageNamed:@"AvatarPlace"];
        self.avatarImageView.highlightedImage = [UIImage imageNamed:@"AvatarPlace_Pressed"];
    }
}

@end
