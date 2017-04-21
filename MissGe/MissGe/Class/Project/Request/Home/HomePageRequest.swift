//
//  HomePageRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/19.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

//t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=column&a=indexchoiceV2&pg=0&size=20

class HomePageRequest: MLBaseRequest {
    
    var page = 0
    
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"column","a":"indexchoiceV2","pg":"\(page)","size":"20"]
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

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=app&a=getslide&type=ios
class HomePageBannerRequest: MLBaseRequest {
    
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"app","a":"getslide","type":"ios"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
}
