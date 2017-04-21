//
//  GMBUploadImagesHelper.m
//  GMBuy
//
//  Created by chengxianghe on 15/11/12.
//  Copyright © 2015年 cn. All rights reserved.
//

#import "GMBUploadImagesHelper.h"
//@import TUNetworking;
#import "MissGe-Swift.h"

// 默认同时开启最多3个上传请求
#define kDefaultUploadMaxNum (3)

#pragma mark - Class: GMBUploadImageModel
@implementation GMBUploadImageModel

@end

#pragma mark - Class: GMBUploadImageRequest
@interface GMBUploadImageRequest : TUUploadRequest

@property (nonatomic, assign) NSInteger imageIndex;
@property (nonatomic,   copy) NSString  *imagePath;
//@property (nonatomic, assign) BOOL isStart;
@property (nonatomic,   copy) NSString  *resultImageUrl; // 接口返回的 图片地址
@property (nonatomic,   copy) NSString  *resultImageId; // 接口返回的 图片地址

@end

@implementation GMBUploadImageRequest

- (NSString *)requestUrl {
    return [@"http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=upload&a=postUpload&token=" stringByAppendingString:[[MLNetConfig shareInstance] token]];
}

// 请求成功后返回的参数
- (void)requestHandleResult {
    [super requestHandleResult];
    
    if(self.responseObject == nil) {
        return ;
    }
    
    /**
     {
     "result":"200",
     "msg":"\u56fe\u50cf\u4e0a\u4f20\u6210\u529f",
     "content":
        {
        "image_name":"uploadImg_0.png",
        "url":"http:\/\/img.gexiaojie.com\/post\/2016\/0718\/160718100723P003873V86.png",
        "image_id":25339}
     }
     */
    id temp = [self.responseObject objectForKey:@"content"];
    
    if ([temp isKindOfClass:[NSDictionary class]] && temp[@"url"] != nil) {
        self.resultImageUrl = temp[@"url"];
        self.resultImageId = [(NSNumber *)temp[@"image_id"] stringValue];
        NSLog(@"*********上传图index:%ld 成功!:%@(id:%d)", (long)self.imageIndex, self.resultImageUrl, (int)self.resultImageId);
    } else {
        NSLog(@"*********上传图index:%ld 失败!:%@", (long)self.imageIndex, self.imagePath);
    }
}


@end

#pragma mark - Class: GMBUploadImagesHelper
@interface GMBUploadImagesHelper()

//外部参数
@property (nonatomic, strong) NSArray           *imageArray; // 需要上传的图片数组 里面存本地文件的地址
@property (nonatomic, assign) UploadMode        mode;
@property (nonatomic,   copy) UploadBlock       completion;
@property (nonatomic,   copy) UploadProgressBlock progress;
@property (nonatomic, assign) NSTimeInterval    maxTime;// 最长时间限制 默认单张60s

// 内部参数
@property (nonatomic, strong) NSMutableArray    *requestArray; // 已经发起的请求
@property (nonatomic, strong) NSMutableArray    *requestReadyArray; // 准备发起的请求
@property (nonatomic, strong) NSMutableArray    *resultModelArray; // 请求回来的保存的数据
@property (nonatomic, assign) NSInteger         maxNum; // 同时最大并发数 默认 kDefaultUploadMaxNum
@property (nonatomic, assign) BOOL              isEnd; // 是否已经结束请求

@end

@implementation GMBUploadImagesHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestArray = [NSMutableArray array];
        self.resultModelArray = [NSMutableArray array];
        self.requestReadyArray = [NSMutableArray array];
        self.maxNum = kDefaultUploadMaxNum;
        self.maxTime = kDefauletMaxTime;
        self.isEnd = NO;
    }
    return self;
}

- (void)cancelOneRequest:(GMBUploadImageRequest *)request {
    [request cancelRequest];
    request = nil;
}

- (void)cancelUploadRequest {
    // 先取消 结束回调
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endUpload) object:nil];
    self.isEnd = YES;
    
    for (GMBUploadImageRequest *request in self.requestArray) {
        [self cancelOneRequest:request];
    }
    self.completion = nil;
    self.progress = nil;
}

- (void)removeRequest:(GMBUploadImageRequest *)request {
    [self.requestArray removeObject:request];
    [self cancelOneRequest:request];
    
    if (self.requestReadyArray.count > 0 && self.requestArray.count < self.maxNum) {
        GMBUploadImageRequest *req = [self.requestReadyArray firstObject];
        [self.requestArray addObject:req];
        [self startRequest:req];
        [self.requestReadyArray removeObject:req];
    }
    
    //    for (GMBUploadImageRequest *requ in self.requestArray) {
    //        if (requ.imageIndex == request.imageIndex) {
    //
    //            return;
    //        }
    //    }
}

- (void)addRequest:(GMBUploadImageRequest *)request {
    if (request != nil) {
        if (self.requestArray.count < self.maxNum) {
            [self.requestArray addObject:request];
            [self startRequest:request];
        } else {
            [self.requestReadyArray addObject:request];
        }
    }
}

- (void)startRequest:(GMBUploadImageRequest *)request {
    if (request != nil) {
        //        [request cancelRequest];
        __weak typeof(self) weakSelf = self;
        NSLog(@"*********正在上传图index:%ld ....", (long)request.imageIndex);

        [request uploadWithConstructingBody:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:request.imagePath] name:@"image" fileName:[@"uploadImg_" stringByAppendingFormat:@"%d.jpg", (int)request.imageIndex] mimeType:@"image/jpeg" error:nil];
//            [formData appendPartWithFileURL:[NSURL fileURLWithPath:request.imagePath] name:@"file" error:nil];
        } progress:^(NSProgress * _Nonnull progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update the progress view
                NSLog(@"progressView: %f", progress.fractionCompleted);
            });
        } success:^(__kindof TUBaseRequest * _Nonnull baseRequest, id  _Nullable responseObject) {
            NSLog(@"上传成功");
            [weakSelf checkResult:(GMBUploadImageRequest *)request];
        } failur:^(__kindof TUBaseRequest * _Nonnull baseRequest, NSError * _Nonnull error) {
            NSLog(@"上传失败:%@", error.localizedDescription);
            [weakSelf checkResult:(GMBUploadImageRequest *)request];
        }];
    }
}

- (void)uploadImages:(NSArray *)images uploadMode:(UploadMode)mode progress:(UploadProgressBlock)progress completion:(UploadBlock)completion {
    [self uploadImages:images uploadMode:mode maxTime:(images.count * kDefauletMaxTime) progress:progress completion:completion];
}

- (void)uploadImages:(NSArray *)images uploadMode:(UploadMode)mode maxTime:(NSTimeInterval)maxTime progress:(UploadProgressBlock)progress completion:(UploadBlock)completion {
    
    [self.requestArray removeAllObjects];
    [self.requestReadyArray removeAllObjects];
    [self.resultModelArray removeAllObjects];
    
    self.completion = completion;
    self.progress = progress;
    self.mode = mode;
    self.imageArray = images;
    self.maxTime = maxTime;
    self.isEnd = NO;
    
    // TODO: 根据网络环境 决定 同时上传数量
    self.maxNum = kDefaultUploadMaxNum;
    
    // 定时回调endUpload
    [self performSelector:@selector(endUpload) withObject:nil afterDelay:maxTime];
    
    for (int i = 0; i < images.count; i ++) {
        GMBUploadImageRequest *request = [[GMBUploadImageRequest alloc] init];
        request.imagePath = images[i];
        request.imageIndex = i;
        [self addRequest:request];
    }
    
    // 先回调一下progress
    if (self.progress) {
        self.progress(self.imageArray.count, self.resultModelArray.count);
    }
}

- (void)checkResult:(GMBUploadImageRequest *)request {
    
    if (self.isEnd) {
        return;
    }
    
    if (self.mode == UploadMode_Retry && !request.resultImageUrl.length) {
        // 失败自动重传
        [self startRequest:request];
        return;
    } else {
        GMBUploadImageModel *model = [[GMBUploadImageModel alloc] init];
        model.imageIndex = request.imageIndex;
        model.imagePath = request.imagePath;
        model.resultImageUrl = request.resultImageUrl;
        model.resultImageId = request.resultImageId;
        
        [self.resultModelArray addObject:model];
        
        [self removeRequest:request];
    }
    
    // 进度回调
    if (self.progress) {
        self.progress(self.imageArray.count, self.resultModelArray.count);
    }
    
    if (self.resultModelArray.count == self.imageArray.count) {
        [self endUpload];
    }
}

- (void)endUpload {
    // 全部完成
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endUpload) object:nil];
    
    // 排序
    [self.resultModelArray sortUsingComparator:^NSComparisonResult(GMBUploadImageModel *obj1, GMBUploadImageModel *obj2) {
        // 从小到大
        return obj1.imageIndex > obj2.imageIndex;
    }];
    
    NSMutableArray<__kindof GMBUploadImageModel *> *successImages = [NSMutableArray array];
    NSMutableArray<__kindof NSString *> *failedImages = [NSMutableArray array];
    
    for (GMBUploadImageModel *model in self.resultModelArray) {
        if (model.resultImageUrl.length > 0) {
            [successImages addObject:model];
        } else {
            [failedImages addObject:model.imagePath];
        }
    }
    if (self.completion) {
        self.completion(successImages,failedImages);
    }
    
    [self cancelUploadRequest];
}

@end
