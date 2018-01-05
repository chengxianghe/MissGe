//
//  TUNetwork.swift
//  MissGe
//
//  Created by chengxianghe on 2017/11/29.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import Moya

struct TUNetwork {
    static let provider = MoyaProvider<APIManager>(endpointClosure: kAPIManagerEndpointClosure, requestClosure: kAPIManagerRequestClosure)
    
    static func request(_ target: APIManager, success successCallback: @escaping (Any) -> Void, failure failureCallback: @escaping(Error) -> Void) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                var error: NSError? = nil
                do {
                    //如果数据返回成功则直接将结果转为JSON
                    let res = try response.filterSuccessfulStatusCodes()
                    let resultObject = try res.mapJSON()
                    
                    if let dict = resultObject as? [String : Any] {
                        if let code = dict["result"] as? String {
                            if code != "200" {
                                var msg = ""
                                if let message = dict["msg"] as? String {
                                    msg = message
                                }
                                error = NSError(domain: "Network", code: Int(code)!, userInfo: [NSLocalizedDescriptionKey: msg])
                            }
                        }
                    } else {
                        error = NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "result not object"])
                    }
                    //后台的数据每次会返回code只有是200才会表示逻辑正常执行
                    if error == nil {
                        successCallback(resultObject)
                    } else {
                        failureCallback(error!)
                    }
                }
                catch let error {
                    failureCallback(error)
                }
            case let .failure(error):
                failureCallback(error)
            }
        }
    }
}
