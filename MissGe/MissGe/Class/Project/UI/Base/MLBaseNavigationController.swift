//
//  MLBaseNavigationController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/24.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class MLBaseNavigationController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        // Do any additional setup after loading the view.
    }

    // MARK: - Status Bar
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count == 1 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        if navigationController.viewControllers.count > 1 {
//            viewController.hidesBottomBarWhenPushed = true
////            self.hidesTabBar(true)
//        }
//    }
//    
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        if navigationController.viewControllers.count <= 1 {
//            self.hidesTabBar(false)
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
