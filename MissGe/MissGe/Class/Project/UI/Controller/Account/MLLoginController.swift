//
//  MLLoginController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/25.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import ObjectMapper

class MLLoginController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var accountTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    var dismissClosure: PublishDismissClosure?
    fileprivate let loginRequest = MLLoginRequest()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.accountTextField.delegate = self
        self.passwordTextField.delegate = self

        self.accountTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    @IBAction func onBackBtnClick(_ sender: UIButton) {
        self.onViewClick()
        self.dismissPost(false)
    }

    func dismissPost(_ isPostSuccess: Bool) {
        self.dismiss(animated: true) {
            self.dismissClosure?(isPostSuccess)
        }
    }

    @IBAction func onViewClick() {
        self.view.endEditing(true)
    }

    @IBAction func onLoginBtnClick(_ sender: UIButton) {
        self.onViewClick()

        if (self.accountTextField.text?.count)! > 0 && (self.passwordTextField.text?.count)! > 0 {
            sender.isEnabled = false
            self.showLoading("正在加载...")

            loginRequest.username = accountTextField.text!
            loginRequest.password = passwordTextField.text!

            loginRequest.send(success: {[unowned self] (baseRequest, responseObject) in
                let user = MLUserModel(JSON: ((responseObject as! NSDictionary)["content"] as! NSDictionary)["userinfo"] as! [String: Any])

                if user != nil && (user!.token?.length)! > 0 {
                    self.showSuccess("登录成功")
                    MLNetConfig.updateUser(user)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kUserLoginSuccessed), object: nil)

                    self.dismissPost(true)
                } else {
                    self.showError("登录失败")
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
                self.showError("登录失败\n\(error.localizedDescription)")
                print(error)
            }
        } else {
            self.showMessage("请输入账号和密码")
        }

    }

    @IBAction func onWeiboBtnClick(_ sender: UIButton) {
        self.onViewClick()

    }

    @IBAction func onQQBtnClick(_ sender: UIButton) {
        self.onViewClick()

    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.onViewClick()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.accountTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.onLoginBtnClick(self.loginButton)
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
