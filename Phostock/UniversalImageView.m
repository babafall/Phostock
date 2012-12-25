//
//  UniversalImageView.m
//  Phostock
//
//  Created by Roman Truba on 04.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "UniversalImageView.h"
#import "UIImageView+AFNetworking.h"
@implementation UniversalImageView
@synthesize captionView, captionMask;
+(UniversalImageView *)getNew
{
    UniversalImageView * imageView = [[[NSBundle mainBundle] loadNibNamed:@"UniversalImageView" owner:nil options:nil] objectAtIndex:0];
    
    imageView.uploadedMarkView.hidden = YES;
    return imageView;
}

-(void)awakeFromNib
{
//    self.captionView.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.captionView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//    self.captionView.layer.shadowOpacity = 1.0f;
//    self.captionView.layer.shadowRadius = 1.0f;
    self.disclosureView.hidden = YES;
}
-(void)setPhotoInfo:(NSDictionary*) photoInfo withDelegate:(id<UIFastLabelDelegate>) delegate
{
    [self.mainImageView setImageWithURL:[NSURL URLWithString:[photoInfo objectForKey:kPhoto]] callback:nil];
    FastAttributedString * captionText = [photoInfo objectForKey:kCaption];
    if (captionText != nil && (id)captionText != [NSNull null])
    {
        captionView.attrString = captionText;
        
        FastAttributedStringSize size;
        NSValue * value = [photoInfo objectForKey:kCaptionSize];
        [value getValue:&size];
        
        CGRect rect = captionView.frame;
        CGFloat hh = size.portraitSize.height;
        rect.origin.x = (RectWidth(self.frame) - size.portraitSize.width) / 2;
        rect.origin.y = 265 + (60 - hh) / 2;
        rect.size.height = hh;
        captionView.frame = rect;
        [captionView setTextColor:[UIColor whiteColor] withLinks:YES];
        
        if (!captionView.highlightImage)
            captionView.highlightImage = [UIImage imageNamed:@"TextSelect"];
        captionView.delegate = delegate;
        captionMask.hidden = NO;
    }
    else
    {
        captionView.attrString = nil;
        captionMask.hidden = YES;
        [captionView layoutSubviews];
    }
}
@end

@implementation PhotoViewer
@synthesize imagesArray = _imagesArray, historyCompleted;
+(PhotoViewer*) getNew
{
    PhotoViewer * imageView = [[[NSBundle mainBundle] loadNibNamed:@"UniversalImageView" owner:nil options:nil] objectAtIndex:1];
    imageView.tableView.scrollsToTop = NO;
    imageView.tableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    imageView.backgroundColor = imageView.tableView.backgroundColor = [UIColor clearColor];
    imageView.historyCompleted = NO;

    return imageView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 320.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _imagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UniversalImageView * cell = (UniversalImageView*)[tableView dequeueReusableCellWithIdentifier:@"PhotoItemCell"];
    if (!cell)
    {
        cell = [UniversalImageView getNew];
        [cell.contentView viewWithTag:1].transform = CGAffineTransformMakeRotation(M_PI / 2);
    }
    NSDictionary * photoInfo = [_imagesArray objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(photoViewer:didScrollToPhotoInfo:)])
    {
        [self.delegate photoViewer:self didScrollToPhotoInfo:photoInfo];
    }
    if (!historyCompleted && indexPath.row > 0 && indexPath.row + 1 == _imagesArray.count)
    {
        [self.delegate photoViewer:self loadHistoryForId:[photoInfo objectForKey:kPhotoId]];
    }
    
    if ([photoInfo objectForKey:kRawPhoto] && [photoInfo objectForKey:kRawPhoto] != [NSNull null])
    {
        [cell.mainImageView setImage:[photoInfo objectForKey:kRawPhoto]];
    }
    else
    {
        [cell setPhotoInfo:photoInfo withDelegate:self];
    }
    cell.disclosureView.hidden = YES;
    if (indexPath.row + 1 < _imagesArray.count )
    {
        cell.disclosureView.hidden = NO;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * photoInfo = self.imagesArray[indexPath.row];
    
    [self.delegate photoViewer:self didSelectPhotoView:self.photoIndex photoInfo:photoInfo];
}

-(void)setImagesArray:(NSArray *)imagesArray
{
    _imagesArray = imagesArray;
    [self.tableView reloadData];
}

-(void)fastLabel:(UIFastLabel *)label didSelectLink:(FastAttributedStringCustomLink *)link
{
    [self.delegate fastLabel:label didSelectLink:link];
}

-(void)addPhotosFromHistory:(NSArray *)photosResponse startId:(NSString *)photoId
{
    NSMutableArray * newImages = [self.imagesArray mutableCopy];
    for (int i = 0; i < newImages.count; i++)
    {
        NSDictionary * photoInfo = [newImages objectAtIndex:i];
        if ([[photoInfo objectForKey:kPhotoId] isEqualToString:photoId])
        {
            [newImages removeObjectsInRange:NSMakeRange(i, newImages.count - i)];
            break;
        }
    }
    [newImages addObjectsFromArray:photosResponse];
    self.imagesArray = newImages;
}
@end

@implementation SmallPhotoView
@synthesize captionView, mainImageView, progressBar;

-(void)awakeFromNib
{
//    self.captionView.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.captionView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//    self.captionView.layer.shadowOpacity = 1.0f;
//    self.captionView.layer.shadowRadius = 1.0f;
    self.followersMask.hidden = YES;
}
-(void) setUser:(NSDictionary*) userInfo
{
    if (!userInfo)
    {
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    NSLog(@"%@", userInfo);
    NSDictionary * photo = userInfo[@"photo"];
    self.followersMask.hidden = YES;
    if (photo)
    {
        [self.mainImageView setImageWithURL:[NSURL URLWithString:photo[@"photo_medium"]] maskImage:[UIImage imageNamed:@"FollowerBlackMask"] callback:^(BOOL successfull) {
            self.followersMask.hidden = NO;
        }];
    }
    else {
        self.mainImageView.image = [UIImage imageNamed:@"FollowerNoPhoto"];
        self.followersMask.hidden = NO;
    }
    
    NSDictionary * captionInfo = [userInfo objectForKey:@"loginA"];
    FastAttributedString * captionText = [captionInfo objectForKey:kCaptionMini];
    if (captionText != nil && (id)captionText != [NSNull null]) {
        
        FastAttributedStringSize size;
        NSValue * value = [captionInfo objectForKey:kCaptionSizeMini];
        [value getValue:&size];
        CGSize psize = captionText.drawSizePortrait;
        CGFloat h = 45;
        psize.height = MIN(size.portraitSize.height, h);
        captionText.drawSizePortrait = psize;
        captionView.attrString = captionText;
        
        CGRect rect = captionView.frame;
        rect.origin.x = (100 - size.portraitSize.width) / 2;
        rect.origin.y = 60 + (h - psize.height) / 2;
        rect.size.height = MIN(size.portraitSize.height, h);
        captionView.frame = rect;
        [captionView setTextColor:[UIColor whiteColor] withLinks:NO];
        
    }
    else
    {
        captionView.attrString = nil;
        [captionView layoutSubviews];
    }
    self.captionMask.hidden = YES;
}
-(void) setPhoto:(NSDictionary*) photoInfo delegate:(id<UIFastLabelDelegate>) delegate
{
    self.photoInfo = photoInfo;
    if (!photoInfo) {
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    self.captionMask.hidden = YES;
    __unsafe_unretained SmallPhotoView * weakSelf = self;
    FastAttributedString * captionText = [photoInfo objectForKey:kCaptionMini];
    [self.mainImageView setImageWithURL:[NSURL URLWithString:[photoInfo objectForKey:kMinPhoto]] callback:^(BOOL successfull) {
        if (captionText != nil && (id)captionText != [NSNull null]) {    
            self.captionMask.hidden = NO;
        }
        else
        {
            self.captionMask.hidden = YES;
        }
    }];

    if (captionText != nil && (id)captionText != [NSNull null]) {
        
        FastAttributedStringSize size;
        NSValue * value = [photoInfo objectForKey:kCaptionSizeMini];
        [value getValue:&size];
        CGSize psize = captionText.drawSizePortrait;
        CGFloat h = 45;
        psize.height = MIN(size.portraitSize.height, h);
        captionText.drawSizePortrait = psize;
        captionView.attrString = captionText;
        
        CGRect rect = captionView.frame;
        rect.origin.x = (100 - size.portraitSize.width) / 2;
        rect.origin.y = 60 + (h - psize.height) / 2;
        rect.size.height = MIN(size.portraitSize.height, h);
        captionView.frame = rect;
        [weakSelf.captionView setTextColor:[UIColor whiteColor] withLinks:YES];
        
        if (!captionView.highlightImage)
            captionView.highlightImage = [UIImage imageNamed:@"TextSelect"];
        captionView.delegate = delegate;
        
    }
    else
    {
        captionView.attrString = nil;
        [weakSelf.captionView layoutSubviews];
    }
}

@end

@implementation GridPhotoCell

+(GridPhotoCell*) getNew
{
    GridPhotoCell * imageView = [[[NSBundle mainBundle] loadNibNamed:@"UniversalImageView" owner:nil options:nil] objectAtIndex:2];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:imageView action:@selector(tapPerformed:)];
    [imageView addGestureRecognizer:tap];
    return imageView;
}

-(void) tapPerformed:(UITapGestureRecognizer*) reco
{
    if (reco.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [reco locationInView:self];
        int view = (int)(point.x / 105.0f);
        if (0 > view || view > 2) return;
        SmallPhotoView * photoView = self.photoViews[view];
        if (!photoView.darkBar)
        {
            photoView.darkBar = [[CustomProgressBar alloc] initWithFrame:CGRectMake(0, 44, 100, 12) backgroundImage:[UIImage imageNamed:@"Uploading_3"] progressImage:[UIImage imageNamed:@"UploadingProgress_3"]];
            [photoView addSubview:photoView.darkBar];
        }
        static AFImageRequestOperation * operation = nil;
        [operation cancel];
        if (operation)
        {
            [operation.customProgressBar setHidden:YES];
        }
        operation = [UIImageView preloadImage:[photoView.photoInfo objectForKey:kPhoto] progressBar:photoView.darkBar success:^{
            
            [self.delegate photoViewer:nil didSelectSmallView:self.startPhotoIndex + view photoInfo:photoView.photoInfo];
        }];
    }
}
@end