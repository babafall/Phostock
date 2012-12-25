//
//  RecentPhotosView.h
//  Phostock
//
//  Created by Roman Truba on 22.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "EasyTableView.h"

@class RecentPhotosView;
@protocol RecentPhotosViewDelegate <NSObject>

-(void) recentPhotosView:(RecentPhotosView*) recentView didSelectAsset:(ALAsset*)asset;
-(void) recentPhotosView:(RecentPhotosView*) recentView didFailWithError:(NSError*)error;

@end

@interface RecentPhotosView : UIView <EasyTableViewDelegate>
{
    ALAssetsLibrary *assetsLibrary;
    NSMutableSet * assetsSet; //To check repeats
    NSMutableArray * assetsArray;
    NSMutableDictionary * assetsPhotos;
    EasyTableView * recentPhotosView;
    BOOL canLoadAssets;
    BOOL isLoadingAssets;
    BOOL failedWithError;
    int iteration, fetched;
}

@property (nonatomic, unsafe_unretained) IBOutlet id<RecentPhotosViewDelegate> delegate;
@property (nonatomic, unsafe_unretained) IBOutlet UIView * errorView;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel * errorTextView;

-(void) clear;
-(void) fetchAssets;
-(void) fetchAssetsFront;
-(void) fetchAssetsAfterActivity;
@end
