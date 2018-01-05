//
//  MLRequestHelper.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/27.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import TUNetworking

class MLRequestHelper: NSObject {
    static let shareInstance = MLRequestHelper();
    
// Send Request
    static func sendRequestWith(_ request: TUBaseRequest, succeed: @escaping TURequestSuccess, failed: @escaping TURequestFailur) {
        request.send(success: succeed, failur: failed)
    }
    
    static func likeCommentWith(_ pid: String, succeed: @escaping TURequestSuccess, failed: @escaping TURequestFailur) {
//        MLLikeCommentRequest
        let request = MLLikeCommentRequest()
        request.pid = pid
        self.sendRequestWith(request, succeed: succeed, failed: failed)
    }
    
    static func likeArticleWith(_ aid: String, succeed: @escaping TURequestSuccess, failed: @escaping TURequestFailur) {
//        MLLikeArticleRequest
        let request = MLLikeArticleRequest()
        request.aid = aid
        
        self.sendRequestWith(request, succeed: succeed, failed: failed)
    }
    
    static func deleteTopicWith(_ pid: String, success successCallback: @escaping (Any) -> Void, failure failureCallback: @escaping(Error) -> Void) {
        TUNetwork.request(.DeleteTopic(pid: pid), success: successCallback, failure: failureCallback)
    }

    static func deleteArticleWith(_ cid: String, success successCallback: @escaping (Any) -> Void, failure failureCallback: @escaping(Error) -> Void) {
        TUNetwork.request(.DeleteArticleComment(cid: cid), success: successCallback, failure: failureCallback)
    }
    
    static func favoriteWith(_ tid: String, succeed: @escaping TURequestSuccess, failed: @escaping TURequestFailur) {
//        MLHomeFavoriteRequest
        let request = MLHomeFavoriteRequest()
        request.tid = tid

        self.sendRequestWith(request, succeed: succeed, failed: failed)
    }
    
    static func userFollow(_ uid: String, succeed: @escaping TURequestSuccess, failed: @escaping TURequestFailur) {
        //        MLHomeFavoriteRequest
        let request = MLUserFollowRequest()
        request.uid = uid
        
        self.sendRequestWith(request, succeed: succeed, failed: failed)
    }
}
