//
//  MLNetConfig.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/19.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import TUNetworking
import ObjectMapper

let kServiceKey: String = "com.cxh.missli.user"
let kUserLogoutSuccessed = "MLUserLogoutSuccessed"
let kUserLoginSuccessed = "MLUserLoginSuccessed"

class MLNetConfig: NSObject, TUNetworkConfigProtocol {
    /// 校验请求结果
    public func requestVerifyResult(_ result: Any) -> Bool {
        guard let dict = result as? NSDictionary else {
            return false
        }

        return (dict["result"] as? String) == "200"
    }

    static let shareInstance = MLNetConfig()

    var userId: String {
        get {
            return self.user?.uid ?? "0"
        }
    }
    var token: String {
        set {
            self.user.token = newValue
        }
        get {
            return self.user?.token ?? ""
        }
    }
    var publicParameters: [AnyHashable: Any]! = ["output":"json",
                                                     "_app_key":"f722d367b8a96655c4f3365739d38d85",
                                                     "_app_secret":"30248115015ec6c79d3bed2915f9e4cc"]
    let user: MLUserModel! = MLUserModel(JSON: ["":""])

    func requestPublicParameters() -> [AnyHashable: Any]? {
        return self.publicParameters
    }

    func configUserId() -> String {
        return self.userId
    }

    override init() {
        super.init()
        self.getUserFromLocal()
    }

    static func config() -> TUNetworkConfigProtocol {
        return MLNetConfig.shareInstance
    }

    func requestMethod() -> TURequestMethod {
        return TURequestMethod.get
    }

    func requestSerializerType() -> TURequestSerializerType {
        return TURequestSerializerType.HTTP
    }

    func requestPublicParametersType() -> TURequestPublicParametersType {
        return TURequestPublicParametersType.url
    }

    func requestHost() -> String? {
        return "t.gexiaojie.com/api.php?"
    }

    func getUserFromLocal() {
        if let userJSON = KeychainTool.load(kServiceKey) {
//            self.user.yy_modelSet(withJSON: userJSON)
            if let tempUser = MLUserModel(JSONString: userJSON) {
                self.setWithNewUser(tempUser: tempUser)
            }

        }
    }

    func setWithNewUser(tempUser: MLUserModel) {
        self.user.token = tempUser.token
        self.user.username = tempUser.username
        self.user.nickname = tempUser.nickname
        self.user.autograph = tempUser.autograph
        self.user.uid = tempUser.uid

        self.user.verify_img_width = tempUser.verify_img_width
        self.user.verify_img_height = tempUser.verify_img_height
        self.user.relation = tempUser.relation
        self.user.avatar = tempUser.avatar
        self.user.verify = tempUser.verify
        self.user.verify_img = tempUser.verify_img

        self.user.p_bests = tempUser.p_bests
        self.user.follow_cnt = tempUser.follow_cnt
        self.user.fans_cnt = tempUser.fans_cnt
        self.user.gender = tempUser.gender
        self.user.birthday = tempUser.birthday
        self.user.location = tempUser.location
        self.user.username = tempUser.username
    }

    static func updateUser(_ user: MLUserModel?) {
        guard let saveUser = user else {
            KeychainTool.save(service: kServiceKey, data: nil)
            return
        }
        if saveUser.token == nil {
            saveUser.token = self.shareInstance.user.token
        }
        if let userJSON = saveUser.toJSONString() {
            KeychainTool.save(service: kServiceKey, data: userJSON)
            if let tempUser = MLUserModel(JSONString: userJSON) {
                self.shareInstance.setWithNewUser(tempUser: tempUser)
            }
//            self.shareInstance.user.yy_modelSet(withJSON: userJSON)
        }
    }

    static func checkToken() {

    }

    static func logout() {
        self.shareInstance.token = ""

    }

    static func isUserLogin() -> Bool {
        return self.shareInstance.token.length > 0
    }

}
