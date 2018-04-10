//
//  MLSquareRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/19.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import TUNetworking

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=forum&a=postlist&fid=3&pg=1&size=20&token=(null)
class MLSquareRequest: MLBaseRequest {
    
    var page = 1
    
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"forum","a":"postlist","fid":"3","token":"(null)","pg":"\(page)","size":"20", "d":22] as [String : Any]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

    
}

//闺蜜圈
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=forum&a=postlist&fid=3&pg=1&size=20&type=follow&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo
class MLSquareFriendRequest: MLBaseRequest {
    var page = 1
    
    //c=forum&a=postlist&fid=3&pg=1&size=20&type=follow&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo
    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"forum","a":"postlist","fid":"3","token":"(null)","pg":"\(page)","size":"20","type":"follow","token":MLNetConfig.shareInstance.token]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

    
}
