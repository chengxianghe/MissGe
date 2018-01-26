//
//  MLDiscoverController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/20.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import MJRefresh

class MLDiscoverController: UITableViewController, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet var navView: UIView!
    @IBOutlet var navContentView: UIView!
    //10
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    //10
    @IBOutlet weak var contentTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    
    var viewModel = MLDiscoverVM()
    
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
        
        self.tableView.dataSource = nil
        self.collectionView.dataSource = nil
        self.configRefresh()
        self.viewModel.tableView = tableView
        self.viewModel.collectionView = collectionView
        self.viewModel.SetConfig()
    }
    
    //MARK: - 刷新
    func configRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] () -> Void in
            self.viewModel.requestNewDataCommond.onNext(true)
            })
        
        (self.tableView.mj_header as! MJRefreshNormalHeader).huaBanHeaderConfig()
        
        self.tableView.mj_header.beginRefreshing()
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let model = self.viewModel.sectionModelObserable.value[indexPath.section].items[indexPath.row]
            let vc = segue.destination as! MLHomeSubjectController
            vc.tag_id = model.tag_id!
            vc.subjectType = .tag
        } else if segue.identifier == "DiscoverCellToSubject" {
            let indexPath = tableView.indexPath(for: sender as! MLDiscoverCell)!
            let model = self.viewModel.modelObserable.value[indexPath.row]

            let vc = segue.destination as! MLHomeSubjectController
            vc.tag_id = model.tid
            vc.subjectType = .banner
            vc.path = model.cover
        } else if segue.identifier == "DiscoverCellToSubject" {
            let indexPath = tableView.indexPath(for: sender as! MLDiscoverCell)!
            let model = self.viewModel.modelObserable.value[indexPath.row]
            
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
