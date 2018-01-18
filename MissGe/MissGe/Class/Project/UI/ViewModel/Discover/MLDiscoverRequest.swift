//
//  MLDiscoverRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/19.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=column&a=topiclist&pg=1&size=5
class MLDiscoverRequest: MLBaseRequest {
    
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"column","a":"topiclist","pg":"1","size":"5"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

    
}

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=tag&a=hot
class MLDiscoverTagRequest: MLBaseRequest {
    
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"tag","a":"hot"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

    
}

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=column&a=topiclist&pg=1&size=20
class MLDiscoverMoreRequest: MLBaseRequest {
    
    var page = 1
    
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"column","a":"topiclist","pg":"\(page)","size":"20"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

    
}
