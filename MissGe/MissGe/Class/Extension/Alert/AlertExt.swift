//
//  AlertExt.swift
//  JokeMusic
//
//  Created by chengxianghe on 15/10/30.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

extension UIViewController {

    /// 提供默认的'done' action
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 信息
    ///   - doneTitlt: 确定的标题 default is 'OK'
    ///   - doneHandler: 确定的handler
    func alert(title: String?, message: String?, doneTitlt: String = "OK", doneHandler:(() -> Void)?) {

        let done = UIAlertAction(title: doneTitlt, style: .default) { (action) in
            doneHandler?()
        }
        showAlert(title, message: message, actions: [done])
    }

    /// 提供默认的'cancel'和'done' action
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 信息
    ///   - doneTitlt: 确定的标题 default is 'OK'
    ///   - doneHandler: 确定的handler
    ///   - cancelTitle: 取消的标题 default is 'Cancel'
    ///   - cancelHandler: 取消的handler
    func alert(title: String?, message: String?, doneTitlt: String = "OK", doneHandler:(() -> Void)?, cancelTitle: String = "Cancel", cancelHandler:(() -> Void)?) {

        let done = UIAlertAction(title: doneTitlt, style: .default) { (action) in
            doneHandler?()
        }
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
            cancelHandler?()
        }
        showAlert(title, message: message, actions: [done, cancel])
    }

    func showAlert(_ title: String?, message: String?, actions: [UIAlertAction]?) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        if actions != nil {
            for act in actions! {
                alert.addAction(act)
            }
        }

        self.present(alert, animated: true, completion: nil)
    }

    func actionSheet(_ title: String?, message: String?, firstTitlt: String, firstHandler:(() -> Void)?, destructiveTitlt: String, destructiveHandler:(() -> Void)?, cancelTitle: String = "Cancel", cancelHandler:(() -> Void)?) {
        let first = UIAlertAction(title: firstTitlt, style: .default) { (action) in
            firstHandler?()
        }
        let destructive = UIAlertAction(title: destructiveTitlt, style: .destructive) { (action) in
            destructiveHandler?()
        }
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
            cancelHandler?()
        }
        showActionSheet(title, message: message, actions: [first, destructive, cancel])
    }

    func showActionSheet(_ title: String?, message: String?, actions: [UIAlertAction]?) {

        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        if actions != nil {
            for act in actions! {
                actionSheet.addAction(act)
            }
        }

        self.present(actionSheet, animated: true, completion: nil)
    }

}
