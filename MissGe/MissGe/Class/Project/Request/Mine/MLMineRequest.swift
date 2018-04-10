//
//  MLMineQuestionRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/28.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import TUNetworking

//我的提问
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=post&a=myThemePostList&pg=1&size=20&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&uid=19793&orderby=add_date&orderway=desc
class MLMineQuestionRequest: MLBaseRequest {
    var page = 1
    
    //c=post&a=myThemePostList&pg=1&size=20&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU& uid=19793&orderby=add_date&orderway=desc
   override func requestParameters() -> [String : Any]? {
        let dict: [String : String] = ["c":"post","a":"myThemePostList","uid":MLNetConfig.shareInstance.userId,"token":MLNetConfig.shareInstance.token,"pg":"\(page)","size":"20","orderby":"add_date","orderway":"desc"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}

//我的回复
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=post&a=myRethemepostList&pg=1&size=20& token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU& orderby=add_date&orderway=desc
class MLMineAnswerRequest: MLBaseRequest {
    var page = 1
    
    //c=post&a=myRethemepostList&pg=1&size=20&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&orderby=add_date&orderway=desc
    override func requestParameters() -> [String : Any]? {
        //"uid":MLNetConfig.shareInstance.userId,
        let dict: [String : String] = ["c":"post","a":"myRethemepostList","token":MLNetConfig.shareInstance.token,"pg":"\(page)","size":"20","orderby":"add_date","orderway":"desc"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}

//我的收藏
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=article&a=getcollect&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo&page=0&size=20&orderby=add_date
class MLMineFavoriteRequest: MLBaseRequest {
    var page = 1
    
    //c=article&a=getcollect&token=XPdcOIKGqf7nmgZSoqA9eshEbpWRSs7%252B%252BkqAtMdIf5uoyjo&page=0&size=20
    override func requestParameters() -> [String : Any]? {
        //,"orderby":"add_date","orderway":"desc"
        let dict: [String : String] = ["c":"article","a":"getcollect","token":MLNetConfig.shareInstance.token,"pg":"\(page)","size":"20"]
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

//我的评论
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=user&a=comlist&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&page=0&size=20
class MLMineCommentRequest: MLBaseRequest {
    var page = 1
    
    //c=user&a=comlist&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&page=0&size=20
    override func requestParameters() -> [String : Any]? {
        //,"orderby":"add_date","orderway":"desc"
        let dict: [String : String] = ["c":"user","a":"comlist","token":MLNetConfig.shareInstance.token,"pg":"\(page)","size":"20"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}

//圈儿消息
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=user&a=replylistV2&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&pg=1&size=20
class MLMineSquareMessageRequest: MLBaseRequest {
    var page = 1
    
    //c=user&a=replylistV2&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&pg=1&size=20
    override func requestParameters() -> [String : Any]? {
        //,"orderby":"add_date","orderway":"desc"
        let dict: [String : String] = ["c":"user","a":"replylistV2","token":MLNetConfig.shareInstance.token,"pg":"\(page)","size":"20"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}

//文章评论
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=user&a=commelist&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&pg=1&size=20
class MLMineArticleCommentRequest: MLBaseRequest {
    var page = 1
    
    //c=user&a=commelist&token=W6FXbNLV9fnnmgZSoqA9eshEbpWRSs7%252B%252BkqAtMZAf5ijyTU&pg=1&size=20
    override func requestParameters() -> [String : Any]? {
        //,"orderby":"add_date","orderway":"desc"
        let dict: [String : String] = ["c":"user","a":"commelist","token":MLNetConfig.shareInstance.token,"pg":"\(page)","size":"20"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}
