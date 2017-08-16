//
//  MLRegisterController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/25.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import ObjectMapper
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MLRegisterController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var surePasswordTextField: UITextField!
    
    @IBOutlet weak var sureButton: UIButton!
    @IBOutlet weak var verificationCodeButton: UIButton!
    @IBOutlet weak var userAllowProtocolButton: UIButton!
    
    fileprivate var timer: Timer?
    fileprivate var endDate: TimeInterval?

    fileprivate let registerRequest = MLRegisterRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.phoneTextField.delegate = self
        self.verificationCodeTextField.delegate = self
        self.nameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.surePasswordTextField.delegate = self
    }

    @IBAction func onViewClick() {
        self.view.endEditing(true)
    }
    
    @IBAction func onSureBtnClick(_ sender: UIButton) {
        self.onViewClick()
        
        if self.phoneTextField.text?.length > 0
            && self.verificationCodeTextField.text?.length > 0
            && self.nameTextField.text?.length > 0
            && self.passwordTextField.text?.length > 0
            && self.surePasswordTextField.text?.length > 0 {
            sender.isEnabled = false
            self.showLoading("正在加载...")
            
            registerRequest.username = phoneTextField.text!
            registerRequest.password = passwordTextField.text!
            
            registerRequest.send(success: {[unowned self] (baseRequest, responseObject) in
                
                let user = MLUserModel(JSON: ((responseObject as! NSDictionary)["content"] as! [String:Any])["userinfo"]! as! [String:Any]) as MLUserModel?;
    
                if user != nil && user?.token?.length > 0 {
                    self.showSuccess("注册成功")
//                    MLNetConfig.updateUser(user)
//                    NotificationCenter.default.post(name: Notification.Name(rawValue: kUserLoginSuccessed), object: nil);
                    self.dismissPost(true)
                } else {
                    self.showError("注册失败")
                    sender.isEnabled = true
                }
                
                /* 登录成功的返回
                 {
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
                 }*/
                
                
            }) { (baseRequest, error) in
                sender.isEnabled = true
                guard let err = error as? NSError else {
                    self.showError("注册失败\n\(error.localizedDescription)")
                    return
                }
                self.showError("注册失败\n\(String(describing: err.userInfo["msg"]))")
                print(error)
            }
        } else {
            self.showMessage("请输入账号和密码")
        }
        
    }
    
    func dismissPost(_ isPostSuccess: Bool) {
        self.dismiss(animated: true) {
//            self.dismissClosure?(isPostSuccess);
        }
    }
    
    
    @IBAction func onUserProtocolBtnClick(_ sender: UIButton) {
        self.navigationController?.pushViewController(UIViewController(), animated: true)
    }
    
    @IBAction func onUserAllowProtocolBtnClick(_ sender: UIButton) {
        
    }
    
    @IBAction func onVerificationCodeBtnClick(_ sender: UIButton) {
//        self.onViewClick()
        if self.phoneTextField.text?.length == 0 {
            self.showMessage("请输入手机号")
            return
        }
        
        sender.isUserInteractionEnabled = false
        self.showLoading("正在加载...")
        
        let request = MLRegisterCheckVerificationCodeRequest()
        request.send(success: { (baseRequest, responseObject) in
            self.showSuccess("验证码发送成功")
            self.startTimer()
        }) { (baseRequest, error) in
            sender.isUserInteractionEnabled = true
            self.showError("发送验证码失败\n\(error.localizedDescription)")
            print(error)
        }
        
    }
    
    func startTimer() {
        self.stopTimer()
        self.endDate = Date().timeIntervalSince1970 + 61;
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerHandler), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil;
    }
    
    func timerHandler() {

        let date = Date().timeIntervalSince1970
        let time = self.endDate! - date;
        if (time <= 0) {
            self.stopTimer()
            self.verificationCodeButton.isUserInteractionEnabled = true;
            self.verificationCodeButton.setTitle("再次发送验证码", for: .normal)
    
        } else {
            self.verificationCodeButton.setTitle(String(format: "%02d s", time), for: .normal)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.onViewClick()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.surePasswordTextField.becomeFirstResponder()
        } else if textField == self.surePasswordTextField {
            self.onSureBtnClick(self.sureButton)
        } else {
            self.onViewClick()
        }
        
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
