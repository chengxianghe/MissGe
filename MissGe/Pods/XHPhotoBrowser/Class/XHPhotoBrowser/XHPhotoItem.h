//
//  XHPhotoItem.h
//  YYKitDemo
//
//  Created by chengxianghe on 15/12/26.
//  Copyright © 2015年 ibireme. All rights reserved.
//

/// Single picture's info.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XHPhotoProtocol <NSObject>

@required

@property (nonatomic, strong) UIView * _Nullable thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, strong) NSURL * _Nullable largeImageURL;
@property (nonatomic, assign) BOOL shouldClipToTop;///< 是否是长图
@property (nonatomic, readonly) UIImage * _Nullable thumbImage;

@optional

@property (nonatomic, copy) NSString * _Nullable caption;

@end

@interface XHPhotoItem : NSObject <XHPhotoProtocol>

@property (nonatomic, strong) UIView * _Nullable thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, strong) NSURL * _Nullable largeImageURL;
@property (nonatomic, assign) BOOL shouldClipToTop;
@property (nonatomic, readonly) UIImage * _Nullable thumbImage;

@property (nonatomic, copy) NSString * _Nullable caption;

+ (BOOL)shouldClipToTopWithView:(UIView * _Nullable)view;

@end

NS_ASSUME_NONNULL_END
