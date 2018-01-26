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

class MLHomeSubjectController: BaseViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topImageView: UIImageView!
    
    var subjectType = SubjectType.tag
    var tag_id = ""
    var path: URL?
    
//    var dataSource = [MLHomePageModel]()
    var viewModel = MLHomeSubjectVM()
//    fileprivate var currentIndex = 0
    
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
        viewModel.tableView = tableView
        viewModel.tag_id = tag_id
        viewModel.subjectType = subjectType
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
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MLHomePageCell") as? MLHomePageCell
//        cell?.setInfo(self.viewModel.modelObserable.value[(indexPath as NSIndexPath).row]);
//        return cell!
//    }
    
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
            let model = self.viewModel.modelObserable.value[(indexPath as NSIndexPath).row]
            let vc = segue.destination as! MLHomeDetailController
            vc.aid = model.tid
        }
        
    }

}

