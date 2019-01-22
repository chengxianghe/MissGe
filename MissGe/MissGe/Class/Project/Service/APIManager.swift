//
//  APIManager.swift
//  RxMissGe
//
//  Created by chengxianghe on 2017/11/27.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import Moya
import Result
import ObjectMapper
import RxSwift

let kNetWorkActivityPlugin = NetworkActivityPlugin { (change, _)  -> Void in
    switch(change) {
    case .ended:
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    case .began:
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}

//public final class kAPIManagerRequestPlugin: PluginType {
//    /// Called immediately before a request is sent over the network (or stubbed).
//    public func willSend(_ request: RequestType, target: TargetType) {
//    }
//
//    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
//        switch result {
//        case .success(let response):
//            let json:Dictionary? = try! JSONSerialization.jsonObject(with: response.data,                                                                     options:.allowFragments) as! [String: Any]
//            print(json as Any)
//            print("加载成功")
//        case .failure:
//            print("加载失败")
//            break
//        }
//    }
//}

let kAPIManagerEndpointClosure = { (target: APIManager) -> Endpoint in
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
//    let _ = defaultEndpoint.adding(newHTTPHeaderFields: ["output":"json",
//                                                         "_app_key":"f722d367b8a96655c4f3365739d38d85",
//                                                         "_app_secret":"30248115015ec6c79d3bed2915f9e4cc"])
    return defaultEndpoint
}

let kAPIManagerRequestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        // Modify the request however you like.
        print(request)
        done(.success(request))
    } catch (let error) {
        print("error: \(error)")
        done(.failure(MoyaError.underlying(error, nil)))
    }

}

enum APIManager {
    case Login(username: String, password: String)
    case Register(username: String, password: String, String)
    case FindPassword(String)
    case VerificationCode(String)
    case HomePage(Int) // 获取首页列表
    case HomePageBanner  // 首页轮播图
    case HomeCommentList(String, Int) // 获取首页评论列表
    case HomePageDetail(String)  // 获取详情页
    case AppStart
    case DeleteTopic(pid: String)
    case DeleteArticleComment(cid: String)
    case LikeComment(pid: String)
    case LikeArticle(aid: String)
    //    var aid = "" var cid = "" /// type 1 正常评论; 2 回复别人 var detail = ""
    case AddHomeComment(aid: String, cid: String, detail: String)
    case HomeFavorite(tid: String)
    case DiscoverDetail(page: Int, tag_id: String, type: SubjectType)
    case Discover
    case DiscoverTag
    case DiscoverMore(page: Int)
    case TopicComment(anonymous: Int, tid: String, quote: String, detail: String)
    case TopicSetBestComment(pid: String, state: Int)
    case PostTopic(anonymous: Int, ids: [String]?, detail: String)
    case Square(page: Int)
    case SquareFriends(page: Int)
}

extension APIManager: TargetType {
    var baseURL: URL {
        return URL.init(string: "http://t.gexiaojie.com/api.php")!
    }

    var path: String {
        return ""
    }

    var method: Moya.Method {
        switch self {
        case .Login(_, _):
            return .post
        default:
            return .get
        }
    }

    var sampleData: Data {
        return Data()
    }

    public var parameters: [String: Any]? {
        var dict = [String: Any]()

        switch self {
        case .AppStart:
            dict = ["c":"app", "a":"getlaunch", "type":"ios"]
        case .Login(_, _):
            return    [
                "grant_type":"password",
                "redirect_uri":"http://www.douban.com/mobile/fm",
                "client_id":"02646d3fb69a52ff072d47bf23cef8fd",
                "client_secret":"cde5d61429abcd7c",
                "udid":"b88146214e19b8a8244c9bc0e2789da68955234d",
                "alt":"json",
                "apikey":"02646d3fb69a52ff072d47bf23cef8fd",
                "device_id":"b88146214e19b8a8244c9bc0e2789da68955234d",
                "douban_udid":"b635779c65b816b13b330b68921c0f8edc049590"
            ]
        case .HomePage(let page):
            dict = ["c":"column", "a":"indexchoiceV2", "pg":"\(page)", "size":"20"]
        case .HomePageDetail(let aid):
            dict = ["c":"article", "a":"contentV2", "aid":"\(aid)"]
        case .HomePageBanner:
            dict = ["c":"app", "a":"getslide", "type":"ios"]
        case .HomeCommentList(let aid, let page):
            dict = ["c":"article", "a":"comlist", "aid":"\(aid)", "pg":"\(page)", "size":"20"]
        case .DeleteTopic(pid: let pid):
            dict = ["c":"post", "a":"delPost", "token":MLNetConfig.shareInstance.token, "pid":"\(pid)"]
        case .DeleteArticleComment(cid: let cid):
            dict = ["c":"article", "a":"delcom", "token":MLNetConfig.shareInstance.token, "cid":"\(cid)"]
        case .LikeComment(pid: let pid):
            dict = ["c":"post", "a":"likeit", "pid":"\(pid)"]
        case .LikeArticle(aid: let aid):
            dict = ["c":"article", "a":"likeit", "aid":"\(aid)"]
        case .AddHomeComment(aid: let aid, cid: let cid, detail: let detail):
            let type: Int = cid.isEmpty ? 1 : 2
            dict = ["c":"article", "a":"addcom", "token":MLNetConfig.shareInstance.token, "detail":"\(detail)", "fid":"3", "aid":"\(aid)", "cid":"\(cid)", "type":"\(type)"]
        case .HomeFavorite(tid: let tid):
            dict = ["c":"article", "a":"upcollect", "tid":"\(tid)", "token":MLNetConfig.shareInstance.token]
        case .DiscoverDetail(let page, let tag_id, let subjectType):
            if subjectType == .banner {
                dict = ["c":"article", "a":"getRelation", "aid":"\(tag_id)", "pg":"\(page)", "size":"20"]
            } else if subjectType == .tag {
                dict = ["c":"column", "a":"getArticleByTag", "tag_id":"\(tag_id)", "pg":"\(page)", "size":"20"]
            } else {
                dict = ["c":"column", "a":"artlist", "pg":"\(page)", "size":"20", "keywords":"\(tag_id)"]
            }
        case .Discover:
            dict = ["c":"column", "a":"topiclist", "pg":"1", "size":"5"]
        case .DiscoverTag:
            dict = ["c":"tag", "a":"hot"]
        case .DiscoverMore(page: let page):
            dict = ["c":"column", "a":"topiclist", "pg":"\(page)", "size":"20"]
        case .TopicComment(anonymous: let anonymous, tid: let tid, quote: let quote, detail: let detail):
            dict = ["c":"post", "a":"reply", "token":MLNetConfig.shareInstance.token, "detail":"\(detail)", "fid":"3", "tid":"\(tid)", "quote":"\(quote)", "anonymous":"\(anonymous)"]
        case .TopicSetBestComment(pid: let pid, state: let state):
            dict = ["c":"post", "a":"bestRepost", "token":MLNetConfig.shareInstance.token, "pid":"\(pid)", "state":"\(state)"]
        case .PostTopic(anonymous: let anonymous, ids: let ids, detail: let detail):
            let title: String = detail.length > 10 ? (detail as NSString).substring(to: 10) : detail
            dict = ["c":"post", "a":"addpost", "token":MLNetConfig.shareInstance.token, "detail":"\(detail)", "anonymous":"\(anonymous)", "title":title, "fid":"3"]
            if ids != nil && ids!.count > 0 {
                dict["ids"] = ids!.joined(separator: ",")
            }
        case .Square(page: let page):
            dict = ["c":"forum", "a":"postlist", "fid":"3", "token":"(null)", "pg":"\(page)", "size":"20", "d":22] as [String: Any]
        case .SquareFriends(page: let page):
            dict = ["c":"forum", "a":"postlist", "fid":"3", "token":"(null)", "pg":"\(page)", "size":"20", "type":"follow", "token":MLNetConfig.shareInstance.token]
        default:
            break
        }

        let publicDict = ["output":"json",
                    "_app_key":"f722d367b8a96655c4f3365739d38d85",
                    "_app_secret":"30248115015ec6c79d3bed2915f9e4cc"]
        publicDict.forEach { (key, value) in
            dict[key] = value
        }
        return dict
    }

    var task: Task {
        switch self {
        case .Login(username: let username, password: let password):
            var parameters = self.parameters!
            parameters["username"] = username
            parameters["password"] = password
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            return .requestParameters(parameters: self.parameters ?? [:], encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return nil
    }

}
