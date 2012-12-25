#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "HighlightDrawer.h"
@class UIFastLabel;
@class FastAttributedStringCustomLink;

struct FastAttributedStringSize
{
    CGSize portraitSize;
};

typedef struct FastAttributedStringSize FastAttributedStringSize;

inline FastAttributedStringSize FastAttributedStringSizeMake(float w1, float h1);

@protocol UIFastLabelDelegate <NSObject>

@optional
- (void)fastLabel:(UIFastLabel *)label didSelectLink:(FastAttributedStringCustomLink *)link;

@end

@interface FastAttributedStringCustomLink : NSObject

@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *stringUrl;
@property (nonatomic, assign) NSTextCheckingType resultType;

@end

@interface FastAttributedString : NSObject

@property (nonatomic, assign) CFMutableAttributedStringRef attrString;
@property (nonatomic, assign) CGSize drawSizePortrait;
@property (nonatomic, assign) CGSize drawSizeLandscape;
@property (nonatomic, strong) NSMutableArray *mutableLinks;
@property (nonatomic, strong) NSArray *highligts;
@property (nonatomic, strong) NSString *originalString;

@end

@interface UIFastLabel : UIControl <UIGestureRecognizerDelegate>
{
    CTFramesetterRef framesetter;
    FastAttributedStringCustomLink *clickResult;
    CGPoint startPoint;
    HighlightDrawer * highlightView;
}

@property (nonatomic, assign) UIInterfaceOrientation drawOrientation;
@property (nonatomic, unsafe_unretained) id<UIFastLabelDelegate> delegate;
@property (nonatomic, assign) bool ignoreGestures;
@property (nonatomic, strong) FastAttributedString *attrString;
@property (nonatomic, strong) UIImage * highlightImage;

+ (FastAttributedStringSize)calculateSizeForAttributedString:(FastAttributedString *)string withMaxPortraitWidth:(float)mpw;
+ (FastAttributedString *)buildAttributedString:(NSString *)text withFont:(UIFont *)font andCustomLinks:(NSMutableArray *)links andHighlight:(NSString*) highlight;
- (void)setTextColor:(UIColor *)textColor withLinks:(BOOL)value;

@end
