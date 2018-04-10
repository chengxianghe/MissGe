//
//  MLHomeFavoriteRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/27.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

// 取消收藏 相同请求再发一遍...
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=article&a=upcollect&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&tid=7992
class MLHomeFavoriteRequest: MLBaseRequest {
    
    var tid = ""
    
    //c=article&a=upcollect&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&tid=7992
    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"article","a":"upcollect","tid":"\(tid)","token":MLNetConfig.shareInstance.token]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

    
}
