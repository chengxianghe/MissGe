//
//  TUNetworkHelper.h
//  TUNetworkingDemo
//
//  Created by chengxianghe on 16/4/19.
//  Copyright © 2016年 cn. All rights reserved.
//

/**
 工具支持
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface TUNetworkHelper : NSObject

/// 将请求的url和参数拼起来
+ (nonnull NSString *)urlStringWithOriginUrlString:(nonnull NSString *)originUrlString
                          appendParameters:(nullable NSDictionary *)parameters;


/// 声明文件的iCloud备份属性
+ (void)setiTunesForbidBackupAttribute:(nonnull NSString *)path;

/// 获取string的md5
+ (nonnull NSString *)md5StringFromString:(nonnull NSString *)string;

/// 对string进行url转码
+ (nonnull NSString *)urlEncode:(nonnull NSString *)str;

/// 对string进行url解码
+ (nonnull NSString *)urlDecoded:(nonnull NSString *)str;

/// 获取文件的类型
+ (nonnull NSString *)mimeTypeForFileAtPath:(nonnull NSString *)path;

/// 获取app的版本号
+ (nonnull NSString *)appVersionString;

/// GB2312 To UTF8
+ (nullable NSData *)GB2312ToUTF8WithData:(nonnull NSData *)gb2312Data;

/// 是否开启 Debug Log 默认开启 YES
+ (void)setDebugLog:(BOOL)debugLog;

@end
NS_ASSUME_NONNULL_END
