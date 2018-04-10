//
//  UIViewBlurExt.swift
//  JokeMusic
//
//  Created by chengxianghe on 15/10/28.
//  Copyright © 2015年 CXH. All rights reserved.
//

/*
let blur = FXBlurView()
blur.dynamic = false
blur.frame = self.bounds
blur.blurRadius = 30
blur.tintColor = UIColor(white: 0, alpha: CGFloat(style.rawValue)*0.33)
self.addSubview(blur)

*/

import UIKit
import Foundation

@available(iOS 8.0, *)
extension UIView   {
    
    func addBlur(_ style: UIBlurEffectStyle = .light) {
        
        self.removeBlur()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle(rawValue: style.rawValue)!)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        blurView.tintColor = UIColor.black
        self.addSubview(blurView)
        
        self.setNeedsDisplay();
        self.layoutIfNeeded()
        
    }
    
    func removeBlur() {
        for view in self.subviews {
            if view.isKind(of: UIVisualEffectView.classForCoder()) {
                view.removeFromSuperview()
            }
        }
    }
    
    
    
}

@available(iOS 8.0, *)
@IBDesignable
class BlurView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    var blurEffect = UIBlurEffectStyle.extraLight
    
    /**
     @IBInspectable目前支持 NSNumber 及 CGPoint、CGSize、CGRect、UIColor 和 NSRange，额外增加了 UIImage。
     */
    @IBInspectable var blurStyle: Int = 0 {
        didSet {
            switch self.blurStyle {
            case 0: blurEffect = .dark
            case 1: blurEffect = .extraLight
            default: blurEffect = .light
            }
            self.addBlur(blurEffect)
            
        }
    }
    
}
