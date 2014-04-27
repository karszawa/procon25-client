//
//  ViewController.h
//  Procon25
//
//  Created by Cubic on 2014/04/03.
//  Copyright (c) 2014年 Cubic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>

- (IBAction)resetButtonTouched:(id)sender;
- (IBAction)selectImageButtonTouched:(id)sender;

@end


@interface NSMutableArray(swapping)

- (void)shuffle;
- (void)swapValuesWithIndex:(int)a opponent:(int)opponent;

@end