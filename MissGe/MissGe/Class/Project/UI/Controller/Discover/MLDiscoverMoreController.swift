//
//  MLDiscoverMoreController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/23.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import MJRefresh
import ObjectMapper

class MLDiscoverMoreController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let discoverRequest = MLDiscoverMoreRequest()
    var dataSource = [MLHomePageModel]()
    fileprivate var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = ceil((kScreenWidth - 20) / 300 * 140 + 20)
        
        self.configRefresh()
    }
    
    //MARK: - 刷新
    func configRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] () -> Void in
            self.loadData(1)
            })
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[unowned self] () -> Void in
            if self.tableView.mj_header.isRefreshing() {
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
        discoverRequest.page = page
        discoverRequest.send(success: {[unowned self] (baseRequest, responseObject) in

            self.hideHud()
            self.tableView.mj_header.endRefreshing()
            
            let result = (responseObject as! NSDictionary)["content"] as! NSDictionary
            
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MLDiscoverCell", for: indexPath) as! MLDiscoverCell
        
        cell.setInfo(self.dataSource[(indexPath as NSIndexPath).row].cover)
        
        return cell
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

        if segue.identifier == "DiscoverMoreToSubject" {
            let indexPath = tableView.indexPath(for: sender as! MLDiscoverCell)!
            let model = self.dataSource[(indexPath as NSIndexPath).row]
            
            let vc = segue.destination as! MLHomeSubjectController
            vc.tag_id = model.tid
            vc.subjectType = SubjectType.banner
        }
    }

}
