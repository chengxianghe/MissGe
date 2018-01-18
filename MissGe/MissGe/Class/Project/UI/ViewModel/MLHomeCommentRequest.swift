//
//  MLHomeCommentRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/24.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

//评论文章 http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=article&a=addcom&aid=7992&cid=(null)&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&detail=%E4%B8%8D%E9%94%99%E5%95%8A&type=1

// 回复别人
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=article&a=addcom&aid=7992&cid=10314&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&detail=%F0%9F%98%84%F0%9F%98%84&type=2
class MLHomeCommentRequest: MLBaseRequest {
    
    var aid = ""
    var cid = ""
    /// 1 正常评论; 2 回复别人
    fileprivate var type = 1
    var detail = ""
    
    override func requestParameters() -> [String : Any]? {
        type = cid.isEmpty ? 1 : 2
        
        let dict: [String : String] = ["c":"article","a":"addcom","token":MLNetConfig.shareInstance.token,"detail":"\(detail)","fid":"3","aid":"\(aid)","cid":"\(cid)","type":"\(type)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

    
}
