//
//  MLHomeDetailRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/22.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

//文章详情
//http://t.gexiaojie.com/index.php?m=mobile&c=explorer&a=article&aid=8229

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=article&a=contentV2&aid=8229
class MLHomeDetailRequest: MLBaseRequest {
    
    var aid = ""
    
    //c=article&a=contentV2&aid=8229
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"article","a":"contentV2","aid":"\(aid)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

    
}
