//
//  YYPhotoGroupCell.h
//  YYKitDemo
//
//  Created by chengxianghe on 15/12/26.
//  Copyright © 2015年 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XHPhotoItem,YYAnimatedImageView;

@interface XHPhotoBrowserCell : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL showProgress;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) XHPhotoItem *item;
@property (nonatomic, readonly) BOOL itemDidLoad;

- (void)resizeSubviewSize;

@end

