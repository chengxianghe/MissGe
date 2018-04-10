//
//  XHCustomPushSegue.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/25.
//  Copyright © 2017年 cn. All rights reserved.
//

import UIKit

class XHCustomPushSegue: UIStoryboardSegue {
    override func perform() {
        self.source.navigationController?.pushViewController(self.destination, animated: false)
//        let firstVCView: UIView! = self.source.view
//        let secondVCView: UIView! = self.destination.view
//        
//        let screenWidth = UIScreen.main.bounds.size.width
//        let screenHeight = UIScreen.main.bounds.size.height
//        
//        secondVCView.frame = CGRect(x: 0.0, y: screenHeight, width: screenWidth, height: screenHeight)
//        let window = UIApplication.shared.keyWindow
//        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
////
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
//            secondVCView.frame = secondVCView.frame.offsetBy(dx: 0.0, dy: -screenHeight)
//        }) { (finished: Bool) -> Void in
//            self.source.present(self.destination, animated: false, completion: nil)
//        }
    }
}

class XHCustomPopSegue: UIStoryboardSegue {
    override func perform() {
        let firstVCView: UIView! = self.source.view
        let secondVCView: UIView! = self.destination.view

        let screenHeight = UIScreen.main.bounds.size.height

        let window = UIApplication.shared.keyWindow
        window?.addSubview(secondVCView)
        window?.addSubview(firstVCView)
        secondVCView.frame = firstVCView.frame

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            firstVCView.frame = firstVCView.frame.offsetBy(dx: 0.0, dy: screenHeight)
        }) { (finished: Bool) -> Void in
            self.source.dismiss(animated: false, completion: nil)
        }
    }
}
