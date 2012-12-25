//
//  PhotoEditController.m
//  Phostock
//
//  Created by Roman Truba on 27.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoEditController.h"
#import "EasyTableView.h"
#import "StandardFilters.h"
#import "BorderedButton.h"
#import "TrollFaceView.h"
#import "AFNetworking.h"
#import "NetWorker.h"

//static int IMAGE_VIEW_MAX_Y = 210;
//static int IMAGE_VIEW_MIN_Y = 0;

static int MAX_LINES = 2;
static NSString * DELIMITER = @"\u2795";
@implementation PhotoEditController
@synthesize retakePhotoButton, saveButton, captionButton;
@synthesize workingImage, filterNum;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        thumbsHolder = [FilterImagesHolder getInstance];
        needInitialize = YES;
        self.wantsFullScreenLayout = YES;
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated
{
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    loadedNow = YES;
    
    self.secondaryView.frame = self.view.frame;
    if (self.photoInfoForResponse)
    {
        self.megafonView.hidden = NO;
    }
    else
    {
        self.megafonView.hidden = YES;
    }

    [self configureButton:self.saveButton withImageName:@"SaveBtn"];
    [self configureButton:self.retakePhotoButton withImageName:@"ActionBtn"];
    [self configureButton:self.captionButton withImageName:@"ActionBtn"];
    [self configureButton:self.cancelButton withImageName:@"ActionBtn"];
    [self configureButton:self.returnButton withImageName:@"ActionBtn"];
    [self configureButton:self.captionButton withImageName:@"CaptionBtn"];
    [self configureButton:self.blurButton withImageName:@"CaptionBtn"];
    
    if (!self.canRetake)
    {
        self.cancelButton.hidden = YES;
        [self.retakePhotoButton setTitle:@"Cancel" forState:UIControlStateNormal];
    }
    if (!filtersView)
    {
        [self createFiltersView];
    }
    if (needInitialize)
    {
        [self reinitialize];
        needInitialize = NO;
    }
    captionFontSize = MAX_FONT_SIZE;
    captionTextView.font  = [UIFont fontWithName:kLobsterFont size:MAX_FONT_SIZE];
    
    NSString *expression = @"#[a-zA-Zа-яА-Я0-9._-]+";
    tagsRegexp = [NSRegularExpression regularExpressionWithPattern:expression options:0 error:NULL];
    if (self.makeUserPic)
    {
        [self captionButtonClicked:nil];
        captionTextView.text = @"#me ";
    }
    
    minimalCaptionLen = 0;
    if (self.photoInfoForResponse)
    {
        [self captionButtonClicked:nil];
        NSLog(@"%@", [self.photoInfoForResponse objectForKey:kUserInfo]);
        captionTextView.text = [NSString stringWithFormat:@"@%@ ", [[self.photoInfoForResponse objectForKey:kUserInfo] objectForKey:@"login"] ];
    }
    minimalCaptionLen = captionTextView.text.length - 1;
    
    UITapGestureRecognizer * tapReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurTap:)];
    tapReco.delegate = self;
    [mainScrollView addGestureRecognizer:tapReco];
    
    UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(blurPinch:)];
    pinch.delegate = self;
    [mainScrollView addGestureRecognizer:pinch];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!blurIsOn) return NO;
    return YES;
}
-(void) blurPinch:(UIPinchGestureRecognizer*) sender {
    
    if (sender.state == UIGestureRecognizerStateChanged)
    {
//        NSLog(@"%f", sender.scale);
        [blurFilter setExcludeCircleRadius:currentBlurPointSize * sender.scale];
        [self fastRedraw];
    }
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        currentBlurPointSize *= sender.scale;
    }
}
-(void) blurTap:(UITapGestureRecognizer*) sender {
    if (!blurIsOn) return;
    if (sender.state == UIGestureRecognizerStateEnded)
    {        
        CGPoint point = [sender locationInView:clipperView];
//        NSLog(@"%f %f", point.x, point.y);
        
        blurFilter.blurPoint = CGPointMake(point.x / clipperView.frame.size.width, point.y / clipperView.frame.size.height);
        [self fastRedraw];
    }

}
-(IBAction) switchBlur:(id) sender
{
    blurIsOn = !blurIsOn;
    if (blurIsOn)
    {
        [self.blurButton setImage:[UIImage imageNamed:@"Blur_active"] forState:UIControlStateNormal];
        
    }
    else
    {
        [self.blurButton setImage:[UIImage imageNamed:@"Camera_Blur"] forState:UIControlStateNormal];

    }
    mainScrollView.scrollEnabled = !blurIsOn;
    if (blurIsOn)
    {
        mainScrollView.minimumZoomScale = mainScrollView.maximumZoomScale = mainScrollView.zoomScale;
    }
    else
    {
        mainScrollView.minimumZoomScale = minimumZoomLevel;
        mainScrollView.maximumZoomScale = maximumZoomLevel;
    }
    [self drawImageWithCurrentSettings];
}

-(void) reinitialize
{
    displayingPrimary = YES;
//    NSDate * now = [NSDate date], *tt = [NSDate date];
    if (workingImage)
    {
        
        workingImage = [self scaleAndRotateImage:workingImage];
//        tt = [NSDate date];
//        NSLog(@"Scale and rotate: %f", tt.timeIntervalSince1970 - now.timeIntervalSince1970);
        
        CGSize size = workingImage.size;
        imageViewForDragging.frame = CGRectMake(0, 0, size.width, size.height);
        imageViewForDragging.hidden = YES;
        
        scaleAspect = mainScrollView.frame.size.width / MIN(size.width, size.height);
        mainScrollView.contentSize = size;
        minimumZoomLevel = mainScrollView.minimumZoomScale = scaleAspect;
        maximumZoomLevel = mainScrollView.maximumZoomScale = scaleAspect * 4;
        
        
        CGFloat minEdge = MIN(size.width, size.height);
        CGFloat maxEdge = MAX(size.width, size.height);
        CGPoint offset;
                
        offset = CGPointMake(maxEdge / 2, maxEdge / 2);
        [mainScrollView zoomToRect:[self zoomRectForScale:scaleAspect withCenter:offset] animated:NO];
        offset.x = (size.width - minEdge ) / 2;
        offset.y = (size.height - minEdge) / 2;
//        [self.retakePhotoButton setTitle:@"Cancel" forState:UIControlStateNormal];
        
        mainScrollView.zoomScale = scaleAspect;
        
        aspectRatio = minEdge / maxEdge;
        CGRect initCropRect = CGRectMake(offset.x / size.width ,
                                         offset.y / size.height, 0, 0);
        
        if ((int)minEdge == (int)size.width) {
            initCropRect.size.width = 1;
            initCropRect.size.height = aspectRatio;
        }
        else {
            initCropRect.size.width = aspectRatio;
            initCropRect.size.height = 1;
        }
        cropToRectFilter = [[GPUImageCropFilter alloc] initWithCropRegion:initCropRect];
        [cropToRectFilter prepareForImageCapture];

        transformFilter = [[GPUImageTransformFilter alloc] init];
        scaleAspect = 1 / scaleAspect;
        transformScale = 1.0;
        CGAffineTransform resizeTransform = CGAffineTransformMakeScale(transformScale, transformScale);
        transformFilter.affineTransform = resizeTransform;
        [transformFilter prepareForImageCapture];
        
        drawingPicture = [[GPUImagePicture alloc] initWithImage:workingImage];
        [drawingPicture prepareForImageCapture];
        if (!filter)
        {
            filter = [[GPUImageBrightnessFilter alloc] init];
            [filter prepareForImageCapture];
        }

        currentBlurPointSize = 0.2f;
        blurFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
        
        [blurFilter setExcludeCircleRadius:currentBlurPointSize];
        [blurFilter prepareForImageCapture];
        if (self.cameraBlurIsOn)
        {
            [self switchBlur:nil];
            blurFilter.blurPoint = self.cameraBlurPoint;
            [blurFilter setExcludeCircleRadius:self.cameraBlurSize];
        }
        
        [self drawImageWithCurrentSettings];
    }
    UIView * v = self.view; v = nil;
    [filtersView selectCellAtIndexPath:[NSIndexPath indexPathForRow:filterNum inSection:0] animated:YES];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"Photo edit disappear");
    [super viewDidDisappear:animated];
    [filtersView deselectAll];
    [self clearAll];
}

#pragma mark Presets

#pragma mark Scroll and zoom

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageViewForDragging;
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView  willDecelerate:(BOOL)decelerate{
    if (decelerate) return;
    isScrolling = NO;
    
    [self drawImageWithCurrentSettings];
}
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    isScrolling = NO;
    [self drawImageWithCurrentSettings];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isScrolling = YES;
    [self drawImageWithCurrentSettings];
}
-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    isScrolling = YES;
    [self drawImageWithCurrentSettings];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != mainScrollView) return;
    CGPoint offset = scrollView.contentOffset;
    CGSize size = scrollView.contentSize;
    CGFloat scrollViewWidth = scrollView.frame.size.width,
            scrollViewHeight = scrollView.frame.size.height;
    translationX = 0;
    float a = size.width - scrollViewWidth, b = size.height - scrollViewWidth;
    if ((int)size.width != (int)scrollViewWidth) {
        translationX = (a / scrollViewWidth) * (0.5f - offset.x / a) * 2;
    }
    translationY = 0;
    if ((int)size.height != (int)scrollViewHeight) {
        translationY = (b / scrollViewWidth) * (0.5f - offset.y / b) * 2;// * aspectRatio;
    }
    if (size.height < size.width)
    {
        translationX *= aspectRatio;
        translationY *= aspectRatio;
    }
    CGAffineTransform resizeTransform = CGAffineTransformMakeScale(scrollView.zoomScale / scrollView.minimumZoomScale, scrollView.zoomScale / scrollView.minimumZoomScale);
    resizeTransform.tx = translationX;
    resizeTransform.ty =  translationY;
    transformFilter.affineTransform = resizeTransform;
    [self fastRedraw];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = [mainScrollView frame].size.height / scale;
    zoomRect.size.width = [mainScrollView frame].size.width / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2);
    return zoomRect;
}
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    isScrolling = YES;
    [self drawImageWithCurrentSettings];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    isScrolling = NO;
    [self drawImageWithCurrentSettings];
}

#pragma mark Text and caption

-(void) finishInput
{
    [captionTextView resignFirstResponder];
    CGRect frame = imageMovingView.frame;
    frame.origin.y = [BaseController hasFourInchDisplay] ? 44 : 0;
    [self animateMainImageTo:frame];
    if (captionTextView.text.length == 0)
    {
        captionButton.hidden = NO;
        captionTextView.hidden = YES;
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self finishInput];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self captionButtonClicked:nil];
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.captionButton.hidden)
        [self captionButtonClicked:nil];
}
-(void)textViewDidChange:(UITextView *)textView
{
    UIFont * font = captionTextView.font;
    int size = MAX_FONT_SIZE;
    NSString * string = textView.text;
    
    [self findOptimalFontSize:string fontSizeRef:&size font:font];
    captionTextView.font = [captionTextView.font fontWithSize:size];
}
-(BOOL) findOptimalFontSize:(NSString*)text fontSizeRef:(int*) fontSize font:(UIFont*) font;
{
    int minSize = 20, curSize = MAX_FONT_SIZE;
    for (int i = curSize; i >= minSize; i--)
    {
        font = [font fontWithSize:i];
        CGSize size = [text sizeWithFont:font
                         constrainedToSize:CGSizeMake(270, 300)
                             lineBreakMode:UILineBreakModeWordWrap]; // default mode
        float numberOfLines = size.height / font.lineHeight;
        if (numberOfLines < MAX_LINES ||
            (numberOfLines < MAX_LINES + 1 && i == minSize)) {
            *fontSize = i;

            return YES;
        }
    }
    return NO;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length == 0 && textView.text.length == minimalCaptionLen) return NO;
    if ([text isEqualToString:@"\n"])
    {
        [self finishInput];
        [self hideSuggestionTable];
        return NO;
    }
    if ([text isEqualToString:@"@"])
    {
        suggestionStartPosition = range.location + 1;
        [self showSuggestionTable];
    }
    if ([text isEqualToString:@" "] && suggestionMode)
    {
        [self hideSuggestionTable];
    }
    if (text.length == 0 && [[textView.text substringWithRange:range] isEqualToString:@"@"] && suggestionMode)
    {
        [self hideSuggestionTable];
    }
    

    UIFont *font = textView.font;
    int size = font.pointSize;
    NSString* string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (suggestionMode)
    {
        [self.suggestionView filterSuggestions:[string substringFromIndex:suggestionStartPosition]];
    }
    if ([self findOptimalFontSize:string fontSizeRef:&size font:font])
    {
        captionFontSize = size;
        return YES;
    }

    return NO;
}
- (IBAction) captionButtonClicked:(id)sender
{
    [captionTextView becomeFirstResponder];
    captionButton.hidden = YES;
    captionTextView.hidden = NO;
    
    CGRect clipRect     = clipperView.frame;
    CGRect  moveRect    = imageMovingView.frame;
    float origin =  (self.view.frame.size.height - 216) - (clipRect.origin.y + clipRect.size.height);
    moveRect.origin.y = origin;
    [self animateMainImageTo:moveRect];
}
-(void) animateMainImageTo:(CGRect) rect
{
    if (rect.origin.y != imageMovingView.frame.origin.y)
    {
        [UIView animateWithDuration:0.3 animations:^{
            imageMovingView.frame = rect;
        }];
    }
}

#pragma mark Filters
- (void) createFiltersView
{
    CGRect recentRect = CGRectMake(0, 0, 320, 68);
    filtersView = [[EasyTableView alloc] initWithFrame:recentRect numberOfColumns:0 ofWidth:66];
    filtersView.delegate						= self;
	filtersView.tableView.backgroundColor       = [UIColor clearColor];
	filtersView.tableView.allowsSelection       = YES;
	filtersView.tableView.separatorColor		= [UIColor clearColor];
	filtersView.cellBackgroundColor             = [UIColor clearColor];
	filtersView.autoresizingMask				= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    filtersView.selectedMask                    = thumbsHolder.selectedFilterMask;
    filtersView.backgroundColor = [UIColor clearColor];
    [imageMovingView addSubview:filtersView];
}


-(NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section
{
    return thumbsHolder.filtersThumbs.count;
}
- (CGSize)   easyTableView:(EasyTableView *)easyTableView sizeForImageAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(65, 65);
}
- (UIImage*) easyTableView:(EasyTableView *)easyTableView imageForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return [thumbsHolder.filtersThumbs objectAtIndex:indexPath.row];
}
-(void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView
{
    [easyTableView reloadData];
    [self selectFilterAt:indexPath.row];
}
-(void) selectFilterAt:(int) index
{
    [filter removeAllTargets];
    filter = [thumbsHolder getFilterAtIndex:index];
    [self drawImageWithCurrentSettings];
}

#pragma mark Drawing

-(void) recreateBlend
{

    [blendFilter removeAllTargets];
    blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    [blendFilter prepareForImageCapture];
    blendFilter.mix = 1.0;
    [blendFilter addTarget:mainImageView];
    
}
-(void) drawImageWithCurrentSettings
{    
    [transformFilter removeAllTargets];
    [cropToRectFilter removeAllTargets];
    [drawingPicture removeAllTargets];
    [filter removeAllTargets];
    [blurFilter removeAllTargets];
    
    [drawingPicture addTarget:transformFilter];
    [transformFilter addTarget:cropToRectFilter];
    mainImageView.hidden = NO;
    if (isScrolling)
    {
        [cropToRectFilter addTarget:mainImageView];
        [self fastRedraw];
        return;
    }
    [cropToRectFilter addTarget:filter];
    
    if (mainImageView) {
        if (blurIsOn)
        {
            [filter addTarget:blurFilter];
            [blurFilter addTarget:mainImageView];
        }
        else
        {
            [filter addTarget:mainImageView];
        }
    }

    [self fastRedraw];
    
    
}
-(void) fastRedraw
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [drawingPicture processImage];
    });
}
#pragma mark Actions
- (IBAction) retakeButtonClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction) cancelButtonClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction) saveButtonClicked:(id)sender
{
    [(UIButton*)sender setEnabled:NO];
    UIImage * img = nil;
    [self drawImageWithCurrentSettings];
    [drawingPicture processImage];
    if (blurIsOn)
    {
        img = [blurFilter   imageFromCurrentlyProcessedOutput];
    }
    else
    {
        img = [filter       imageFromCurrentlyProcessedOutput];
    }

    [self clearAll];
    
    NSString * caption = captionTextView.text;
    
    NSMutableDictionary * params = [@{ kPhoto : img, kCaption : caption} mutableCopy];
    if (self.photoInfoForResponse)
    {
        params[kReplyId]  = [self.photoInfoForResponse objectForKey:kPhotoId];
        params[kIsPublic] = @([self.megafonView isSelected]);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoCreatedEvent object:params];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark Death

-(void)viewDidUnload
{
    mainImageView = nil;
    mainScrollView = nil;
    self.retakePhotoButton = nil;
    self.saveButton = nil;
    self.captionButton = nil;
    
    loadedNow = NO;
    
    [self clearAll];
    [super viewDidUnload];
}
- (void) dealloc
{
    NSLog(@"Photo edit dealloc");
    
    [self clearAll];
}
-(void) clearAll
{
    workingImage = nil;
    
    [filter removeAllTargets];
    filter = nil;
    
    [blendFilter removeAllTargets];
    blendFilter = nil;
    
    [cropToRectFilter removeAllTargets];
    cropToRectFilter = nil;
    
    [transformFilter removeAllTargets];
    transformFilter = nil;
    
    [drawingPicture removeAllTargets];
    drawingPicture = nil;
    
    mainImageView.hidden = YES;
}
-(void) showSuggestionTable
{
    suggestionMode = YES;
    if (self.suggestionView.hidden)
    {
        self.suggestionView.hidden = NO;
        self.suggestionView.alpha = 0;
        self.suggestionView.delegate = self;
        [UIView animateWithDuration:0.3 animations:^{
            self.suggestionView.alpha = 1;
        }];
    }
}
-(void) hideSuggestionTable
{
    suggestionMode = NO;
    if (!self.suggestionView.hidden )
    {
        self.suggestionView.alpha = 1;
        [UIView animateWithDuration:0.3 animations:^{
            self.suggestionView.alpha = 0;
        } completion:^(BOOL finished) {
            self.suggestionView.hidden = YES;
        }];
    }
}
-(void)suggestionSelected:(NSString *)suggestion
{
    [self hideSuggestionTable];
    //Найти, сколько символов заменить
    NSString * string = captionTextView.text;
    NSRange range = [string rangeOfString:@" " options:0 range:NSMakeRange(suggestionStartPosition, string.length - suggestionStartPosition)];
    if (range.location == NSNotFound) range = NSMakeRange(suggestionStartPosition, string.length - suggestionStartPosition);
    string = [[string stringByReplacingCharactersInRange:range withString:suggestion] stringByAppendingString:@" "];
    
    captionTextView.text = string;
    [self textViewDidChange:captionTextView];
}
@end
