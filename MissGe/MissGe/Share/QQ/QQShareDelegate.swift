//
//  QQShareDelegate.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/6.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import SVProgressHUD

class QQShareDelegate: NSObject, QQApiInterfaceDelegate {

    static let currenQQshareDelegate = QQShareDelegate()

    /**
     处理来至QQ的请求
     */
    func onReq(_ req: QQBaseReq!) {

    }

    /**
    处理来至QQ的响应
    */
    func onResp(_ resp: QQBaseResp!) {

        if resp.isKind(of: SendMessageToQQResp.classForCoder()) {

            var codeStr = "分享成功"
            if(resp.errorDescription.length == 0) {
                // 发出通知 返积分
                SVProgressHUD.showSuccess(withStatus: codeStr)

            } else if(resp.result == "-4") {
                codeStr = "取消分享"
                SVProgressHUD.showInfo(withStatus: codeStr)
            } else {
                codeStr = "分享失败"
                SVProgressHUD.showError(withStatus: codeStr)
            }

            print("处理来至QQ的响应:" + codeStr)
        }

    }

    /**
     处理QQ在线状态的回调
     */
    func isOnlineResponse(_ response: [AnyHashable: Any]!) {

    }
}
