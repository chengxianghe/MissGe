//
//  MLDeleteRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/26.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

//删文章评论
//GET http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=article&a=delcom&cid=10485&token=DvZRa4KBqPPnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdNfJapzDo
class MLDeleteArticleCommentRequest: MLBaseRequest {
    var cid = ""
    
    //c=article&a=delcom&cid=10485&token=DvZRa4KBqPPnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdNfJapzDo
    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"article","a":"delcom","token":MLNetConfig.shareInstance.token,"cid":"\(cid)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    


}

//删除 圈儿评论
//GET http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=post&a=delPost&pid=40443&token=DvZRa4KBqPPnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdNfJapzDo
// 一样的
//删除 圈儿动态
//GET http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=post&a=delPost&pid=40444&token=DvZRa4KBqPPnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdNfJapzDo
class MLDeleteTopicRequest: MLBaseRequest {

    var pid = ""
    
    //c=post&a=delPost&pid=40444&token=DvZRa4KBqPPnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdNfJapzDo
    override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"post","a":"delPost","token":MLNetConfig.shareInstance.token,"pid":"\(pid)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}
