//
//  TUDownloadRequest.h
//  TUNetworkingDemo
//
//  Created by chengxianghe on 16/4/22.
//  Copyright © 2016年 cn. All rights reserved.
//

/**
 下载的基类
 */

#import "TUBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  下载请求 支持断点续传
 */
@interface TUDownloadRequest : TUBaseRequest

- (void)sendRequestWithSuccess:(nullable TURequestSuccess)success
                        failur:(nullable TURequestFailur)failur __attribute__((unavailable("use [-downloadWithCache:progress:success:failur:]")));

- (void)sendRequestWithCache:(nullable TURequestCacheCompletion)cache
                     success:(nullable TURequestSuccess)success
                      failur:(nullable TURequestFailur)failur __attribute__((unavailable("use [-downloadWithCache:progress:success:failur:]")));

/**
 *  继续下载
 */
- (void)resume;

/**
 *  暂停下载
 */
- (void)suspend;

@end
NS_ASSUME_NONNULL_END
