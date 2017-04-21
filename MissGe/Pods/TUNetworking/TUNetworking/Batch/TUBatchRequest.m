//
//  TUBatchRequest.m
//  TUNetworkingDemo
//
//  Created by chengxianghe on 2017/3/23.
//  Copyright © 2017年 cn. All rights reserved.
//

#import "TUBatchRequest.h"
#import <objc/runtime.h>
#import "TURequestManager.h"

// 默认同时开启最多3个上传请求
#define kDefaultRequestMaxNum (3)

static const void *kBatchIndexKey; // BatchIndex

@interface TUBaseRequest (Batch)

@property (nonatomic, assign) NSInteger batchIndex;

@end

@implementation TUBaseRequest (Batch)

- (NSInteger)batchIndex {
    NSNumber *scaleValue = objc_getAssociatedObject(self, &kBatchIndexKey);
    return scaleValue.integerValue;
}

- (void)setBatchIndex:(NSInteger)batchIndex {
    objc_setAssociatedObject(self, &kBatchIndexKey, @(batchIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface TUBatchRequest ()

//外部参数
@property (nonatomic, assign) NSInteger totalCount; // 请求组请求个数
@property (nonatomic, assign) TUBatchRequestMode mode; // 请求模式
@property (nonatomic,   copy) TUBatchRequestCompletionBlock completion;
@property (nonatomic,   copy) TUBatchRequestProgressBlock progress;
@property (nonatomic,   copy) TUBatchRequestOneProgressBlock oneProgress;
@property (nonatomic, assign) NSTimeInterval maxTime;// 最长时间限制

// 内部参数
@property (nonatomic, strong) NSMutableArray *requestArray; // 已经发起的请求
@property (nonatomic, strong) NSMutableArray *requestReadyArray; // 准备发起的请求
@property (nonatomic, strong) NSMutableArray *resultArray; // 完成的请求
@property (nonatomic, assign) NSInteger maxNum; // 同时最大并发数 默认 kDefaultUploadMaxNum
@property (nonatomic, assign) BOOL isEnd; // 是否已经结束请求

@end

@implementation TUBatchRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestArray = [NSMutableArray array];
        self.resultArray = [NSMutableArray array];
        self.requestReadyArray = [NSMutableArray array];
        self.maxNum = kDefaultRequestMaxNum;
        self.maxTime = 0;
        self.isEnd = NO;
    }
    return self;
}

//MARK: - Public

- (void)cancelRequest {
    // 先取消 结束回调
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelRequestWithError:) object:nil];
    self.isEnd = YES;
    
    [self clearAll];
    TULog(@"BatchRequest Error:%@", @"Error: BatchRequest was cancelled.");
}

+ (instancetype)sendRequests:(NSArray<__kindof TUBaseRequest *> *)requests requestMode:(TUBatchRequestMode)mode progress:(TUBatchRequestProgressBlock)progress completion:(TUBatchRequestCompletionBlock)completion {
    TUBatchRequest *request = [[TUBatchRequest alloc] init];
    [request sendRequests:requests requestMode:mode maxTime:0 progress:progress oneProgress:nil completion:completion];
    return request;
}

- (void)sendRequests:(NSArray<__kindof TUBaseRequest *> *)requests requestMode:(TUBatchRequestMode)mode maxTime:(NSTimeInterval)maxTime progress:(TUBatchRequestProgressBlock)progress oneProgress:(TUBatchRequestOneProgressBlock)oneProgress completion:(TUBatchRequestCompletionBlock)completion {
    
    [self.requestArray removeAllObjects];
    [self.requestReadyArray removeAllObjects];
    [self.resultArray removeAllObjects];
    
    self.completion = completion;
    self.progress = progress;
    self.oneProgress = oneProgress;
    self.mode = mode;
    self.totalCount = requests.count;
    self.maxTime = maxTime;

    self.isEnd = NO;
    
    // 根据网络环境 决定 同时上传数量
    if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
        self.maxNum = kDefaultRequestMaxNum;
    } else {
        self.maxNum = 1;
    }
    
    NSInteger i = 0;
    for (TUBaseRequest *request in requests) {
        request.batchIndex = i++;
        
        if (maxTime == 0) {
            self.maxTime += [request requestTimeoutInterval];
        }
    }
    
    // 先回调一下progress
    if (self.progress) {
        self.progress(self.totalCount, 0);
    }

    // 定时回调cancelRequest
    [self performSelector:@selector(cancelRequestWithError:) withObject:nil afterDelay:self.maxTime];
    
    for (TUBaseRequest *request in requests) {
        if (self.requestArray.count < self.maxNum) {
            [self.requestArray addObject:request];
            [self startRequest:request];
        } else {
            [self.requestReadyArray addObject:request];
        }
    }
}

//MARK: - Private

- (void)cancelOneRequest:(TUBaseRequest *)request {
    [request cancelRequest];
    request = nil;
}

- (void)removeRequest:(TUBaseRequest *)request {
    [self.requestArray removeObject:request];
    [self cancelOneRequest:request];
    
    if (self.requestReadyArray.count > 0 && self.requestArray.count < self.maxNum) {
        TUBaseRequest *req = [self.requestReadyArray firstObject];
        [self.requestArray addObject:req];
        [self startRequest:req];
        [self.requestReadyArray removeObject:req];
    }
}

- (void)startRequest:(TUBaseRequest *)request {
    __weak typeof(self) weakSelf = self;
    TULog(@"*********batch request current index:%ld ...", (long)request.batchIndex);
    [request sendRequestWithCache:^(__kindof TUBaseRequest * _Nonnull baseRequest, __kindof id  _Nullable cacheResult, NSError * _Nonnull error) {
        if (error) {
            //缓存读取失败
            if ([request cacheOption] == TURequestCacheOptionCacheOnly || [request cacheOption] == TURequestCacheOptionRefreshPriority) {
                [weakSelf checkResult:request error:error];
            }
        } else {
            //缓存读取成功
            if ([request cacheOption] == TURequestCacheOptionCacheSaveFlow || [request cacheOption] == TURequestCacheOptionRefreshPriority) {
                [weakSelf checkResult:request error:nil];
            }
        }
    } success:^(__kindof TUBaseRequest * _Nonnull baseRequest, id  _Nullable responseObject) {
        [weakSelf checkResult:request error:nil];
    } failur:^(__kindof TUBaseRequest * _Nonnull baseRequest, NSError * _Nonnull error) {
        // RefreshPriority 失败还有一次机会读取本地缓存 
        if ([request cacheOption] != TURequestCacheOptionRefreshPriority) {
            [weakSelf checkResult:request error:error];
        }
    }];
}

- (void)checkResult:(TUBaseRequest *)request error:(NSError *)error {
    if (self.isEnd) {
        return;
    }
    
    if (error && self.mode == TUBatchRequestModeStrict) {
        [self cancelRequestWithError:error];
        return;
    }
    
    // 单个请求完成回调
    if (self.oneProgress) {
        self.oneProgress(request, error);
    }
    
    @synchronized (self) {
        [self.resultArray addObject:request];
        [self removeRequest:request];
        
        // 进度回调
        if (self.progress) {
            self.progress(self.totalCount, self.resultArray.count);
        }
        
        if (self.resultArray.count == self.totalCount) {
            [self endRequests];
        }
    }
}

- (void)cancelRequestWithError:(NSError *)error {
    // 先取消 结束回调
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelRequestWithError:) object:nil];
    self.isEnd = YES;

    if (!error) {
        error = [NSError errorWithDomain:@"Error: BatchRequest was timeout." code:-1 userInfo:nil];
    }
    
    if (self.completion) {
        self.completion(self.resultArray, error);
    }
    
    TULog(@"BatchRequest Error:%@", error);

    [self clearAll];
}

- (void)endRequests {
    // 全部完成
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelRequestWithError:) object:nil];
    
    // 排序
    [self.resultArray sortUsingComparator:^NSComparisonResult(TUBaseRequest *obj1, TUBaseRequest *obj2) {
        // 从小到大
        return obj1.batchIndex > obj2.batchIndex;
    }];
    
    NSArray *array = [self.resultArray mutableCopy];
    
    if (self.completion) {
        self.completion(array, nil);
    }
    
    [self clearAll];
}

- (void)clearAll {
    self.completion = nil;
    self.progress = nil;
    self.oneProgress = nil;
    self.isEnd = YES;
    for (TUBaseRequest *request in self.requestArray) {
        [self cancelOneRequest:request];
    }
    [self.resultArray removeAllObjects];
    [self.requestArray removeAllObjects];
    [self.requestReadyArray removeAllObjects];
}

@end
