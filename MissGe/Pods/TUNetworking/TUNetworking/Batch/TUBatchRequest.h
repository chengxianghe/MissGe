//
//  TUBatchRequest.h
//  TUNetworkingDemo
//
//  Created by chengxianghe on 2017/3/23.
//  Copyright © 2017年 cn. All rights reserved.
//

#import "TUBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUBatchRequestMode) {
    /** 普通模式 直至所有请求都结束才回调结果 */
    TUBatchRequestModeNormal   = 0,
    /** 严格模式 失败任何一个请求都立即回调结果，并终止请求 */
    TUBatchRequestModeStrict
};

/// 请求组结束的block error仅当严格模式下或者超时有值
typedef void(^TUBatchRequestCompletionBlock)(__kindof NSArray<__kindof TUBaseRequest *> *_Nullable requests, NSError *_Nullable error);

/// 请求组进度的block
typedef void(^TUBatchRequestProgressBlock)(NSInteger totals, NSInteger completions);

/// 单个请求完成的block
typedef void(^TUBatchRequestOneProgressBlock)(__kindof TUBaseRequest *_Nonnull request, NSError *_Nullable error);


@interface TUBatchRequest : NSObject

/**
 一次发起多个请求 所有请求完成后回调
 maxTime使用每个请求的默认超时之和
 注意：TURequestCacheOptionCachePriority的两次回调，这里只支持网络部分的回调
 
 @param requests 请求数组
 @param mode 请求组处理模式
 @param progress 进度
 @param completion 完成
 @return TUBatchRequest
 */
+ (instancetype)sendRequests:(nonnull NSArray<__kindof TUBaseRequest *> *)requests
                 requestMode:(TUBatchRequestMode)mode
                    progress:(nullable TUBatchRequestProgressBlock)progress
                  completion:(nullable TUBatchRequestCompletionBlock)completion;

/**
 一次发起多个请求 所有请求完成后回调
 注意：TURequestCacheOptionCachePriority的两次回调，这里只支持网络部分的回调

 @param requests 请求数组
 @param mode 请求组处理模式
 @param maxTime 总共最大时间限制 如果 maxTime = 0 则取每个请求的默认超时之和
 @param progress 总进度
 @param oneProgress 单个request完成的回调
 @param completion 完成
 */
- (void)sendRequests:(nonnull NSArray<__kindof TUBaseRequest *> *)requests
         requestMode:(TUBatchRequestMode)mode
             maxTime:(NSTimeInterval)maxTime
            progress:(nullable TUBatchRequestProgressBlock)progress
         oneProgress:(nullable TUBatchRequestOneProgressBlock)oneProgress
          completion:(nullable TUBatchRequestCompletionBlock)completion;

/**
 *  取消请求
 */
- (void)cancelRequest;

@end
NS_ASSUME_NONNULL_END
