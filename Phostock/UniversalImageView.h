//
//  UniversalImageView.h
//  Phostock
//
//  Created by Roman Truba on 04.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomProgressBar.h"
#import "UIFastLabel.h"

@interface UniversalImageView : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView * mainImageView;
@property (nonatomic, strong) IBOutlet UIImageView * disclosureView;
@property (nonatomic, strong) IBOutlet UIImageView * uploadedMarkView;
@property (nonatomic, strong) IBOutlet UIImageView * captionMask;
@property (nonatomic, strong) IBOutlet CustomProgressBar * progressBar;
@property (nonatomic, strong) IBOutlet UIFastLabel * captionView;

+(UniversalImageView*) getNew;

-(void)setPhotoInfo:(NSDictionary*) photoInfo withDelegate:(id<UIFastLabelDelegate>) delegate;
@end

@class PhotoViewer;
@protocol PhotoViewerDelegate <NSObject>

-(void) photoViewer:(PhotoViewer*) viewer loadHistoryForId:(NSString*) photoId;
-(void) photoViewer:(PhotoViewer*) viewer didSelectSmallView:(int) index photoInfo:(NSDictionary*) photoInfo;
@optional
-(void) photoViewer:(PhotoViewer*) viewer didSelectPhotoView:(int) index photoInfo:(NSDictionary*) photoInfo;
-(void) photoViewer:(PhotoViewer*) viewer didScrollToPhotoInfo:(NSDictionary*) photoInfo;
@end

@interface PhotoViewer : UIView <UITableViewDataSource, UITableViewDelegate, UIFastLabelDelegate>

@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) NSArray * imagesArray;
@property (nonatomic, unsafe_unretained) id<UIFastLabelDelegate, PhotoViewerDelegate> delegate;
@property (nonatomic, assign) BOOL historyCompleted;
@property (nonatomic, assign) int photoIndex;

+(PhotoViewer*) getNew;

-(void) addPhotosFromHistory:(NSArray*) photosResponse startId:(NSString*) photoId;

@end

@interface SmallPhotoView : UIView
@property (nonatomic, strong) IBOutlet UIImageView * mainImageView;
@property (nonatomic, strong) IBOutlet UIImageView * captionMask;
@property (nonatomic, strong) IBOutlet UIImageView * followersMask;
@property (nonatomic, strong) IBOutlet CustomProgressBar * progressBar;
@property (nonatomic, strong) IBOutlet UIFastLabel * captionView;

@property (nonatomic, strong) CustomProgressBar * darkBar;
@property (nonatomic, strong) NSDictionary * photoInfo;

-(void) setUser:(NSDictionary*) userInfo;
-(void) setPhoto:(NSDictionary*) photoInfo delegate:(id<UIFastLabelDelegate>) delegate;

@end

@interface GridPhotoCell : UITableViewCell
@property (nonatomic, strong) IBOutletCollection(SmallPhotoView) NSArray * photoViews;
@property (nonatomic, assign) int startPhotoIndex;
@property (nonatomic, unsafe_unretained) id<PhotoViewerDelegate> delegate;
+(GridPhotoCell*) getNew;

@end

