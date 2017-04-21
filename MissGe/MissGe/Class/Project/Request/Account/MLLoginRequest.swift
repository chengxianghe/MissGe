//
//  MLLoginRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/19.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit



/*
{
    "msg": "亲爱的，18500522314 欢迎您，登录成功！",
    "result": "200",
    "content": {
        "userinfo": {
            "uid": "19793",
            "uname": "18500522314",
            "nickname": "云逸",
            "token": "BvBdN4eCrqnnmgZSoqA9eshEbpWRSs7%2B%2BkqAtMdMf5usyj8",
            "avatar": "",
            "p_bests": 0,
            "verify": "",
            "verify_img": "",
            "verify_img_width": 0,
            "verify_img_height": 0,
            "follow_cnt": 2,
            "fans_cnt": 0,
            "autograph": "说点什么好呢"
        }
    }
}*/
class MLLoginRequest: MLBaseRequest {
    var password = ""
    var username = ""

    //c=user&a=login&username=18500522314&password=cheng613637
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"user","a":"login","username":"\(username)", "password":"\(password)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    


}

//注册 获取手机验证码
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=sms&a=getRegSMS&mobile=18500522314
class MLRegisterVerificationCodeRequest: MLBaseRequest {
    var mobile = ""
    
    //c=sms&a=getRegSMS&mobile=18500522314
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"sms","a":"getRegSMS","mobile":"\(mobile)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}

//注册 校验手机验证码
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=sms&a=verifyCode&mobile=18500522314&captcha=338274
class MLRegisterCheckVerificationCodeRequest: MLBaseRequest {
    var verificationCode = ""
    var mobile = ""
    
    //c=sms&a=verifyCode&mobile=18500522314&captcha=338274
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"sms","a":"verifyCode","mobile":"\(mobile)", "captcha":"\(verificationCode)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}

//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=user&a=doregV2&username=%E4%BA%91%E9%80%B8&password=cheng613637&mobile=18500522314
class MLRegisterRequest: MLBaseRequest {
    var password = ""
    var username = ""
    var mobile = ""

    //c=user&a=doregV2&username=%E4%BA%91%E9%80%B8&password=cheng613637&mobile=18500522314
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"user","a":"doregV2","username":"\(username)", "password":"\(password)", "mobile":"\(mobile)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}

//找回密码
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=sms&a=findpwd&user=18866575582
class MLFindPasswordRequest: MLBaseRequest {

    var user = ""
    
    //c=sms&a=findpwd&user=18866575582
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"sms","a":"findpwd","user":"\(user)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}

//找回密码验证手机验证码
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=sms&a=verifyForgot&user=18500522314&code=196631
class MLFindPasswordVerificationCodeRequest: MLBaseRequest {
    var verificationCode = ""
    var user = ""
    
    //c=sms&a=verifyForgot&user=18500522314&code=196631
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"sms","a":"verifyForgot","user":"\(user)", "code":"\(verificationCode)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}

//重置密码
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=sms&a=renewPwd&user=18500522314&code=196631&newpwd=613637
class MLFindPasswordNewPasswordRequest: MLBaseRequest {
    var verificationCode = ""
    var user = ""
    var newpwd = ""
    
    //c=sms&a=renewPwd&user=18500522314&code=196631&newpwd=613637
    override func requestParameters() -> [String : Any]? {
        let dict = ["c":"sms","a":"renewPwd","user":"\(user)", "code":"\(verificationCode)", "newpwd":"\(newpwd)"]
        return dict
    }
    
    override func requestHandleResult() {
        print("requestHandleResult -- \(self.classForCoder)")
    }
    

}



//注册 手机验证码
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=sms&a=getRegSMS&mobile=18500522314
//
//注册 校验验证码
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=sms&a=verifyCode&mobile=18500522314&captcha=338274
// 注册
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=user&a=doregV2&username=%E4%BA%91%E9%80%B8&password=cheng613637&mobile=18500522314
//
//登录
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=user&a=login&username=18500522314&password=cheng613637
//
//找回密码
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=sms&a=findpwd&user=18866575582
//
//找回密码验证手机验证码
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=sms&a=verifyForgot&user=18500522314&code=196631
//
//重置密码
//http://t.gexiaojie.com/api.php?&output=json&_app_key=f722d367b8a96655c4f3365739d38d85&_app_secret=30248115015ec6c79d3bed2915f9e4cc&c=sms&a=renewPwd&user=18500522314&code=196631&newpwd=613637
