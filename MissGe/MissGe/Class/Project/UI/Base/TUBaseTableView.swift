//
//  TUBaseTableView.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/19.
//  Copyright © 2017年 cn. All rights reserved.
//

import UIKit

class TUBaseTableView: UITableView {

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        configUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configUI()
    }

    func configUI() {
        self.delaysContentTouches = false
        self.canCancelContentTouches = true
        self.separatorStyle = .none

        // Remove touch delay (since iOS 8)
        guard let wrapView = self.subviews.first else {
            return
        }
        if NSStringFromClass(wrapView.classForCoder).hasSuffix("WrapperView") {
            for gesture in wrapView.gestureRecognizers! {
                if NSStringFromClass(gesture.classForCoder).contains("DelayedTouchesBegan") {
                    gesture.isEnabled = false
                    break
                }
            }
        }
    }

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: UIControl.classForCoder()) {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
