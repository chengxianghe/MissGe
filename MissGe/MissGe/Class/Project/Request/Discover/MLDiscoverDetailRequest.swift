//
//  MLDiscoverDetailRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/26.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

// 点击banner type = 2
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=article&a=getRelation&pg=1&aid=8325&size=20

//点击tag
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=column&a=getArticleByTag&pg=0&tag_id=568&size=20

//搜索结果
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=column&a=artlist&pg=1&keywords=%E6%88%91&size=20
class MLDiscoverDetailRequest: MLBaseRequest {
    var page = 1
    var tag_id = ""
    var subjectType = SubjectType.banner
    
    //c=article&a=getRelation&pg=1&aid=8325&size=20
    //c=column&a=getArticleByTag&pg=0&tag_id=568&size=20
    //c=column&a=artlist&pg=1&keywords=%E6%88%91&size=20
    override func requestParameters() -> [String : Any]? {
        var dict: [String : String]?
        if subjectType == .banner {
            dict = ["c":"article","a":"getRelation","aid":"\(tag_id)","pg":"\(page)","size":"20"]
        } else if subjectType == .tag {
            dict = ["c":"column","a":"getArticleByTag","tag_id":"\(tag_id)","pg":"\(page)","size":"20"]
        } else {
            dict = ["c":"column","a":"artlist","pg":"\(page)","size":"20","keywords":"\(tag_id)"]
        }
        
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    


}
