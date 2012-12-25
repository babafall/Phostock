//
//  TabButton.m
//  Phostock
//
//  Created by Roman Truba on 18.11.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "TabButton.h"
#import "NetworkTabbedController.h"
@implementation BadgeLabel
@synthesize valueLabel, backgroundImage;
-(id)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        UIImage * image = [[UIImage imageNamed:@"Notify"] stretchableImageWithLeftCapWidth:11 topCapHeight:5];
        backgroundImage = [[UIImageView alloc] initWithImage:image];
        [self addSubview:backgroundImage];
        
        valueLabel = [[UILabel alloc] init];
        valueLabel.font = [UIFont boldSystemFontOfSize:10];
        valueLabel.backgroundColor = [UIColor clearColor];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.textColor = [UIColor whiteColor];
        [self addSubview:valueLabel];
        
        [self setValue:0];
        self.userInteractionEnabled = NO;
        
    }
    return self;
}
-(void)willMoveToSuperview:(UIView *)newSuperview
{
    self.frame = RectSetX(self.frame, newSuperview.frame.size.width - 25);
}
-(void)setValue:(int)value
{
    if (value == 0)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        }];
        return;
    }
    self.hidden = NO;
    static int margin = 9, marginTop = 5;
    valueLabel.text = [@(value) stringValue];
    [valueLabel sizeToFit];
    CGRect vr = valueLabel.frame;
    vr = RectSetOrigin(vr, 0, 0);
    
    CGRect ir = RectSetSize(vr, vr.size.width + margin * 2, 25);
    if (ir.size.width < ir.size.height) ir.size.width = ir.size.height;
    
    
    vr = RectSetOrigin(vr, margin, marginTop );
    [valueLabel sizeThatFits:ir.size];
    valueLabel.frame = vr;
    
    [UIView animateWithDuration:0.3 animations:^{
        backgroundImage.frame = ir;
        self.alpha = 1;
        self.frame = RectSetOrigin(ir, RectWidth(self.superview.frame) - RectWidth(ir), 0);
    }];
    
}
@end

@implementation TabButton

-(void)awakeFromNib
{
    self.isVisible = YES;
    UIImage * bottomSelectImage = [UIImage imageNamed:@"BottomSelected"];
    CGFloat ratio = bottomSelectImage.size.width / RectWidth(self.frame);
    CGFloat h = bottomSelectImage.size.height / ratio;
    CGRect fr = RectSetOrigin(self.frame, 0, (RectHeight(self.frame) - h));

    selectImageView = [[UIImageView alloc] initWithFrame:fr];
    [self addSubview:selectImageView];
    
    // the space between the image and text
    CGFloat spacing = -2.0;
    
    // get the size of the elements here for readability
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    // lower the text and push it left to center it
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // the text width might have changed (in case it was shortened before due to
    // lack of space and isn't anymore now), so we get the frame size again
    titleSize = self.titleLabel.frame.size;
    
    // raise the image and push it right to center it
    self.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    BadgeLabel * bl = [[BadgeLabel alloc] init];
    bl.tag = 1000;
    bl.alpha = 0;
    [self addSubview:bl];
    
}
-(void) setBadgeValue:(int)value
{
    BadgeLabel * bl = (BadgeLabel *)[self viewWithTag:1000];
    [bl setValue:value];
    
    if (value > 0 && !self.isVisible)
    {
        [self.parentController showTabButton:self];
    }
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    selectImageView.hidden = !selected;
}

@end
