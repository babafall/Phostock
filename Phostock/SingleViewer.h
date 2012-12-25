//
//  SingleViewer.h
//  Phostock
//
//  Created by Roman Truba on 09.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "BaseController.h"
#import "UniversalImageView.h"
#import "PhotoCells.h"
#import "NetworkMainViewController.h"
@interface SingleViewer : BaseController <PhotoHeaderDelegate>
{
    PhotoViewer * viewer;
    IBOutlet PhotoHeader * header;
}

@property (nonatomic, unsafe_unretained) NetworkMainViewController * caller;
@property (nonatomic, strong) NSDictionary * photoInfo;
@end
