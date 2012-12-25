//
//  LobsterLabel.m
//  Phostock
//
//  Created by Roman Truba on 25.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "LobsterLabel.h"

@implementation LobsterLabel

-(void)awakeFromNib
{
    UIFont * pictoFont = [UIFont fontWithName:kLobsterFont size:self.font.pointSize];
    [self setFont:pictoFont];
}

@end
@implementation LobsterButton

-(void)awakeFromNib
{
    UIFont * pictoFont = [UIFont fontWithName:kLobsterFont size:self.titleLabel.font.pointSize];
    [self.titleLabel setFont:pictoFont];
}
-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self.delegate buttonHighlighted:highlighted];
}
@end
