//
//  MLHomeSubjectController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/23.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import MJRefresh
import ObjectMapper

enum SubjectType {
    case tag, banner, search, favorite
}

class MLHomeSubjectController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topImageView: UIImageView!
    
    var subjectType = SubjectType.tag
    var tag_id = ""
    var path: URL?
    let subjectRequest = MLDiscoverDetailRequest()

    var dataSource = [MLHomePageModel]()
    fileprivate var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.tableView.rowHeight = 100
        
//        if self.subjectType == .search {
//            var vcs = self.navigationController!.viewControllers
////            for i in 0..<vcs.count {
////                if vcs[i].isKind(of: MLSearchController.classForCoder()) {
////                    vcs.remove(at: i);
////                    break;
////                }
////            }
//
//            self.navigationController?.viewControllers = vcs
//        }

        if self.path != nil {
            self.topImageView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 200)
            self.topImageView.yy_setImage(with: self.path!, placeholder: UIImage(named: "banner_default_320x170_"))
            self.tableView.tableHeaderView = self.topImageView;
        } else {
            self.tableView.tableHeaderView = nil;
        }
        
        self.configRefresh()
    }
    
    //MARK: - 刷新
    func configRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] () -> Void in
            self.loadData(1)
            })
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[unowned self] () -> Void in
            if self.tableView.mj_header.isRefreshing {
                return
            }
            self.loadData(self.currentIndex + 1)
            })
        
        (self.tableView.mj_footer as! MJRefreshAutoNormalFooter).huaBanFooterConfig()
        (self.tableView.mj_header as! MJRefreshNormalHeader).huaBanHeaderConfig()
        
        self.tableView.mj_header.beginRefreshing()
    }
    
    //MARK: - 数据请求
    func loadData(_ page: Int){
        
        self.showLoading("正在加载...")
        subjectRequest.page = page
        subjectRequest.tag_id = tag_id
        subjectRequest.subjectType = subjectType
        subjectRequest.send(success: {[unowned self] (baseRequest, responseObject) in
            
            self.hideHud()
            self.tableView.mj_header.endRefreshing()
            
            let result = (responseObject as! NSDictionary)["content"] as! NSDictionary
            
            if result["artlist"] == nil {
                return
            }
            guard let artlist = result["artlist"] as? [[String:Any]] else {
                return
            }
            
            let array = artlist.map({ MLHomePageModel(JSON: $0) }) as! [MLHomePageModel];
            
            if array.count > 0 {
                if page == 1 {
                    self.dataSource.removeAll()
                    self.dataSource.append(contentsOf: array )
                    self.tableView.reloadData()
                } else {
                    self.tableView.beginUpdates()
                    let lastItem = self.dataSource.count
                    self.dataSource.append(contentsOf: array)
                    let indexPaths = (lastItem..<self.dataSource.count).map { IndexPath(row: $0, section: 0) }
                    self.tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.fade)
                    self.tableView.endUpdates()
                }
                
                if array.count < 20 {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.currentIndex = page
                    self.tableView.mj_footer.endRefreshing()
                }
            } else {
                if page == 1 {
                    self.dataSource.removeAll()
                    self.tableView.reloadData()
                }
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            
        }) { (baseRequest, error) in
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            print(error)
        }
        
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MLHomePageCell") as? MLHomePageCell
        cell?.setInfo(self.dataSource[(indexPath as NSIndexPath).row]);
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "SubjectToDetail" {
            let indexPath = tableView.indexPath(for: sender as! MLHomePageCell)!
            let model = self.dataSource[(indexPath as NSIndexPath).row]
            let vc = segue.destination as! MLHomeDetailController
            vc.aid = model.tid
        }
        
    }

}

