//
//  TUCacheManager.h
//  TUNetworkingDemo
//
//  Created by chengxianghe on 16/4/19.
//  Copyright © 2016年 cn. All rights reserved.
//

/**
 管理缓存的类
 注意：用户的缓存默认保存的目录是"Library/TURequestCache/0/"下面
 这里的"0"是默认的用户userId，如果设置了userId，则根据userId确定缓存目录。
 
 例：
 设置了用户userId为"12345",
 则缓存的目录为: "Library/TURequestCache/12345/"
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUBaseRequest.h"
#import "TUDownloadRequest.h"

@class TUBaseRequest;

NS_ASSUME_NONNULL_BEGIN

@interface TUBaseRequest (TUCacheManager)


/**
 *  缓存路径 不推荐重写
 *
 *  @return NSString
 */
- (nonnull NSString *)cachePath;

@end

typedef void (^TUCacheReadCompletion)(NSError * _Nullable error, id _Nullable cacheResult);
typedef void (^TUCacheWriteCompletion)(NSError * _Nullable error, NSString * _Nullable cachePath);

@interface TUCacheManager : NSObject

/// 根据缓存路径取得缓存数据
+ (void)getCacheObjectWithCachePath:(nonnull NSString *)path completion:(nullable TUCacheReadCompletion)completion;

/// 根据缓存路径存储缓存数据
+ (void)saveCacheObject:(nonnull id)object withCachePath:(nonnull NSString *)path completion:(nullable TUCacheWriteCompletion)completion;

/// 取得某个请求的缓存
+ (void)getCacheForRequest:(nonnull TUBaseRequest *)request completion:(TUCacheReadCompletion)completion;

/// 缓存某个请求
+ (void)saveCacheForRequest:(nonnull TUBaseRequest *)request completion:(TUCacheWriteCompletion)completion;

/// 清除某个请求的缓存
+ (void)clearCacheForRequest:(nonnull TUBaseRequest *)request;

/// 清除所有缓存
+ (void)clearAllCacheWithCompletion:(nullable void(^)())completion;

/// 获取单个缓存文件的大小,返回多少B
+ (CGFloat)getCacheSizeWithRequest:(nonnull TUBaseRequest *)request;

/// 获取所有缓存文件的大小,返回多少B
+ (void)getCacheSizeOfAllWithCompletion:(nullable void(^)(CGFloat totalSize))completion;

/// 返回文件缓存的主目录
+ (nonnull NSString *)cacheBaseDirPath;

/// 返回下载文件缓存的主目录
+ (nonnull NSString *)cacheBaseDownloadDirPath;

+ (BOOL)checkDirPath:(nonnull NSString *)dirPath autoCreate:(BOOL)autoCreate;

@end

NS_ASSUME_NONNULL_END
