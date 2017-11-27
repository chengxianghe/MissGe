//
//  MLDiscoverController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/20.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import MJRefresh
import ObjectMapper

class MLDiscoverController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet var navView: UIView!
    @IBOutlet var navContentView: UIView!
    //10
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    //10
    @IBOutlet weak var contentTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    
    let discoverRequest = MLDiscoverRequest()
    let discoverTagRequest = MLDiscoverTagRequest()
    var dataSource = [MLHomePageModel]()
    var tagsArray = [MLDiscoverTagModel]()
    var requestCount = 0
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        if self.navView.superview == nil {
//            self.navigationController?.navigationBar.addSubview(self.navView)
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        let searchBar = UISearchBar.init(frame: CGRect.init(x: 10, y: 10, width: kScreenWidth - 20, height: 30))
//        searchBar.searchBarStyle = .minimal;
//        searchBar.contentInset = UIEdgeInsetsMake(10, 20, 10, 20)
        searchBar.tintColor = UIColor.white
        searchBar.placeholder = "搜索"
        searchBar.delegate = self
//        self.navView.frame = CGRect(x: 10, y: 7, width: kScreenWidth - 20, height: 30)
//        self.navigationController?.navigationBar.addSubview(self.navView)
        self.navigationItem.titleView = searchBar;
        
        
        let titleHeight = ceil((kScreenWidth - 20) / 305 * 16)
        let collectionViewLineSpace = collectionViewLayout.minimumLineSpacing
        let collectionViewItemSpace = collectionViewLayout.minimumInteritemSpacing
        let headerCellWidth: CGFloat = (kScreenWidth - 20 - 3 * collectionViewItemSpace) / 4.0
        self.tableView.tableHeaderView?.setHeight(headerCellWidth * 2 + titleHeight + 3 * collectionViewLineSpace + 30)
  
        let footerHeight = ceil((kScreenWidth - 30) / 303 * 28 + 20)
        self.tableView.tableFooterView?.setHeight(footerHeight)
        
        self.tableView.rowHeight = ceil((kScreenWidth - 20) / 300 * 140 + 20)
        
        self.collectionViewLayout.itemSize = CGSize(width: headerCellWidth, height: headerCellWidth)
                
        self.configRefresh()
    }
    
    //MARK: - 刷新
    func configRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] () -> Void in
            self.loadData(1)
            })
        
        (self.tableView.mj_header as! MJRefreshNormalHeader).huaBanHeaderConfig()
        
        self.tableView.mj_header.beginRefreshing()
    }
    
    //MARK: - 数据请求
    func loadData(_ page: Int){
        requestCount = 0
        self.showLoading("正在加载...")
        discoverTagRequest.send(success: {[unowned self] (baseRequest, responseObject) in
            
            var array: [MLDiscoverTagModel]? = nil
            if let list = ((responseObject as! NSDictionary)["content"] as! NSDictionary)["list"] as? [[String:Any]] {
                array = list.map({ MLDiscoverTagModel(JSON: $0)! })
                //modelArray = NSArray.yy_modelArray(with: MLTopicCommentModel.classForCoder(), json: list) as? [MLTopicCommentModel]
            }
            
            if array != nil && array!.count > 0 {
                self.tagsArray.removeAll()
                self.tagsArray.append(contentsOf: array!)
            }

            self.collectionView.reloadData()
            self.requestCount += 1
            self.finishedAllRequest()
            
        }) { (baseRequest, error) in
            self.tableView.mj_header.endRefreshing()
            print(error)
        }
        
        discoverRequest.send(success: {[unowned self] (baseRequest, responseObject) in
            var array: [MLHomePageModel]? = nil
            if let list = ((responseObject as! NSDictionary)["content"] as! NSDictionary)["artlist"] as? [[String:Any]] {
                array = list.map({ MLHomePageModel(JSON: $0)! })
            }
            
            if array != nil && array!.count > 0 {
                self.dataSource.removeAll()
                self.dataSource.append(contentsOf: array!)
            }
            self.requestCount += 1

            self.finishedAllRequest()

        }) { (baseRequest, error) in
            self.tableView.mj_header.endRefreshing()
            print(error)
        }
    }
    
    func finishedAllRequest() {
        if self.requestCount == 2 {
            self.hideHud()
            self.tableView.mj_header.endRefreshing()
            self.tableView.reloadData()
            self.requestCount = 0
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.tagsArray.count / 8
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MLDiscoverHeaderCell", for: indexPath) as! MLDiscoverHeaderCell
        //0  1  2  3  4  5  6  7  8  9   10 11
        //0. 4. 1. 5. 2. 6. 3. 7, 8  12  9  13
        var index = 0
        if (indexPath as NSIndexPath).row % 2 == 0 {
            index = (indexPath as NSIndexPath).row / 2 + (indexPath as NSIndexPath).section * 8
        } else {
            index = (indexPath as NSIndexPath).row + 3 - ((indexPath as NSIndexPath).row / 2) + (indexPath as NSIndexPath).section * 8
        }
                
        cell.setInfo(self.tagsArray[index])
        
        return cell
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MLDiscoverCell", for: indexPath) as! MLDiscoverCell
        
        cell.setInfo(self.dataSource[(indexPath as NSIndexPath).row].cover)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
//    @IBAction func popFromSearch(_ segue:UIStoryboardSegue) {
//        print(segue.identifier ?? "")
//        print("popFromSearch")
//        contentTrailingConstraint.constant = 50
//        contentLeadingConstraint.constant = 10
//
//        UIView.animate(withDuration: 0.01, animations: {
//            self.navView.layoutIfNeeded()
//        }) { (f) in
//            self.contentTrailingConstraint.constant = 0
//            self.contentLeadingConstraint.constant = 0
//            UIView.animate(withDuration: 0.3) {
//                self.navView.layoutIfNeeded()
//            }
//        }
//   
//    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.performSegue(withIdentifier: "SearchToSubject", sender: searchBar.text)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //DiscoverItemToSubject DiscoverCellToSubject
//        self.navView.removeFromSuperview()

        if segue.identifier == "DiscoverItemToSubject" {
            let indexPath = collectionView.indexPath(for: sender as! MLDiscoverHeaderCell)!
            let model = self.tagsArray[(indexPath as NSIndexPath).row]
            let vc = segue.destination as! MLHomeSubjectController
            vc.tag_id = model.tag_id!
            vc.subjectType = .tag

        } else if segue.identifier == "DiscoverCellToSubject" {
            let indexPath = tableView.indexPath(for: sender as! MLDiscoverCell)!
            let model = self.dataSource[(indexPath as NSIndexPath).row]

            let vc = segue.destination as! MLHomeSubjectController
            vc.tag_id = model.tid
            vc.subjectType = .banner
            vc.path = model.cover
        } else if segue.identifier == "DiscoverCellToSubject" {
            let indexPath = tableView.indexPath(for: sender as! MLDiscoverCell)!
            let model = self.dataSource[(indexPath as NSIndexPath).row]
            
            let vc = segue.destination as! MLHomeSubjectController
            vc.tag_id = model.tid
            vc.subjectType = .banner
            vc.path = model.cover
        }
        
        else if segue.identifier == "SearchToSubject" {
            let vc = segue.destination as! MLHomeSubjectController
            vc.tag_id = sender as! String
            vc.subjectType = .search
        }
        
//        else if segue.identifier == "DiscoverToSearch" {
//            let vc = segue.destination as! MLSearchController
//        }
    }

//    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue? {
//        if identifier == "popFromSearch" {
//            return XHCustomPopSegue(identifier: identifier, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
//            })
//        }
//        
//        return super.segueForUnwinding(to: toViewController, from: fromViewController, identifier: identifier)!
//    }
    
}
