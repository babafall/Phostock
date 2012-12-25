//
//  HeaderMovePannel.h
//  Phostock
//
//  Created by Roman Truba on 08.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderMovePannel : UIView
{
    BOOL visible;
}
@property (nonatomic, strong) IBOutlet UIView * movePannel;
@property (nonatomic, strong) IBOutlet UIButton * actionButton;
@property (nonatomic, strong) IBOutlet UIButton * cancelButton;



-(void) show;
-(void) hide;
-(BOOL) toggle;

@end
