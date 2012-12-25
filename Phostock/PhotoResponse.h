//
//  PhotoResponse.h
//  Phostock
//
//  Created by Roman Truba on 27.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoResponse : NSObject

@property (nonatomic, assign) int totalPhotoCount;
@property (nonatomic, strong) NSArray * photos;

@end
