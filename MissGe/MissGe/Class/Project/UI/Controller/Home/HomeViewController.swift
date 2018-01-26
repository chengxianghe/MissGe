//
//  HomeViewController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/18.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import MJRefresh
import XHPhotoBrowser
import RxSwift
import RxCocoa
import Moya

class HomeViewController: BaseViewController, ScrollDrectionChangeProtocol, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // scrollprotocol
    var weakScrollView: UIScrollView! = nil
    var lastOffsetY: CGFloat = 0
    var isUp: Bool = false
    var scrollBlock: ScrollDirectionChangeBlock?
    let viewModel = MLHomeViewModel()
    var bag : DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.checkAdView()
        
        print("login:\(MLNetConfig.isUserLogin())")
        
        self.setWeakScrollView(self.tableView)
        
        self.setWeakScrollDirectionChangeBlock { (isUp) in
            if isUp {
                print("isUp")
            } else {
                print("isDown")
            }
        }
        
        let scrollAdView = GMBScrollAdView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kisIPad() ? 300 : 200), images: nil, autoPlay: true, delay: 3.0) { (index) in
            let banner = self.viewModel.bannerModelObserable.value[index]
            if banner.weibo_type == 2 {
                // 跳到新的页面
                self.performSegue(withIdentifier: "BannerToSubject", sender: banner)
            } else if banner.weibo_type == 0 {
                // 进入文章详情
                self.performSegue(withIdentifier: "HomeCellToDetail", sender: banner.weibo_id)
            } else {
                print("未知类型: id:\(String(describing: banner.weibo_id)), type:\(String(describing: banner.weibo_type))")
            }
            
        }
        self.tableView.delegate = self;
        self.tableView.dataSource = nil
        self.tableView.tableHeaderView = scrollAdView
        
        self.configRefresh()
        viewModel.tableView = tableView
        viewModel.scrollAdView = scrollAdView
        viewModel.SetConfig()

//        tableView.rx
//            .itemSelected
//            .subscribe(onNext: {
//                (index : IndexPath) in
//                print("\(index.row)")
//            })
//            .disposed(by: bag)
//
//        tableView.rx
//            .modelSelected(MLHomePageModel.self)
//            .subscribe(
//                onNext:{
//                    value in
//                    print(value.title)
//            })
//            .disposed(by: bag)
    }
    

    
    //MARK: - 刷新
    func configRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] () -> Void in
            if self.tableView.mj_footer.isRefreshing {
                return
            }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let model = self.dataSource[(indexPath as NSIndexPath).row]
        let model = self.viewModel.modelObserable.value[indexPath.row]
        if model.type == 5 {
            self.performSegue(withIdentifier: "HomeAlbumCellToDetail", sender: model)
        } else {
            self.performSegue(withIdentifier: "HomeCellToDetail", sender: model.tid)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let model = self.dataSource[(indexPath as NSIndexPath).row] as MLHomePageModel
        let model = self.viewModel.modelObserable.value[indexPath.row]

        if model.type == 5 {
            return MLHomePageAlbumCell.height(model)
        }
        return 100
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataSource.count
//    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "HomeCellToDetail" {
            let vc = segue.destination as! MLHomeDetailController
            vc.aid = sender as! String
            
            let aids = (self.viewModel.modelObserable.value.filter({ $0.type == 1 })).map({ $0.tid })
            
            vc.nextClosure = { (aid: String!) -> String? in
                if let index = aids.index(of: aid) {
                    if index < aids.count - 1 {
                        return aids[index + 1]
                    }
                }
                
                return nil
            }
        } else if segue.identifier == "HomeAlbumCellToDetail" {
            let vc = segue.destination as! XHPhotoBrowserController
            let models = (sender as! MLHomePageModel).album!
            var groupItems = [XHPhotoItem]()
            let title = (sender as! MLHomePageModel).title
            for model in models {
                let item = XHPhotoItem()
                item.caption = title
                item.largeImageURL = model.url
                groupItems.append(item)
            }
            
            vc.groupItems = groupItems
//            vc.title = 
            vc.rightImage = UIImage(named: "atlas_review_btn_sel_30x30_")
            vc.moreBlock = {[aid = (sender as! MLHomePageModel).tid, _self = self] in
                let commentVC = kLoadVCFromSB("MLHomeCommentController", stroyBoard: "HomeComment") as! MLHomeCommentController
                commentVC.aid = aid
                _self.navigationController?.pushViewController(commentVC, animated: true)
            }
        } else if segue.identifier == "BannerToSubject" {
            let vc = segue.destination as! MLHomeSubjectController
            vc.tag_id = (sender as! MLHomeBannerModel).weibo_id!
            vc.path = (sender as! MLHomeBannerModel).path
            vc.subjectType = .banner
        }
     }
 
}

extension HomeViewController {
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //    if (!_fpsLabel) { return; }
        
        let offsetY = scrollView.contentOffset.y;
        
        //|| _fpsLabel.alpha == 0
        if (weakScrollView != scrollView || offsetY < offsetChangeBegin || scrollView.contentSize.height - offsetY - UIScreen.main.bounds.height < 0) {
            return;
        }
        
        if (lastOffsetY - offsetY > offsetChange) { // 上移
            if (self.isUp == true) {
                self.isUp = false;
                self.scrollBlock?(self.isUp);
            }
        }
        if (offsetY - lastOffsetY > offsetChange) {
            if (self.isUp == false) {
                self.isUp = true;
                self.scrollBlock?(self.isUp);
            }
        }
        
        lastOffsetY = offsetY;
    }
    
}
