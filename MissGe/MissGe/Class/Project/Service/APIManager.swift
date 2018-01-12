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

let kNetWorkActivityPlugin = NetworkActivityPlugin { (change,target)  -> () in
    switch(change){
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

let kAPIManagerEndpointClosure = { (target: APIManager) -> Endpoint<APIManager> in
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
//    let _ = defaultEndpoint.adding(newHTTPHeaderFields: ["output":"json",
//                                                         "_app_key":"f722d367b8a96655c4f3365739d38d85",
//                                                         "_app_secret":"30248115015ec6c79d3bed2915f9e4cc"])
    return defaultEndpoint
}

let kAPIManagerRequestClosure = { (endpoint: Endpoint<APIManager>, done: MoyaProvider.RequestResultClosure) in
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


enum APIManager{
    case Login(String, String)
    case Register(String, String, String)
    case FindPassword(String)
    case VerificationCode(String)
    case HomePage(Int) // 获取首页列表
    case HomePageBanner  // 首页轮播图
    case HomeCommentList(String, Int) // 获取首页评论列表
    ////文章详情
    //http://t.gexiaojie.com/index.php?m=mobile&c=explorer&a=article&aid=8229
    //http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=article&a=contentV2&aid=8229
    case HomePageDetail(String)  // 获取详情页
    case AppStart
    case DeleteTopic(pid: String)
    case DeleteArticleComment(cid: String)
    case LikeComment(pid: String)
    case LikeArticle(aid: String)
    //    var aid = "" var cid = "" /// type 1 正常评论; 2 回复别人 var detail = ""
    case AddHomeComment(aid: String, cid: String, detail: String)
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
            dict = ["c":"app","a":"getlaunch","type":"ios"]
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
                "douban_udid":"b635779c65b816b13b330b68921c0f8edc049590",
            ]
        case .HomePage(let page):
            dict = ["c":"column","a":"indexchoiceV2","pg":"\(page)","size":"20"]
        case .HomePageDetail(let aid):
            dict = ["c":"article","a":"contentV2","aid":"\(aid)"]
        case .HomePageBanner:
            dict = ["c":"app","a":"getslide","type":"ios"]
        case .HomeCommentList(let aid, let page):
            dict = ["c":"article","a":"comlist","aid":"\(aid)","pg":"\(page)","size":"20"]
        case .DeleteTopic(pid: let pid):
            dict = ["c":"post","a":"delPost","token":MLNetConfig.shareInstance.token,"pid":"\(pid)"]
        case .DeleteArticleComment(cid: let cid):
            dict = ["c":"article","a":"delcom","token":MLNetConfig.shareInstance.token,"cid":"\(cid)"]
        case .LikeComment(pid: let pid):
            dict = ["c":"post","a":"likeit","pid":"\(pid)"]
        case .LikeArticle(aid: let aid):
            dict = ["c":"article","a":"likeit","aid":"\(aid)"]
        case .AddHomeComment(aid: let aid, cid: let cid, detail: let detail):
            let type: Int = cid.isEmpty ? 1 : 2
            dict = ["c":"article","a":"addcom","token":MLNetConfig.shareInstance.token,"detail":"\(detail)","fid":"3","aid":"\(aid)","cid":"\(cid)","type":"\(type)"]
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
        case .Login(let username, let password):
            var parameters = self.parameters!
            parameters["username"] = username
            parameters["password"] = password
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            return .requestParameters(parameters: self.parameters ?? [:], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
