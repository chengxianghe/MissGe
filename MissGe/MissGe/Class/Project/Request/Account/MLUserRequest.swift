//
//  MLUserRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/24.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=user&a=getUserInfo&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo&uid=19793
class MLUserInfoRequest: MLBaseRequest {
    var uid = ""
    
    //c=user&a=getUserInfo&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo&uid=19793
    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"user","a":"getUserInfo","uid":"\(uid)","token":MLNetConfig.shareInstance.token]
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

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=post&a=myThemePostList&pg=1&size=20&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo&uid=19793&orderby=add_date&orderway=desc
class MLUserTopicListRequest: MLBaseRequest {
    
    var uid = ""
    var page = 0

    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"post","a":"myThemePostList","pg":"\(page)","size":"20","token":MLNetConfig.shareInstance.token, "uid":"\(uid)", "orderby":"add_date", "orderway":"desc"]
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

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=follow&a=set&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo&uid=13899
class MLUserFollowRequest: MLBaseRequest {
    
    var uid = ""
    
    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"follow","a":"set","uid":"\(uid)","token":MLNetConfig.shareInstance.token]
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

//关注列表
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=follow&a=getFollowed&uid=19793&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo
class MLUserFollowListRequest: MLBaseRequest {
    var uid = ""
    
    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"follow","a":"getFollowed","token":MLNetConfig.shareInstance.token, "uid":"\(uid)"]
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

//粉丝列表
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=follow&a=getFans&uid=19793&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=follow&a=getFans&uid=13899&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo
class MLUserFansListRequest: MLBaseRequest {
    var uid = ""
    
    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"follow","a":"getFans","token":MLNetConfig.shareInstance.token, "uid":"\(uid)"]
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

//更改资料
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=user&a=modifyUserInfoV2&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo&
//地址: field=location&value=11%7C1105
//性别: field=gender&value=3
//昵称: field=nickname&value=%E4%BA%91%E9%80%B8%E5%BD%B1
//生日: field=birthday&value=753350704.000000
//简介: field=autograph&value=%E8%AF%B4%E7%82%B9%E4%BB%80%E4%B9%88%E5%A5%BD%E5%91%A2
class MLUserModifyInfoRequest: MLBaseRequest {
    
    enum FieldType: String {
        case location = "location" //地址
        case gender = "gender" //性别
        case nickname = "nickname" //昵称
        case birthday = "birthday" //生日
        case autograph = "autograph" //简介
    }
    
    var field: FieldType!
    var value = ""
    
    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"user","a":"modifyUserInfo","token":MLNetConfig.shareInstance.token, "field":"\(field.rawValue)","value":"\(value)"]
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

