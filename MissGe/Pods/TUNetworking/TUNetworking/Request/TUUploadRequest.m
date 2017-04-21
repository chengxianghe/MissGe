//
//  TUUploadRequest.m
//  MissLi
//
//  Created by chengxianghe on 16/7/25.
//  Copyright © 2016年 cn. All rights reserved.
//

#import "TUUploadRequest.h"

@interface TUUploadRequest ()
/**
 *  POST传送文件文件
 */
@property (nonatomic, copy, nullable) AFConstructingBlock constructingBodyBlock;

/**
 *  POST传送文件Data(自定义Request)
 */
@property (nonatomic, strong, nullable) NSData * fileData;

/**
 *  POST传送文件Data(自定义Request)
 */
@property (nonatomic, strong, nullable) NSURL * fileURL;

/**
 *  当需要上传时，获得上传进度的回调
 */
@property (nonatomic, copy, nullable) AFProgressBlock uploadProgressBlock;

@end

@implementation TUUploadRequest

- (TURequestCacheOption)cacheOption {
    return TURequestCacheOptionNone;
}

- (TURequestMethod)requestMethod {
    return TURequestMethodPost;
}

@end
