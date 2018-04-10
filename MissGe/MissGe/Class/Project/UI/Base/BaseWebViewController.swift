//
//  BaseWebViewController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/19.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class BaseWebViewController: UIViewController {

    var url: String = ""
    var showTitle: String?
    fileprivate var webView = UIWebView()

    convenience init(url: String, title: String?) {
        self.init()
        self.url = url
        self.showTitle = title
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.showTitle
        
        self.webView.frame = self.view.bounds
        self.view.addSubview(self.webView)
        self.webView.loadRequest(URLRequest(url: URL(string: url)!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
