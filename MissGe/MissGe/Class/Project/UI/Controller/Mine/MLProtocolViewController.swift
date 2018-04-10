//
//  MLProtocolViewController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/27.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class MLProtocolViewController: BaseViewController {

    var textView: UITextView!
//    fileprivate lazy var argument: String = {
//        let path = Bundle.main.path(forResource: "Agreement", ofType: "txt")
//        let string = try? String(contentsOfFile: path!)
//        return string!
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView = UITextView(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 64))
        self.textView.font = UIFont.systemFont(ofSize: 14.0)
        self.view.addSubview(self.textView)
        self.textView.text = try! String(contentsOfFile: Bundle.main.path(forResource: "Agreement", ofType: "txt")!)
    }

    @IBAction func onAgree(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
