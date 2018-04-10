//
//  MLFansController.swift
//  MissLi
//
//  Created by CXH on 2016/10/11.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class MLUserFansController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    
    var isFans = false
    var uid: String = ""
    
    private var dataSource = [MLUserModel]()
    private let fansRequest = MLUserFansListRequest()
    private let followersRequest = MLUserFollowListRequest()
    
    private var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - 数据请求
    func loadData(){
        self.showLoading("正在加载...")
        var request: MLBaseRequest!
        
        if isFans {
            self.fansRequest.uid = self.uid
            request = self.fansRequest
        } else {
            self.followersRequest.uid = self.uid
            request = self.followersRequest
        }
        
        request.send(success: {[unowned self] (baseRequest, responseObject) in
            self.hideHud()
            
            guard let blacklist = ((responseObject as? NSDictionary)?["content"] as? NSDictionary)?["blacklist"] as? [[String:Any]] else {
                return
            }
            
            guard let modelArray = blacklist.map({ MLUserModel(JSON: $0) }) as? [MLUserModel] else {
                return
            }
            
            self.dataSource.append(contentsOf: modelArray)
            self.tableView.reloadData()
            
        }) { (baseRequest, error) in
            print(error)
            self.showError("请求出错")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MLUserFansCell") as? MLUserFansCell
       
        let userModel = self.dataSource[indexPath.row]
        cell!.setInfo(model: userModel);
        
        cell!.onFollowButtonTapClosure = {(sender) in
            if userModel.relation == 0 {
                // 去关注
                MLRequestHelper.userFollow(self.uid, succeed: { (base, res) in
                    self.showSuccess("关注成功")
                    userModel.relation = 1
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                    }, failed: { (base, err) in
                        self.showError("网络错误")
                        print(err)
                })
            } else {
                // 取消关注
                MLRequestHelper.userFollow(self.uid, succeed: { (base, res) in
                    self.showSuccess("已取消关注")
                    userModel.relation = 0
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                    }, failed: { (base, err) in
                        self.showError("网络错误")
                        print(err)
                })
            }
        }
        
        cell!.onIconButtonTapClosure = {(sender) in
            // 进入用户详情
            //ToUserDetail
            self.performSegue(withIdentifier: "ToUserDetail", sender: userModel)
        }
        
        return cell!
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return MLTopicCell.height(model)
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ToUserDetail" {
            let vc = segue.destination as! MLUserController
            vc.uid = (sender as! MLUserModel).uid
        }
    }

}
