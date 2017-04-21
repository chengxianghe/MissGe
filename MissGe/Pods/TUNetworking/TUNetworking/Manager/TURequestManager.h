//
//  TURequestManager.h
//  TUNetworkingDemo
//
//  Created by chengxianghe on 16/4/19.
//  Copyright © 2016年 cn. All rights reserved.
//

/**
 管理请求的类
 主要功能是构建请求、发送请求、取消请求
 */

#import <Foundation/Foundation.h>
#import "TUBaseRequest.h"
#import "TUDownloadRequest.h"
#import "TUUploadRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUBaseRequest (TURequestManager)

/**
 *  发送请求
 *
 *  @param success  成功的回调
 *  @param failur   失败的回调
 */
- (void)sendRequestWithSuccess:(nullable TURequestSuccess)success
                        failur:(nullable TURequestFailur)failur;

/**
 *  发送请求（缓存）
 *
 *  @param cache    缓存读取完的回调
 *  @param success  成功的回调
 *  @param failur   失败的回调
 */
- (void)sendRequestWithCache:(nullable TURequestCacheCompletion)cache
                     success:(nullable TURequestSuccess)success
                      failur:(nullable TURequestFailur)failur;

/**
 *  取消请求
 */
- (void)cancelRequest;


@end

@interface TUDownloadRequest (TURequestManager)

/**
 *  发送请求（缓存）
 *
 *  @param cache    缓存读取完的回调
 *  @param success  成功的回调
 *  @param failur   失败的回调
 */
- (void)downloadWithCache:(nullable TURequestCacheCompletion)cache
                 progress:(nullable AFProgressBlock)downloadProgressBlock
                  success:(nullable TURequestSuccess)success
                   failur:(nullable TURequestFailur)failur;

@end

@interface TUUploadRequest (TURequestManager)

/**
 *  上传请求 POST
 *
 *  @param constructingBody 上传的数据
 *  @param uploadProgress   上传进度
 *  @param success          成功的回调
 *  @param failur           失败的回调
 */
- (void)uploadWithConstructingBody:(nullable AFConstructingBlock)constructingBody
                          progress:(nullable AFProgressBlock)uploadProgress
                           success:(nullable TURequestSuccess)success
                            failur:(nullable TURequestFailur)failur;
/**
 *  上传请求 POST (自定义request)
 *
 *  @param fileData         上传的数据
 *  @param uploadProgress   上传进度
 *  @param success          成功的回调
 *  @param failur           失败的回调
 */
- (void)uploadCustomRequestWithFileData:(nullable NSData *)fileData
                               progress:(nullable AFProgressBlock)uploadProgress
                                success:(nullable TURequestSuccess)success
                                 failur:(nullable TURequestFailur)failur;
/**
 *  上传请求 POST (自定义request)
 *
 *  @param fileURL          上传的文件URL
 *  @param uploadProgress   上传进度
 *  @param success          成功的回调
 *  @param failur           失败的回调
 */
- (void)uploadCustomRequestWithFileURL:(nullable NSURL *)fileURL
                              progress:(nullable AFProgressBlock)uploadProgress
                               success:(nullable TURequestSuccess)success
                                failur:(nullable TURequestFailur)failur;

@end

@interface TURequestManager : NSObject

+ (nonnull instancetype)manager;

+ (nullable NSMutableDictionary *)buildRequestHeader:(TUBaseRequest *)request;

+ (nullable NSMutableDictionary *)buildRequestParameters:(TUBaseRequest *)request;

+ (nullable NSString *)buildRequestUrl:(nonnull TUBaseRequest *)request;

- (void)sendRequest:(nonnull TUBaseRequest *)request;

- (void)cancelRequest:(nonnull TUBaseRequest *)request;

- (void)cancelAllRequests;

@end

NS_ASSUME_NONNULL_END
