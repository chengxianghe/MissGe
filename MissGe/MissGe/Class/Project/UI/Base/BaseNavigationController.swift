//
//  BaseNavigationController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/18.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

//IB_DESIGNABLE//声明类是可设计的， 此处测试无效，分类应该不能实现
/*
 An extension that adds a "flat" field to UINavigationBar. This flag, when
 enabled, removes the shadow under the navigation bar.
 */

class BaseNavigationController: UINavigationController {


    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.delegate = self

        // Do any additional setup after loading the view.
    }

//    override func pushViewController(viewController: UIViewController, animated: Bool) {
//        super.pushViewController(viewController, animated: animated)
//        if self.viewControllers.count > 1 {
//            self.hidesTabBar(true)
//        }
//    }
//
//    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
//        let vc = super.popViewControllerAnimated(animated)
//        if self.viewControllers.count <= 1 {
//            self.hidesTabBar(false)
//        }
//        return vc
//    }
        
    // MARK: - Status Bar
    override var childViewControllerForStatusBarStyle : UIViewController? {
        return self.topViewController
    }
    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return UIStatusBarStyle.LightContent
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
