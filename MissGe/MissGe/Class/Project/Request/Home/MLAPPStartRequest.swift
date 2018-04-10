//
//  MLAPPStartRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/19.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import ObjectMapper

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=app&a=getlaunch&type=ios
class MLAPPStartRequest: MLBaseRequest {
    
    var adModel: MLHomeBannerModel?
    
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"app","a":"getlaunch","type":"ios"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
        if let result = (self.responseObject as? NSDictionary)?["content"] as? [String:Any] {
            self.adModel = MLHomeBannerModel(JSON: result);
        }
    }
    
    override func requestVerifyResult() -> Bool {
        guard let dict = self.responseObject as? NSDictionary else {
            return false
        }
        
        return (dict["result"] as? String) == "200"
    }

}

/**
 {
    "result": "200",
    "content": {
        "path": "http://img.gexiaojie.com/launch_image/2016/0711/160711135425P301917V71.jpg",
        "ext": "jpg",
        "width": "720",
        "height": "1280",
        "size": "429800",
        "summary": ""
    },
    "msg": "正确返回"
}
*/
