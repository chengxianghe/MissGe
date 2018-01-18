//
//  MLLikeRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/26.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=post&a=likeit&pid=40298
class MLLikeCommentRequest: MLBaseRequest {
    
    var pid = ""
    
    //c=post&a=likeit&pid=40298
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"post","a":"likeit","pid":"\(pid)"]
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

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=article&a=likeit&aid=7992
class MLLikeArticleRequest: MLBaseRequest {
    var aid = ""
    
    //c=post&a=likeit&pid=40298
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"article","a":"likeit","aid":"\(aid)"]
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
