//
//  GMBLifeUploadHelper.h
//  GMBuy
//
//  Created by chengxianghe on 15/9/14.
//  Copyright (c) 2015年 cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface GMBLifeUploadHelper : NSObject

#pragma mark - 图片压缩工具

/**
 *  根据一张原图返回一张上传规格的图片Data
 *
 *  @param originalImage 原图
 *  @param maxSize       指定大小
 *
 *  @return 图片NSData
 */
+ (NSData * _Nonnull)getUpLoadImageData:(UIImage * _Nonnull)originalImage withMaxDataSize:(long long)maxSize;

/**
 *  根据一张原图返回一张上传规格的图片Data  默认限制大小200k
 *
 *  @param originalImage 原图
 *
 *  @return 图片NSData
 */
+ (NSData * _Nonnull)getUpLoadImageData:(UIImage * _Nonnull)originalImage;

/**
 *  指定图片大小
 *
 *  @param img  图片
 *  @param size 指定的大小
 *
 *  @return 缩放过的图片
 */
+ (UIImage * _Nonnull)scaleToSize:(UIImage * _Nonnull)img size:(CGSize)size;

/**
 *  临时存储一张图片
 *
 *  @param tempImage 图片或者图片Data
 *  @param imageName 图片名称
 *
 *  @return 存储完整路径
 */
+ (NSString * _Nonnull)saveImage:(__nonnull id)tempImage withName:(NSString * _Nullable)imageName;


@end
NS_ASSUME_NONNULL_END
