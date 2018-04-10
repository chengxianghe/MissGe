//
//  MLTopicCommentListRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/21.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

// 话题详情
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=post&a=post&pid=40338
class MLTopicDetailRequest: MLBaseRequest {

    var pid = ""
    
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"post","a":"post","pid":"\(pid)"]
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

// 话题详情 评论列表
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=post&a=repostlist&pid=40338&pg=1&size=20
class MLTopicCommentListRequest: MLBaseRequest {
    var page = 1
    var pid = ""
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"post","a":"repostlist","pid":"\(pid)","pg":"\(page)","size":"20"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    
}

// 评论
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=post&a=reply&token=CapUPdHV%252BqjnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdKeZyvwzQ&fid=3&tid=40362&detail=...&quote=40371&anonymous=0
class MLTopicCommentRequest: MLBaseRequest {
    //c=post&a=reply&token=CapUPdHV%252BqjnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdKeZyvwzQ
    //&fid=3&tid=40362&detail=...&quote=40371&anonymous=0
    
    var tid = ""
    var quote = ""
    var anonymous = 0
    var detail = ""

    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"post","a":"reply","token":MLNetConfig.shareInstance.token,"detail":"\(detail)","fid":"3","tid":"\(tid)","quote":"\(quote)","anonymous":"\(anonymous)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    
}

// 设为最佳答案
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=post&a=bestRepost&pid=40304&state=1&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo
class MLTopicSetBestCommentRequest: MLBaseRequest {

    var pid = ""
    var state = 1
    
    //&c=post&a=bestRepost&pid=40304&state=1&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo
    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"post","a":"bestRepost","token":MLNetConfig.shareInstance.token,"pid":"\(pid)","state":"\(state)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

    
}
