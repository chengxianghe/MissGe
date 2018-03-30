//
//  TUSearchBar.swift
//  MissGe
//
//  Created by chengxianghe on 2017/10/19.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation

class TUSearchBar: UISearchBar {

    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }

//    var contentInset: UIEdgeInsets? {
//        didSet {
//            self.layoutSubviews()
//        }
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        // view是searchBar中的唯一的直接子控件
//        for view in self.subviews {
//            // UISearchBarBackground与UISearchBarTextField是searchBar的简介子控件
//            for subview in view.subviews {
//
//                // 找到UISearchBarTextField
//                if subview.isKind(of: UITextField.classForCoder()) {
//
//                    if let textFieldContentInset = contentInset { // 若contentInset被赋值
//                        // 根据contentInset改变UISearchBarTextField的布局
//                        subview.frame = CGRect(x: textFieldContentInset.left, y: textFieldContentInset.top, width: self.bounds.width - textFieldContentInset.left - textFieldContentInset.right, height: self.bounds.height - textFieldContentInset.top - textFieldContentInset.bottom)
//                    } else { // 若contentSet未被赋值
//                        // 设置UISearchBar中UISearchBarTextField的默认边距
//                        let top: CGFloat = (self.bounds.height - 28.0) / 2.0
//                        let bottom: CGFloat = top
//                        let left: CGFloat = 8.0
//                        let right: CGFloat = left
//                        contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
//                    }
//                }
//            }
//        }
//    }
}
