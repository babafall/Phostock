//
//  LobsterLabel.h
//  Phostock
//
//  Created by Roman Truba on 25.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LobsterLabel : UILabel

@end

@protocol LobsterButtonDelegate <NSObject>

-(void) buttonHighlighted:(BOOL) highlight;
@end
@interface LobsterButton: UIButton
@property (nonatomic, unsafe_unretained) IBOutlet id<LobsterButtonDelegate> delegate;
@end