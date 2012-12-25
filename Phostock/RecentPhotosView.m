//
//  RecentPhotosView.m
//  Phostock
//
//  Created by Roman Truba on 22.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "RecentPhotosView.h"

static NSString * kImageKey = @"image";
static NSString * kImageViewKey = @"imageview";
static NSString * kAssetKey = @"asset";
@implementation RecentPhotosView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}
-(void)willMoveToSuperview:(UIView *)newSuperview
{
    iteration = 1;
    self.errorView.hidden = YES;
    assetsLibrary = [RecentPhotosView defaultAssetsLibrary];
    if (!assetsSet)     assetsSet       = [NSMutableSet new];
    if (!assetsArray)   assetsArray     = [NSMutableArray new];
    if (!assetsPhotos)  assetsPhotos    = [NSMutableDictionary new];
    [self createRecentView];
    
}
+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}
- (void) createRecentView
{
    CGRect recentRect = CGRectMake(0, -5, 320, 84);
    recentPhotosView = [[EasyTableView alloc] initWithFrame:recentRect numberOfColumns:0 ofWidth:74];
    recentPhotosView.delegate						= self;
	recentPhotosView.tableView.backgroundColor      = [UIColor clearColor];
	recentPhotosView.tableView.allowsSelection      = YES;
	recentPhotosView.tableView.separatorColor		= [UIColor clearColor];
	recentPhotosView.cellBackgroundColor			= [UIColor clearColor];
	recentPhotosView.autoresizingMask				= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    recentPhotosView.backgroundColor = [UIColor clearColor];
    [recentPhotosView clear];
    [self insertSubview:recentPhotosView atIndex:0];
}
-(void) fetchAssets
{
    @autoreleasepool {
        
        isLoadingAssets = YES;
        canLoadAssets = YES;
        [self fetchAssetsForGroupType:ALAssetsGroupSavedPhotos putFront:NO];
    }
    
}
-(void) fetchAssetsFront
{
    isLoadingAssets = YES;
    canLoadAssets = YES;
    [self fetchAssetsForGroupType:ALAssetsGroupSavedPhotos putFront:YES];
    
}
-(void) fetchAssetsAfterActivity
{
    @autoreleasepool {
        
        @synchronized(self) {
//            int sleepCount = 0;
            while (isLoadingAssets) {
                canLoadAssets = NO;
                [NSThread sleepForTimeInterval:0.1];
//                NSLog(@"Sleep %d",++sleepCount);
            }
        
            //Своеобразный лок
            isLoadingAssets = YES;
            [assetsArray removeAllObjects];
            [assetsSet removeAllObjects];
            [recentPhotosView reloadData];
        
            canLoadAssets = YES;
            [self fetchAssetsForGroupType:ALAssetsGroupSavedPhotos putFront:NO];
        }
    }
}
-(void) fetchAssetsForGroupType:(ALAssetsGroupType)type putFront:(BOOL)putFront
{
    self.userInteractionEnabled = YES;
    recentPhotosView.userInteractionEnabled = YES;
    self.errorView.hidden = YES;
    recentPhotosView.hidden = NO;
    failedWithError = NO;
    isLoadingAssets = YES;
    [assetsLibrary enumerateGroupsWithTypes:type usingBlock:
     ^(ALAssetsGroup *group, BOOL *stop) {
    fetched = 0;
    if (nil != group)
    {
     [group setAssetsFilter:[ALAssetsFilter allPhotos]];
     [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:
      ^(ALAsset *result, NSUInteger index, BOOL *stop) {
          isLoadingAssets = YES;
          if (canLoadAssets && nil != result) {
              int countBefore = assetsSet.count;
              [assetsSet addObject:result.defaultRepresentation.url ];
              if (assetsSet.count > countBefore)
              {
                  if (putFront)
                  {
                      [assetsArray insertObject:result atIndex:0];
                  }
                  else
                  {
                      [assetsArray addObject:result];
                  }
              }
          }
          if (++fetched == PHOTOS_PER_PAGE || nil == result || !canLoadAssets)
          {
              fetched = 0;
              iteration++;
              [recentPhotosView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
          }
          if (nil == result)
          {
              //Догрузить остальные фоты
              if (canLoadAssets && type == ALAssetsGroupSavedPhotos)
              {
                  [self fetchAssetsForGroupType:ALAssetsGroupAll putFront:putFront];
              }
              isLoadingAssets = NO;
          }
          if (!canLoadAssets)
          {
              *stop = YES;
          }
          
      }];
     
    }//end if
    if (!canLoadAssets)
    {
        *stop = YES;
    }
    if (nil == group)
    {
        isLoadingAssets = NO;
        if (!assetsArray || !assetsArray.count)
        {
            [self showError:@"You have no recentPhotos" error:nil];
        }
    }
         }//end block
       failureBlock:^(NSError *error) {
           failedWithError = YES;
           isLoadingAssets = NO;
           [recentPhotosView reloadData];
           [self showError:@"You can select recent photos after allow geolocation access" error:error];
       }
     ];
}
-(void) showError:(NSString*) errorText error:(NSError*) error
{
    self.userInteractionEnabled = NO;
    recentPhotosView.userInteractionEnabled = NO;
    runOnMainQueueWithoutDeadlocking(^{
        [self.delegate recentPhotosView:self didFailWithError:error];
        self.errorView.hidden = NO;
        recentPhotosView.hidden = YES;
        self.errorView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.errorView.alpha = 1;
        }];
        self.errorTextView.text = errorText;
    });
}
-(void) fetchPhotoForAsset:(NSDictionary*) dict
{
    @autoreleasepool {
        
        ALAsset * result = [dict objectForKey:kAssetKey];
        UIImage * mask = [UIImage imageNamed:@"PhotoRollPhoto"];
        ALAssetRepresentation *repr = [result defaultRepresentation];
        UIImage *newImage = nil;
        @try {
            if (repr != nil && [assetsPhotos objectForKey:[repr url]] != nil) {
                newImage = [assetsPhotos objectForKey:[repr url]];
            }
            else {
                UIImage *img = nil;
                
                    img = [UIImage imageWithCGImage:[result thumbnail]];
               
                
                img = [self getImageSquared:img];
                
                CGSize newSize = CGSizeMake(140.0f, 140.0f);
                UIGraphicsBeginImageContext( newSize );
                
                // Use existing opacity as is
                [mask drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
                
                // Apply supplied opacity if applicable
                float margin = 10.0f;
                [img drawInRect:CGRectMake(margin / 2,margin / 3,newSize.width - margin,newSize.height - margin) blendMode:kCGBlendModeNormal alpha:1];
                
                newImage = UIGraphicsGetImageFromCurrentImageContext();
                if (repr.url)
                    [assetsPhotos setObject:newImage forKey:[repr url]];
                UIGraphicsEndImageContext();
            }
            [self performSelectorOnMainThread:@selector(setImageForView:)
                                   withObject:@{kImageKey : newImage, kImageViewKey : [dict objectForKey:kImageViewKey]}
                                waitUntilDone:NO];
        }
        @catch (NSException *exception) {
            
        }
        
    }
}
-(UIImage*) getImageSquared:(UIImage*) img
{
    if (img.size.width != img.size.height) {
        float minSide = MIN(img.size.width, img.size.height);
        CGRect cropRect = CGRectMake((img.size.width - minSide) / 2, (img.size.height - minSide) / 2, minSide, minSide);
        CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], cropRect);
        img = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    return img;
}

-(void) setImageForView:(NSDictionary*) dict
{
    UIImage * img = [dict objectForKey:kImageKey];
    UITableViewCell * view = [dict objectForKey:kImageViewKey];
    [recentPhotosView setImage:img forCell:view];
}

-(NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section
{
    if (failedWithError) return 0;
    if (isLoadingAssets && (!assetsArray || !assetsArray.count)) return 1;
    else if (!isLoadingAssets && (!assetsArray || !assetsArray.count)) return 0;
    if (((int)assetsArray.count - PHOTOS_PER_PAGE * iteration) < 0) return assetsArray.count;
    return PHOTOS_PER_PAGE * iteration;
}
- (CGSize)   easyTableView:(EasyTableView *)easyTableView sizeForImageAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(70, 70);
}
- (UIImage*) easyTableView:(EasyTableView *)easyTableView imageForCellAtIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    if (!assetsArray || !assetsArray.count || assetsArray.count < indexPath.row) return nil;
    NSURL * url = [[[assetsArray objectAtIndex:indexPath.row] defaultRepresentation] url];
    UIImage * img = [assetsPhotos objectForKey:url];
    if (img)
        return img;
    [self performSelectorInBackground:@selector(fetchPhotoForAsset:) withObject:@{kAssetKey : [assetsArray objectAtIndex:indexPath.row], kImageViewKey : cell}];
    return nil;
}
- (void)easyTableView:(EasyTableView *)easyTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (assetsArray.count <= indexPath.row) return;
    runOnMainQueueWithoutDeadlocking(^{
        [self.delegate recentPhotosView:self didSelectAsset:[assetsArray objectAtIndex:indexPath.row]];
    });
}

-(void) clear
{
    NSLog(@"Recent photos clean");
    [assetsPhotos removeAllObjects];
}

@end
