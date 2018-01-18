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

class MLDiscoverMoreController: BaseViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
//    let discoverRequest = MLDiscoverMoreRequest()
//    var dataSource = [MLHomePageModel]()
//    fileprivate var currentIndex = 0
    var viewModel = MLDiscoverMoreVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = ceil((kScreenWidth - 20) / 300 * 140 + 20)
        
        self.configRefresh()
        viewModel.tableView = tableView
        viewModel.SetConfig()
    }
    
    //MARK: - 刷新
    func configRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] () -> Void in
            self.viewModel.requestNewDataCommond.onNext(true)
            })
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[unowned self] () -> Void in
            if self.tableView.mj_header.isRefreshing {
                return
            }
            self.viewModel.requestNewDataCommond.onNext(false)
            })
        
        (self.tableView.mj_footer as! MJRefreshAutoNormalFooter).huaBanFooterConfig()
        (self.tableView.mj_header as! MJRefreshNormalHeader).huaBanHeaderConfig()
        
        self.tableView.mj_header.beginRefreshing()
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.modelObserable.value.count
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MLDiscoverCell", for: indexPath) as! MLDiscoverCell
//        
//        cell.setInfo(self.viewModel.modelObserable.value[(indexPath as NSIndexPath).row].cover)
//        
//        return cell
//    }
    
    
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
            let model = self.viewModel.modelObserable.value[(indexPath as NSIndexPath).row]
            
            let vc = segue.destination as! MLHomeSubjectController
            vc.tag_id = model.tid
            vc.subjectType = SubjectType.banner
        }
    }

}
