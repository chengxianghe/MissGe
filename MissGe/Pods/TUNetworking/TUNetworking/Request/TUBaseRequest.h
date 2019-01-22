//
//  TUBaseRequest.h
//  TUNetworkingDemo
//
//  Created by chengxianghe on 16/4/19.
//  Copyright © 2016年 cn. All rights reserved.
//

/**
 请求的基类
 需继承此类实现自定义Request
 */

#import <Foundation/Foundation.h>
#import "TUNetworkDefine.h"
#import "TUNetworkConfig.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
@import AFNetworking;
#endif

NS_ASSUME_NONNULL_BEGIN

@class TUBaseRequest;

typedef NSURL * _Nullable (^AFDownloadDestinationBlock)(NSURL *targetPath, NSURLResponse *response);
typedef void (^AFConstructingBlock)(__kindof id<AFMultipartFormData> formData);
typedef void (^AFProgressBlock)(__kindof NSProgress *progress);
typedef void (^TURequestSuccess)(__kindof TUBaseRequest *baseRequest, id _Nullable responseObject);
typedef void (^TURequestFailur)(__kindof TUBaseRequest *baseRequest, NSError *error);
typedef void (^TURequestCacheCompletion)(__kindof TUBaseRequest *baseRequest, __kindof id _Nullable cacheResult, NSError *error);

/**
 *  基本请求
 */
@interface TUBaseRequest : NSObject

@property (nonatomic, strong, nullable) id responseObject; ///< 请求返回的数据
@property (nonatomic, strong, nullable) id cacheResponseObject; ///< 缓存返回的数据
@property (nonatomic,   copy, nullable) TURequestSuccess successBlock; ///< 请求成功的回调
@property (nonatomic,   copy, nullable) TURequestFailur failurBlock; ///< 请求失败的回调
@property (nonatomic,   copy, nullable) TURequestCacheCompletion cacheCompletionBlcok; ///< 请求获取到cache的回调
@property (nonatomic, strong) NSURLSessionTask *requestTask; ///< 请求的Task
@property (nonatomic, assign) TURequestPriority requestPriority;///< 请求优先级
@property (nonatomic, assign) TURequestCacheOption cacheOption; ///< 请求的缓存选项

#pragma mark - Build TURequest

/**
 *  请求的protocol
 *  例如："http://"
 *  @return NSString
 */
- (nullable NSString *)requestURLProtocol;

/**
 *  请求的Host
 *
 *  @return NSString
 */
- (nullable NSString *)requestHost;

/**
 *  请求的URL
 *
 *  @return NSString
 */
- (nullable NSString *)requestUrl;

/**
 *  请求的连接超时时间，默认为60秒
 *
 *  @return NSTimeInterval
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  请求的参数列表
 *  POST时放在body中
 *
 *  @return NSDictionary
 */
- (nullable NSDictionary<NSString *, id> *)requestParameters;

/**
 *  请求的方法(GET,POST...)
 *
 *  @return TURequestMethod
 */
- (TURequestMethod)requestMethod;

/**
 *  请求的SerializerType
 *
 *  @return TURequestSerializerType
 */
- (TURequestSerializerType)requestSerializerType;

/**
 *  请求公参的位置
 *
 *  @return TURequestPublicParametersType
 */
- (TURequestPublicParametersType)requestPublicParametersType;

/**
 *  证书配置
 *
 *  @return AFSecurityPolicy
 */
- (nullable AFSecurityPolicy *)requestSecurityPolicy;

/**
 *  在HTTP报头添加的自定义参数
 *
 *  @return NSDictionary
 */
- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;

#pragma mark - Request Handle
/**
 *  请求的回调
 */
- (void)requestHandleResult;

/**
 *  请求缓存的回调
 *
 *  @param cacheResult 缓存的数据
 *  @param error Error
 */
- (void)requestHandleResultFromCache:(nullable id)cacheResult error:(nullable NSError *)error;

/**
 *  请求结果校验
 *
 *  @return BOOL
 */
- (BOOL)requestVerifyResult;

/**
 *  清理网络回调block
 */
- (void)clearCompletionBlock;

#pragma mark - Custom Request
/**
 *  自定义UrlRequest 忽略所有Build TURequest方法
 *
 *  @return NSURLRequest
 */
- (nullable NSURLRequest *)buildCustomUrlRequest;

#pragma mark - Cache

/**
 *  缓存过期时间（默认-1 永远不过期）
 *
 *  @return NSTimeInterval
 */
- (NSTimeInterval)cacheExpireTimeInterval;

/**
 *  清理缓存回调block
 */
- (void)clearCacheCompletionBlock;

/**
 *  缓存需要忽略的参数
 *
 *  @return NSArray
 */
- (nullable NSArray<__kindof NSString *> *)cacheFileNameIgnoreKeysForParameters;

#pragma mark - config

/**
 *  网络配置
 *
 *  @return TUNetworkConfig
 */
- (nonnull id<TUNetworkConfigProtocol>)requestConfig;

@end

NS_ASSUME_NONNULL_END
