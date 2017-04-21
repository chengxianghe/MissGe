//
//  MLHomeCommentListRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/23.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=article&a=comlist&aid=7992&pg=1&size=20
class MLHomeCommentListRequest: MLBaseRequest {
    
    var page = 1
    var aid = ""
    
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"article","a":"comlist","aid":"\(aid)","pg":"\(page)","size":"20"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}
