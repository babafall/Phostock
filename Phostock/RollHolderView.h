//
//  RollHolderView.h
//  Phostock
//
//  Created by Roman Truba on 11.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RollHolderView : UIView

@property (nonatomic, strong) IBOutlet UIButton * buttonTop;
@property (nonatomic, strong) IBOutlet UIButton * buttonBottom;
@property (nonatomic, strong) IBOutlet UIView   * rollView;

-(void) activateTop;
-(void) activateBottom;
@end
