//
//  PhotoEditController.h
//  Phostock
//
//  Created by Roman Truba on 27.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"
#import "EasyTableView.h"
#import "FilterImagesHolder.h"
#import "CustomSegmentControl.h"
#import "CaptionShadowFilter.h"
#import "DemotivationFilter.h"
#import "BlackLettersLabel.h"
#import "TrollFaceView.h"
#import "SuggestionView.h"
#import "MegafonView.h"

enum CaptionType {
    CaptionSimple = 1,
    CaptionDemotivator,
    CaptionPolaroid,
    CaptionAdvice
    };

@interface PhotoEditController : BaseController <UIScrollViewDelegate, EasyTableViewDelegate, UITextFieldDelegate, CustomSegmentControlDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, SuggestionsDelegate>
{
    IBOutlet UIScrollView   * mainScrollView;
    IBOutlet UIView         * imageViewForDragging;
    IBOutlet GPUImageView   * mainImageView;
    IBOutlet UIView         * clipperView;
    
    IBOutlet UIView         * imageMovingView;
    IBOutlet UITextView     * captionTextView;
    
    NSString * lastCaptionText;
        
    GPUImageOutput<GPUImageInput>   * filter;    EasyTableView                   * filtersView;
    FilterImagesHolder              * thumbsHolder;
    GPUImageAlphaBlendFilter        * blendFilter;
    
    IBOutlet UIScrollView           * captionTypeScrollView;
    NSArray                         * captionButtonsArray;
    BOOL                              firstFlip;
    enum CaptionType                  selectedCaption;
    
    GPUImagePicture                 * drawingPicture;
    GPUImageCropFilter              * cropToRectFilter;
    GPUImageTransformFilter         * transformFilter;
    GPUImageGaussianSelectiveBlurFilter * blurFilter;
    
    NSArray                         * tagsArray;
    NSRegularExpression             * tagsRegexp;
    
    float                             scaleAspect, minimumZoomLevel, maximumZoomLevel, currentBlurPointSize;
    CGFloat                           translationX, translationY, transformScale, aspectRatio;
    BOOL loadedNow, needInitialize, displayingPrimary, twoLinesInput, isAdviceMode, isScrolling, blurIsOn, suggestionMode;
    int currentLinesCount, captionFontSize, suggestionStartPosition, minimalCaptionLen;
    
}
@property (nonatomic, strong) IBOutlet UIButton * cancelButton;
@property (nonatomic, strong) IBOutlet UIButton * retakePhotoButton;
@property (nonatomic, strong) IBOutlet UIButton * saveButton;
@property (nonatomic, strong) IBOutlet UIButton * captionButton;
@property (nonatomic, strong) IBOutlet UIButton * returnButton;
@property (nonatomic, strong) IBOutlet UIButton * blurButton;
@property (nonatomic, strong) IBOutlet SuggestionView * suggestionView;
@property (nonatomic, strong) IBOutlet MegafonView * megafonView;
@property (nonatomic, assign) int filterNum;

@property (nonatomic, strong) UIImage * workingImage;
@property (nonatomic, strong) NSDictionary * photoInfoForResponse;
@property (nonatomic, assign) CGPoint cameraBlurPoint;
@property (nonatomic, assign) BOOL fromCamera;
@property (nonatomic, assign) BOOL makeUserPic;
@property (nonatomic, assign) BOOL canRetake;
@property (nonatomic, assign) BOOL cameraBlurIsOn;

@property (nonatomic, assign) float cameraBlurSize;

-(void) reinitialize;
@end
