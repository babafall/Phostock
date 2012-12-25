#import "UIFastLabel.h"
#import <QuartzCore/QuartzCore.h>
#import <pthread.h>

FastAttributedStringSize FastAttributedStringSizeMake(float w1, float h1)
{
    FastAttributedStringSize size;
    size.portraitSize = CGSizeMake(w1, h1);
    return size;
}

@implementation FastAttributedStringCustomLink

@synthesize url, range, resultType, stringUrl;

@end

@implementation FastAttributedString

@synthesize mutableLinks, attrString, drawSizeLandscape, drawSizePortrait, highligts, originalString;

- (void)dealloc
{
    if(attrString)
        CFRelease(attrString);
}

@end

static CFDictionaryRef whiteAttr = nil;
static CFDictionaryRef blackAttr = nil;
static CFDictionaryRef linkAttr = nil;
static CFDictionaryRef selectedLinkAttr = nil;
static UIColor *linkColor = nil;
static UIColor *selectedLinkColor = nil;

pthread_mutex_t mutex;

@implementation UIFastLabel

@synthesize attrString, delegate, drawOrientation, ignoreGestures, highlightImage = _highlightImage;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if((attrString && [self linkAtPoint:point]) || (!ignoreGestures && [self.gestureRecognizers count]) || (ignoreGestures && CGRectContainsPoint(self.bounds, point)))
        return self;
    return nil;
}

+ (void)createTextAttributes
{
    if(whiteAttr)
        return;
    pthread_mutex_init(&mutex, NULL);
    if(!whiteAttr)
    {
        CFStringRef cfKeys[] = {kCTForegroundColorAttributeName};
        CFTypeRef cfValues[] = {[UIColor whiteColor].CGColor};
        whiteAttr = CFDictionaryCreate(kCFAllocatorDefault, (const void **)cfKeys, (const void **)cfValues, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    if(!blackAttr)
    {
        CFStringRef cfKeys[] = {kCTForegroundColorAttributeName};
        CFTypeRef cfValues[] = {[UIColor blackColor].CGColor};
        blackAttr = CFDictionaryCreate(kCFAllocatorDefault, (const void **)cfKeys, (const void **)cfValues, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    if(!linkAttr)
    {
        linkColor = [UIColor colorWithRed:149.0/255 green:200.0/255 blue:0.9 alpha:1];
        CFStringRef cfKeys[] = {kCTForegroundColorAttributeName};
        CFTypeRef cfValues[] = {linkColor.CGColor};
        linkAttr = CFDictionaryCreate(kCFAllocatorDefault, (const void **)cfKeys, (const void **)cfValues, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    if(!selectedLinkAttr)
    {
        selectedLinkColor = [UIColor colorWithRed:149.0/255 green:200.0/255 blue:0.9 alpha:1];
        CFStringRef cfKeys[] = {kCTForegroundColorAttributeName};
        CFTypeRef cfValues[] = {selectedLinkColor.CGColor};
        selectedLinkAttr = CFDictionaryCreate(kCFAllocatorDefault, (const void **)cfKeys, (const void **)cfValues, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
        CALayer *layer = self.layer;
        [layer setNeedsDisplayOnBoundsChange:YES];
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        [UIFastLabel createTextAttributes];
    }
    return self;
}

- (void)awakeFromNib
{
    CALayer *layer = self.layer;
    [layer setNeedsDisplayOnBoundsChange:YES];
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    [UIFastLabel createTextAttributes];
}

- (void)dealloc
{
    if(framesetter)
        CFRelease(framesetter);
}
-(void)setHighlightImage:(UIImage *)highlightImage
{
    if (!_highlightImage)
    {
        _highlightImage = [highlightImage stretchableImageWithLeftCapWidth:3 topCapHeight:0];
    }
}

+ (FastAttributedStringSize)calculateSizeForAttributedString:(FastAttributedString *)string withMaxPortraitWidth:(float)mpw
{
    if(!string)
        return FastAttributedStringSizeMake(0, 0);
    [UIFastLabel createTextAttributes];
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(string.attrString);
    
    CGSize textSizePortrait = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFStringGetLength((CFStringRef)string.attrString)), NULL, CGSizeMake(mpw, 10000), NULL);    
    
    string.drawSizePortrait = CGSizeMake(mpw, ceil(textSizePortrait.height));
    FastAttributedStringSize returnResult = FastAttributedStringSizeMake(ceil(textSizePortrait.width), ceil(textSizePortrait.height));
        
    CFRelease(framesetter);
	return returnResult;
}

+ (FastAttributedString *)buildAttributedString:(NSString *)text withFont:(UIFont *)font andCustomLinks:(NSMutableArray *)links andHighlight:(NSString*) highlight
{
    if(!text.length)
        return nil;
    [UIFastLabel createTextAttributes];
    FastAttributedString *string = [[FastAttributedString alloc] init];

	NSMutableString *mString = [NSMutableString stringWithString:text];
	CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);

    CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), (__bridge CFStringRef)mString);
    string.attrString = attrString;
    
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    CFAttributedStringSetAttribute(string.attrString, CFRangeMake(0, CFStringGetLength((__bridge CFStringRef)mString)), kCTFontAttributeName, myFont);
    CFRelease(myFont);
    
    CGFloat leading = font.lineHeight - font.ascender + font.descender;

    CTTextAlignment alignment = kCTTextAlignmentCenter;
	CTParagraphStyleSetting settings[] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &leading},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
	};
        
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 2);
	CFAttributedStringSetAttribute(string.attrString, CFRangeMake(0, CFStringGetLength((CFStringRef)string.attrString)), kCTParagraphStyleAttributeName, paragraphStyle);
    CFRelease(paragraphStyle);
    
//    static NSDataDetector *dataDetector = nil;
//    if(!dataDetector)
//        dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber error:nil];
    string.mutableLinks = [[NSMutableArray alloc] init];

    if(links)
        [string.mutableLinks addObjectsFromArray:links];
    for(FastAttributedStringCustomLink *result in string.mutableLinks)
    {
        if(![links containsObject:result])
            CFAttributedStringSetAttribute(string.attrString, CFRangeMake(result.range.location, result.range.length), kCTUnderlineStyleAttributeName, (__bridge CFNumberRef)[NSNumber numberWithBool:YES]);
        CFAttributedStringSetAttributes(string.attrString, CFRangeMake(result.range.location, result.range.length), linkAttr, false);
    }
    
    if (highlight)
        string.highligts = [UIFastLabel highlightWords:text withWord:highlight];
    
    
    return string;
}
+ (NSArray *)highlightWords:(NSString *)src withWord:(NSString*) toHighlight
{
    if(!src)
        return nil;
    src = [src lowercaseString];
    NSMutableArray * array = [NSMutableArray new];
    NSRegularExpression *expUser = [NSRegularExpression regularExpressionWithPattern:[toHighlight lowercaseString] options:NSRegularExpressionSearch error:nil];
    int searchPos = 0;
    while(true)
    {
        NSTextCheckingResult *match = [expUser firstMatchInString:src options:0 range:NSMakeRange(searchPos, src.length - searchPos)];
        if(!match.numberOfRanges)
            break;
        NSString *result = [src substringWithRange:match.range];
        
        FastAttributedStringCustomLink *link = [[FastAttributedStringCustomLink alloc] init];
        link.stringUrl = result;
        link.range = NSMakeRange(match.range.location, match.range.length);
        link.resultType = NSTextCheckingTypeLink;
        [array addObject:link];
        searchPos = match.range.location + match.range.length;
    }
    return array;
}
- (void)setAttrString:(FastAttributedString *)str
{
    attrString = str;
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor withLinks:(BOOL)value
{
    if(attrString)
    {
        clickResult = nil;
        
        CFStringRef cfKeys[] = {kCTForegroundColorAttributeName};
        CFTypeRef cfValues[] = {textColor.CGColor};
        CFDictionaryRef custimAttr = CFDictionaryCreate(kCFAllocatorDefault, (const void **)cfKeys, (const void **)cfValues, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        CFAttributedStringSetAttributes(attrString.attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString.attrString)), custimAttr, false);
        if(value)
            for(FastAttributedStringCustomLink *result in attrString.mutableLinks)
                CFAttributedStringSetAttributes(attrString.attrString, CFRangeMake(result.range.location, result.range.length), linkAttr, false);
        [self setNeedsDisplay];
    }
}
- (void) hightlight:(CTFrameRef) frame context:(CGContextRef) context drawRect:(CGRect) rect
{
    CGRect hlFrame = self.frame;
    hlFrame.size = rect.size;    
    if (highlightView) [highlightView removeFromSuperview];
    highlightView = [[HighlightDrawer alloc] initWithFrame:hlFrame];
    highlightView.backgroundColor = [UIColor clearColor];
    highlightView.userInteractionEnabled = NO;
    [self.superview addSubview:highlightView];
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    
    for (FastAttributedStringCustomLink *link in attrString.highligts) {
        NSRange range = link.range;
//        NSLog(@"Cur range: %d %d", range.location, range.length);
        
        CGPoint origins[lines.count];//the origins of each line at the baseline
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
        int curOffset = 0;
        NSUInteger lineIndex = 0;
        for (int i = 0; i < lines.count; i++) {
//            NSLog(@"Line: %d", lineIndex);
            CTLineRef line = (__bridge CTLineRef)lines[i];
            int glyphs = CTLineGetGlyphCount(line);

            if (curOffset + glyphs <= range.location)
            {
                curOffset += glyphs;
                lineIndex++;
                continue;
            }
            
            //Здесь нужно взять высоту - по ней будем дравать
            CGRect lineRect;
            CGFloat ascent, descent;
            lineRect.size.width = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            lineRect.size.height = descent + ascent;
            lineRect.origin.x = origins[i].x;
            lineRect.origin.y = origins[i].y - descent;
            
//            lineRect.origin.x = (self.attrString.drawSizePortrait.width - lineRect.size.width) / 2;
//            CGFloat leftOffset = lineRect.size.width;//lineRect.origin.x + self.attrString.drawSizePortrait.width / 2;
            
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//            CGContextStrokeRect(context, lineRect);
            
            CGRect frameRect = lineRect;
            frameRect.size = CGSizeMake(0, lineRect.size.height);
            
            
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            
            int runCount = CFArrayGetCount(runs);
            int lineOffset = 0, lowerBorder = range.location - curOffset, upperBorder = (range.location + range.length) - curOffset;
            
            BOOL startFound = NO;
            CGFloat skipped = 0.0;
            for (int j = 0; j < runCount; j++)
            {
                CTRunRef curRun = CFArrayGetValueAtIndex(runs, j);
                CFRange runRange = CTRunGetStringRange(curRun);
                
                CGFloat ascent;//height above the baseline
                CGFloat descent;//height below the baseline
                 int runGlyphs = CTRunGetGlyphCount(curRun);
                CGRect typoBounds;
                typoBounds.size.width = CTRunGetTypographicBounds(curRun, CFRangeMake(0, 0), &ascent, &descent, NULL);
                typoBounds.size.height = ascent + descent;
                
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(curRun).location, NULL);
                typoBounds.origin.x = lineRect.origin.x + xOffset;
                typoBounds.origin.y = lineRect.origin.y;
                CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
//                CGContextStrokeRect(context, typoBounds);
                
                //Проверяем, что попали на нужный ран, т.е. подстрока где-то здесь
                if (lineOffset + runRange.length < lowerBorder)
                {
                    lineOffset += runGlyphs;
                    skipped += typoBounds.size.width;
                    continue;
                }
                if (lineOffset >= upperBorder)
                {
                    
                    lineOffset += runGlyphs;
                    continue;
                }
                int start = lowerBorder - lineOffset - (runRange.length - runGlyphs);
                if (start < 0) start = 0;
                int len = MIN(range.length, runRange.length);
                if (len + start > runRange.length) len = start - runRange.length;
                if (len < 0) len = runRange.length - start;
//                NSLog(@"Range 2: %d %d", start, len);
                CGRect bounds = CTRunGetImageBounds(curRun, context, CFRangeMake(start, len));
                bounds.size.width = CTRunGetTypographicBounds(curRun, CFRangeMake(start, len), &ascent, &descent, NULL);
                bounds.size.height = ascent + descent;
                
                if (bounds.size.width == 0)
                {
                    bounds = CTRunGetImageBounds(curRun, context, CFRangeMake(start, runGlyphs));
                    bounds.size.width = CTRunGetTypographicBounds(curRun, CFRangeMake(start, runGlyphs), &ascent, &descent, NULL);
                    bounds.size.height = ascent + descent;
                    
                    if (bounds.size.width == 0)
                    {
                        skipped += typoBounds.size.width;
                        lineOffset += runGlyphs;
                        continue;
                    }
                }
                int charIndex = CTRunGetStringRange(curRun).location + start;
                bounds.origin.x = CTLineGetOffsetForStringIndex(line, charIndex, NULL);
                bounds.origin.y = frameRect.origin.y;
                
                if (!startFound)
                {
                    frameRect.origin.x = lineRect.origin.x + bounds.origin.x;// - leftOffset;
                }
                startFound = YES;
                frameRect.size.width += bounds.size.width;
                 
                lineOffset += runRange.length;
                skipped += typoBounds.size.width;
            }
            curOffset += glyphs;
            if (startFound)
            {
                [highlightView addImage:_highlightImage drawInRect:frameRect];
//                [_highlightImage drawInRect:frameRect];
            }
        }
        lineIndex++;
        //break;
    }
}
- (void)drawRect:(CGRect)rect
{
    if (highlightView.superview)
    [highlightView removeFromSuperview];
    if(!attrString)
    {
        [super drawRect:rect];
        return;
    }
    
    bool useTruncated = false;

	CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, 1.0));
    CGContextSetShadowWithColor(context,
                                CGSizeMake(1, 1),
                                1,
                                [UIColor blackColor].CGColor);
	CGMutablePathRef path = CGPathCreateMutable();
    
    CGSize drawSize;
    drawSize = attrString.drawSizePortrait;
    
    if(!useTruncated)
        CGPathAddRect(path, NULL, CGRectMake(0, 0, drawSize.width, drawSize.height));
    
    if(framesetter)
        CFRelease(framesetter);
    
	framesetter = CTFramesetterCreateWithAttributedString(attrString.attrString);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
	CTFrameDraw(frame, context);
    
    if (attrString.highligts.count)
        [self hightlight:frame context:context drawRect:rect];
    CFRelease(path);
    CFRelease(frame);

    
//    if(useTruncated)
//    {
//        CGMutablePathRef pathTruncated = CGPathCreateMutable();
//        CTFramesetterRef framesetterTruncated = nil;
//
//        CTFrameRef frameTruncated = CTFramesetterCreateFrame(framesetterTruncated, CFRangeMake(0, 0), pathTruncated, NULL);
//        CFRelease(pathTruncated);
//        CTFrameDraw(frameTruncated, context);
//        CFRelease(frameTruncated);
//        CFRelease(framesetterTruncated);
//    }
    
//    [highlightView drawRect:rect];
}

#pragma mark - links

- (FastAttributedStringCustomLink *)linkAtCharacterIndex:(CFIndex)idx
{
    NSRange range;
    for(FastAttributedStringCustomLink *result in attrString.mutableLinks)
    {
        range = result.range;
        if((CFIndex)range.location <= idx && idx <= (CFIndex)(range.location + range.length - 1))
        {
            return result;
        }
    }
    return nil;
}

- (FastAttributedStringCustomLink *)linkAtPoint:(CGPoint)p
{
    CFIndex idx = [self characterIndexAtPoint:p];
    return [self linkAtCharacterIndex:idx];
}

- (CFIndex)characterIndexAtPoint:(CGPoint)p
{
    if(!CGRectContainsPoint(self.bounds, p))
        return NSNotFound;
    p = CGPointMake(p.x, self.bounds.size.height - p.y);
    CGMutablePathRef path = CGPathCreateMutable();
    CGSize drawSize;
    
    bool useTruncated = false;
    
    if(UIInterfaceOrientationIsLandscape(drawOrientation))
    {
        drawSize = attrString.drawSizeLandscape;
        if(drawSize.height > self.frame.size.height)
        {
            useTruncated = true;
        }
    }
    else
    {
        drawSize = attrString.drawSizePortrait;
        if(drawSize.height > self.frame.size.height)
        {
            useTruncated = true;
        }
    }
    if(!useTruncated)
        CGPathAddRect(path, NULL, CGRectMake(0, 0, drawSize.width, drawSize.height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, CFAttributedStringGetLength(attrString.attrString)), path, NULL);
    if(!frame)
    {
        CFRelease(path);
        return NSNotFound;
    }
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    if(!numberOfLines)
    {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    NSUInteger idx = NSNotFound;
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    for(CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++)
    {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        if(p.y > yMax)
            break;
        if(p.y >= yMin)
        {
            if(p.x >= lineOrigin.x && p.x <= lineOrigin.x + width)
            {
                CGPoint relativePoint = CGPointMake(p.x - lineOrigin.x, p.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                break;
            }
        }
    }
    CFRelease(frame);
    CFRelease(path);
    return idx;
}

#pragma mark - UIGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if(framesetter != nil && attrString != nil)
    {
        startPoint = [[touches anyObject] locationInView:self];
        clickResult = [self linkAtPoint:startPoint];
        if(clickResult)
        {
            NSRange range = clickResult.range;
            CFAttributedStringSetAttributes(attrString.attrString, CFRangeMake(range.location, range.length), selectedLinkAttr, false);

            [self setNeedsDisplay];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if(clickResult)
    {
        CGPoint endPoint = [[touches anyObject] locationInView:self];
        if(sqrtf((startPoint.x - endPoint.x) * (startPoint.x - endPoint.x) + (startPoint.y - endPoint.y) * (startPoint.y - endPoint.y)) <= 10.0f)
        {
            if([self.delegate respondsToSelector:@selector(fastLabel:didSelectLink:)])
            {
                [self.delegate fastLabel:self didSelectLink:clickResult];
            }
        }
        NSRange range = clickResult.range;
        CFAttributedStringSetAttributes(attrString.attrString, CFRangeMake(range.location, range.length), linkAttr, false);       
        [self setNeedsDisplay];
        clickResult = nil;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if(clickResult)
    {
        CFAttributedStringSetAttributes(attrString.attrString, CFRangeMake(clickResult.range.location, clickResult.range.length), linkAttr, false);
        [self setNeedsDisplay];
        clickResult = nil;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
