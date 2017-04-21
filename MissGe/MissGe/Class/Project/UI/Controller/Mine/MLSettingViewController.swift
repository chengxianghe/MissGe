//
//  MLSettingViewController.swift
//  MissLi
//
//  Created by CXH on 2016/10/11.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import YYWebImage

class MLSettingViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath)
        
        let row = indexPath.row
        
        switch row {
        case 0: // 清除缓存
            YYImageCache.shared().diskCache.removeAllObjects(progressBlock: { (removedCount, totalCount) in
                if totalCount > 0 {
                    let progress = CGFloat(removedCount) / CGFloat(totalCount)
                    self.showLoading("正在清除\(progress * 100)%")
                }
                }, end: { (isError) in
                    if isError {
                        self.showError("清除出错")
                    } else {
                        self.showSuccess("清除成功")
                    }
            })
        case 2: // 分享APP
            kJumpToAppStoreDetail(appid: kAppId)
//        case 4: // 关于我们
            
        default:
            break
        }
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
