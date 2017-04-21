//
//  GMBUploadImagesHelper.h
//  GMBuy
//
//  Created by chengxianghe on 15/11/12.
//  Copyright © 2015年 cn. All rights reserved.
//

#import <Foundation/Foundation.h>

// 单张默认时间
#define kDefauletMaxTime (60)

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, UploadMode) {
    /** 失败自动重传 */
    UploadMode_Retry    = 0,
    /** 失败直接忽略 */
    UploadMode_Ignore   = 1
};

@class GMBUploadImageModel;

typedef void(^UploadBlock)(__kindof NSArray<__kindof GMBUploadImageModel *> * _Nullable successImageUrls, __kindof NSArray<__kindof NSString *> * _Nullable failedImages);
typedef void(^UploadProgressBlock)(NSInteger totals, NSInteger completions);

@interface GMBUploadImagesHelper : NSObject

/**
 *  需登录 上传多张图片
 *
 *  @param images     图片路径数组
 *  @param mode       模式
 *  @param maxTime    总共最大时间限制
 *  @param progress   进度
 *  @param completion 完成
 */
- (void)uploadImages:(NSArray<__kindof NSString *> * _Nonnull)images
          uploadMode:(UploadMode)mode
             maxTime:(NSTimeInterval)maxTime
            progress:(UploadProgressBlock _Nullable)progress
          completion:(UploadBlock _Nullable)completion;

/**
 *  需登录 上传多张图片 采用默认时间(每张60s)
 *
 *  @param images     图片路径数组
 *  @param mode       模式
 *  @param progress   进度
 *  @param completion 完成
 */
- (void)uploadImages:(NSArray<__kindof NSString *> * _Nonnull)images
          uploadMode:(UploadMode)mode
            progress:(UploadProgressBlock _Nullable)progress
          completion:(UploadBlock _Nullable)completion;

/**
 *  取消请求
 */
- (void)cancelUploadRequest;

@end

@interface GMBUploadImageModel : NSObject

@property (nonatomic, assign) NSInteger imageIndex;
@property (nonatomic,   copy) NSString *imagePath;
@property (nonatomic,   copy) NSString *resultImageUrl;
@property (nonatomic,   copy) NSString *resultImageId;

@end

NS_ASSUME_NONNULL_END
