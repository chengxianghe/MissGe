//
//  MLPostTopicRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/20.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=post&a=addpost&token=X%2FZTO4eBrq%2FnmgZSoqA9eshEbpWRSs7%2B%2BkqAtMZAf5mvzTo&fid=3&detail=有工程师给看看么？这是怎么了？&title=有工程师给看看么？这&anonymous=0&ids=25339,25340
class MLPostTopicRequest: MLBaseRequest {

    var anonymous = 0
    var detail = ""
    var ids:[String]?
    
    //c=post&a=addpost&token=X%2FZTO4eBrq%2FnmgZSoqA9eshEbpWRSs7%2B%2BkqAtMZAf5mvzTo&fid=3&detail=有工程师给看看么？这是怎么了？&title=有工程师给看看么？这&anonymous=0&ids=25339,25340
    override func requestParameters() -> [String : Any]? {
        let title: String = detail.length > 10 ? (detail as NSString).substring(to: 10) : detail;
        var dict: [String : String] = ["c":"post","a":"addpost","token":MLNetConfig.shareInstance.token,"detail":"\(detail)","anonymous":"\(anonymous)", "title":title, "fid":"3"]
        if ids != nil && ids!.count > 0 {
            dict["ids"] = ids!.joined(separator: ",")
        }
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    
    override func requestVerifyResult() -> Bool {
        guard let dict = self.responseObject as? NSDictionary else {
            return false
        }
        
        return (dict["result"] as? String) == "200"
    }
    
}

/*
 传图
 POST http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=upload&a=postUpload&token=X%252FZTO4eBrq%252FnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5mvzTo
 
 body 带图
 
 返回
 {"result":"200","msg":"\u56fe\u50cf\u4e0a\u4f20\u6210\u529f","content":{"image_name":"uploadImg_0.png","url":"http:\/\/img.gexiaojie.com\/post\/2016\/0718\/160718100723P003873V86.png","image_id":25339}}

 */
//class MLUploadImageRequest: MLBaseRequest {
//
//    var fileURL: NSURL!
//    var fileBodyblock: AFConstructingBlock!
//    var uploadProgress: AFProgressBlock = { (progress: NSProgress) in
//        print("uploadProgressBlock:" + progress.localizedDescription)
//    }
//
//    
//    override func requestMethod() -> TURequestMethod {
//        return TURequestMethod.Post
//    }
//    
//    //c=upload&a=postUpload&token=X%252FZTO4eBrq%252FnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5mvzTo
//    
//    override func requestUrl() -> String {
//        return "c=upload&a=postUpload&token=\(MLNetConfig.shareInstance.token)"
//    }
//    
//    override func requestHandleResult() {
//        print("requestHandleResult -- \(self.classForCoder)")
//    }
//    
//    override func requestVerifyResult() -> Bool {
//        return (self.responseObject?["result"] as? String) == "200"
//    }
//    
//}
