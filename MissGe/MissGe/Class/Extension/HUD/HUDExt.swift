//
//  SVProgressHUDExt.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/3.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import SVProgressHUD

extension SVProgressHUD {
    static func JCHUDConfig() {
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
        SVProgressHUD.setSuccessImage(UIImage(named: "success")!)
        SVProgressHUD.setErrorImage(UIImage(named: "error")!)
    }
}

extension UIViewController {
    
    /**
     *  显示加载状态
     */
    func showLoading(_ message: String) {
        SVProgressHUD.show(withStatus: message)
    }
    
    /**
     *  显示错误状态 1s后自动消失
     */
    func showError(_ message: String) {
        SVProgressHUD.showError(withStatus: message)
        
    }
    
    /**
     *  显示成功状态 1s后自动消失
     */
    func showSuccess(_ message: String) {
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    /**
     *  是否正在展示HUD
     */
    func isShowingHud() -> Bool {
        return SVProgressHUD.isVisible()
    }
    
    /**
     *  手动隐藏HUD
     */
    func hideHud(after time: TimeInterval = 0) {
        SVProgressHUD.dismiss(withDelay: time)
    }
    
    
    /**
     *  展示一条文字信息 MB
     */
    func showMessage(_ message: String) {
        SVProgressHUD.showInfo(withStatus: message)
//        self.showMessage(message, yOffset: 0)
    }
    
    
    //MARK: MB 显示信息 纯文字 2s后消失MBProgressHUD
    // 从默认(showMessage:)显示的位置再往上(下)yOffset
//    func showMessage(message: String, yOffset y: CGFloat) {
        //显示提示信息
//        let  view = UIApplication.sharedApplication().delegate?.window;
//        let hud = MBProgressHUD.showHUDAddedTo(view!, animated: true)
//        hud.userInteractionEnabled = false;
//        // Configure for text only and offset down
//        hud.mode = MBProgressHUDMode.Text;
//        hud.labelText = message;
//        hud.margin = 10.0;
//        hud.yOffset += Float(kScreenHeight * 0.3)
//        hud.removeFromSuperViewOnHide = true;
//        hud.hide(true, afterDelay: 2.0)
//    }

}
