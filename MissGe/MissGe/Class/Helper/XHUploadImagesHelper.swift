//
//  XHUploadImagesHelper.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/25.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import TUNetworking

enum XHUploadImageMode: UInt {
    /** 失败自动重传 */
    case retry
    
    /** 失败直接忽略 */
    case ignore
}

typealias XHUploadImageCompletion = (_ successImageUrls: [XHUploadImageModel]?, _ failedImages: [XHUploadImageModel]?) -> Void

typealias XHUploadImageProgress = (_ totals: NSInteger, _ completions: NSInteger) -> Void

class XHUploadImagesHelper: NSObject {
    //外部参数
    var imageArray: [String]! // 需要上传的图片数组 里面存本地文件的地址
    var mode = XHUploadImageMode.ignore
    var completion: XHUploadImageCompletion?
    var progress: XHUploadImageProgress?
    var maxTime: TimeInterval = 60.0 // 最长时间限制 默认单张60s
    
    // 内部参数
    var requestArray = [XHUploadImageRequest]() // 已经发起的请求
    var requestReadyArray = [XHUploadImageRequest]() // 准备发起的请求
    var resultModelArray = [XHUploadImageModel]() // 请求回来的保存的数据
    var maxNum: Int = 3 // 同时最大并发数 默认 kDefaultUploadMaxNum
    var isEnd = false // 是否已经结束请求
    
    
    func cancelOneRequest(_ request: XHUploadImageRequest) {
        request.cancel()
    }
    
    
    func cancelUploadRequest() {
        // 先取消 结束回调
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(endUpload), object: nil)
        self.isEnd = true
        
        for request in self.requestArray {
            self.cancelOneRequest(request)
        }
        self.completion = nil
        self.progress = nil
        
    }
    
    func removeRequest(_ request: XHUploadImageRequest) {
        self.requestArray.remove(at: self.requestArray.index(of: request)!)
        self.cancelOneRequest(request)
        
        
        if (self.requestReadyArray.count > 0 && self.requestArray.count < self.maxNum) {
            let req = self.requestReadyArray.first!
            self.requestArray.append(req)
            self.startRequest(req)
            self.requestReadyArray.remove(at: self.requestReadyArray.index(of: req)!)
        }
    }
    
    
    func addRequest(_ request: XHUploadImageRequest) {
        
        if (self.requestArray.count < self.maxNum) {
            self.requestArray.append(request)
            self.startRequest(request)
            
        } else {
            self.requestReadyArray.append(request)
            
        }
    }
    
    func startRequest(_ request: XHUploadImageRequest) {
        
        //        [request cancelRequest];
        print("*********正在上传图index:\(request.imageIndex) ....")
        request.upload(constructingBody: { (formData: AFMultipartFormData) in
            
//            if request.imageData != nil {
//                formData.appendPart(withFileData: request.imageData!, name: "image", fileName: "uploadImg_\(request.imageIndex).gif", mimeType: "image/gif")
//            } else if request.imagePath != nil {
                do {
                    try formData.appendPart(withFileURL: URL.init(fileURLWithPath: request.imagePath!), name: "image", fileName: request.name, mimeType: request.isGif ? "image/gif" : "image/jpeg")
                }
                catch let error as NSError {
                    print(error)
                }
//            } else {
//                print("上传的图片没有数据imagePath、imageData不可都为nil")
//            }
        }, progress: { (progress) in
            print("progressView: \(progress.fractionCompleted)")
        }, success: { (baseRequest, responseObject) in
            print("上传成功");
            self.checkResult(request)
        }) { (baseRequest, error) in
            print("上传失败:\(error.localizedDescription)");
            self.checkResult(request)
        }
    }
    
    open func uploadImages(images: [String], uploadMode: XHUploadImageMode, progress: XHUploadImageProgress?, completion: XHUploadImageCompletion?) {
        self.uploadImages(images: images, uploadMode: uploadMode, maxTime: TimeInterval(images.count * 60), progress: progress, completion: completion)
    }
    
    open func uploadImages(images: [String], uploadMode: XHUploadImageMode, maxTime: TimeInterval, progress: XHUploadImageProgress?, completion: XHUploadImageCompletion?) {
        self.requestArray.removeAll()
        self.requestReadyArray.removeAll()
        self.resultModelArray.removeAll()
        
        
        self.completion = completion;
        self.progress = progress;
        self.mode = uploadMode;
        self.imageArray = images;
        self.maxTime = maxTime;
        self.isEnd = false;
        
        // TODO: 根据网络环境 决定 同时上传数量
        self.maxNum = 3;
        
        // 定时回调endUpload
        self.perform(#selector(endUpload), with: nil, afterDelay: maxTime)
        
        var i = 0
        for str in images {
            let request = XHUploadImageRequest.init()
            request.imagePath = str
            request.imageIndex = i
            request.name = (str as NSString).lastPathComponent
            request.isGif = (str as NSString).pathExtension.uppercased() == "GIF"
            self.addRequest(request)
            i = i + 1
        }
        
        // 先回调一下progress
        self.progress?(self.imageArray.count, self.resultModelArray.count);
    }
    
    
    func checkResult(_ request: XHUploadImageRequest) {
        
        if (self.isEnd) {
            return;
        }
        
        if (self.mode == .retry && request.resultImageUrl == nil) {
            // 失败自动重传
            self.startRequest(request)
            return;
        } else {
            let model = XHUploadImageModel.init()
            model.imageIndex = request.imageIndex;
            model.imagePath = request.imagePath;
            model.resultImageUrl = request.resultImageUrl;
            model.resultImageId = request.resultImageId;
            
            self.resultModelArray.append(model)
            self.removeRequest(request)
        }
        
        // 进度回调
        self.progress?(self.imageArray.count, self.resultModelArray.count);
        
        if (self.resultModelArray.count == self.imageArray.count) {
            self.endUpload()
        }
    }
    
    func endUpload() {
        // 全部完成
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(endUpload), object: nil)
        
        
        // 排序
        self.resultModelArray.sort { (obj1, obj2) -> Bool in
            // 从小到大
            return obj1.imageIndex > obj2.imageIndex;
        }
        
        var successImages = [XHUploadImageModel]()
        var failedImages = [XHUploadImageModel]()
        
        for model in resultModelArray {
            
            if (model.resultImageUrl != nil) {
                successImages.append(model)
            } else {
                failedImages.append(model)
            }
        }
        
        self.completion?(successImages,failedImages);
        self.cancelUploadRequest()
    }
    
}

//mark: - Class: GMBUploadImageModel
class XHUploadImageModel: NSObject {
    var imageIndex: Int = 0
    var imagePath: String!
    var resultImageUrl: String?  // 接口返回的 图片地址
    var resultImageId: String? // 接口返回的 图片id
}


/// imageData和imagePath不可都为nil
class XHUploadImageRequest: TUUploadRequest {
    var imageIndex: Int = 0
    var isGif: Bool = false
    var name: String = ""
    var imagePath: String? // 上传的普通图片路径
//    var imageData: Data? // 上传的gif图片data
    var resultImageUrl: String?  // 接口返回的 图片地址
    var resultImageId: String? // 接口返回的 图片id
    
    override func requestUrl() -> String? {
        let str = "http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=upload&a=postUpload&token="
        return str.appending(MLNetConfig.shareInstance.token)
    }
    
    // 请求成功后返回的参数
    override func requestHandleResult() {
        
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
         }
         */
        guard let result = self.responseObject as? [String:Any] else {
            return
        }
        
        guard let temp = result["content"] as? [String:Any] else {
            return
        }
        
        if (temp["url"] != nil) {
            self.resultImageUrl = temp["url"] as? String;
            if let tempImageId = temp["image_id"] as? Int {
                self.resultImageId = "\(tempImageId)"
            } else if let tempImageId = temp["image_id"] as? String {
                self.resultImageId = tempImageId
            }
            print("*********上传图index:\(self.imageIndex) 成功!:\(String(describing: self.resultImageUrl))(id:\(String(describing: self.resultImageId))))")
            //            print("*********上传图index:%ld 成功!:%@(id:%d)", (long)self.imageIndex, self.resultImageUrl, (int)self.resultImageId);
        } else {
            print("*********上传图index:\(self.imageIndex) 失败!:\(String(describing: self.imagePath))")
        }
    }
    
}
