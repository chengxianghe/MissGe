//
//  ScrollDrectionChangeProtocol.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/18.
//  Copyright © 2016年 cn. All rights reserved.
//

import Foundation
import UIKit

let offsetChange: CGFloat = 20
let offsetChangeBegin: CGFloat = 0

typealias ScrollDirectionChangeBlock = (_ isUp: Bool) -> Void

protocol ScrollDrectionChangeProtocol: UIScrollViewDelegate {
    var weakScrollView: UIScrollView! { get set }
    var lastOffsetY: CGFloat { get set }
    var isUp: Bool { get set }
    var scrollBlock: ScrollDirectionChangeBlock? { get set }

    func setWeakScrollView(_ scrollView: UIScrollView)
    func updateWeakScrollViewPosition()
    func setWeakScrollDirectionChangeBlock(_ scrollBlock: ScrollDirectionChangeBlock?)
}

extension ScrollDrectionChangeProtocol {

    func setWeakScrollView(_ scrollView: UIScrollView) {
        self.weakScrollView = scrollView
    }

    func updateWeakScrollViewPosition() {
        self.isUp = false
        self.lastOffsetY = self.weakScrollView.contentOffset.y
    }

    func setWeakScrollDirectionChangeBlock(_ scrollBlock: ScrollDirectionChangeBlock?) {
        self.scrollBlock = scrollBlock
    }

}
