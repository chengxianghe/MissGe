//
//  TUNetworkConfig.h
//  TUNetworkingDemo
//
//  Created by chengxianghe on 16/4/21.
//  Copyright © 2016年 cn. All rights reserved.
//

/**
 配置请求的类
 
 可以使用默认提供的TUNetworkConfig,也可以自行实现config（遵循TUNetworkConfigProtocol即可）
 
 config实际是提供网络请求构建的默认参数的配置。
 
 参数使用优先级：
 自定义Request > 自定义Config > 默认的(TUNetworkConfig)
 */

#import <Foundation/Foundation.h>
#import "TUNetworkDefine.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
@import AFNetworking;
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol TUNetworkConfigProtocol <NSObject>

@required

+ (nonnull id<TUNetworkConfigProtocol>)config;

/// 用户的userId，主要用来区分缓存的目录
- (nonnull NSString *)configUserId;

/// 请求的公共参数
- (nullable NSDictionary *)requestPublicParameters;

/// 校验请求结果
- (BOOL)requestVerifyResult:(nonnull id)result;

@optional
/// 请求的protocol 例如："http://"
- (nullable NSString *)requestURLProtocol;

/// 请求的Host 例如："www.douban.com:8080"
- (nullable NSString *)requestHost;

/// 请求的超时时间
- (NSTimeInterval)requestTimeoutInterval;

/// 请求的安全选项
- (nullable AFSecurityPolicy *)requestSecurityPolicy;

/// Http请求的方法
- (TURequestMethod)requestMethod;

/// 请求的SerializerType
- (TURequestSerializerType)requestSerializerType;

/// 请求公参的位置
- (TURequestPublicParametersType)requestPublicParametersType;

@end

///默认实现的config
@interface TUNetworkConfig : NSObject <TUNetworkConfigProtocol>

@property (nonatomic, copy, nonnull) NSString *userId;
@property (nonatomic, strong, nullable) NSDictionary *publicParameters;

+ (nonnull instancetype)config;

- (nonnull NSString *)configUserId;

- (nullable NSString *)requestURLProtocol;

- (nullable NSString *)requestHost;

- (NSTimeInterval)requestTimeoutInterval;

- (nullable AFSecurityPolicy *)requestSecurityPolicy;

- (TURequestMethod)requestMethod;

- (TURequestSerializerType)requestSerializerType;

- (nullable NSDictionary *)requestPublicParameters;

- (TURequestPublicParametersType)requestPublicParametersType;

- (BOOL)requestVerifyResult:(nullable id)result;

@end

NS_ASSUME_NONNULL_END
