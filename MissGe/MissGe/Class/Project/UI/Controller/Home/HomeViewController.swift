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

class HomeViewController: BaseViewController, ScrollDrectionChangeProtocol, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // scrollprotocol
    var weakScrollView: UIScrollView! = nil
    var lastOffsetY: CGFloat = 0
    var isUp: Bool = false
    var scrollBlock: ScrollDirectionChangeBlock?
    
    var dataSource = [MLHomePageModel]()
    var bannerSource = [MLHomeBannerModel]()
    let homeRequest = HomePageRequest()
    let bannerRequest = HomePageBannerRequest()
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkAdView()
        
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
            let banner = self.bannerSource[index]
            if banner.weibo_type == 2 {
                // 跳到新的页面
                self.performSegue(withIdentifier: "BannerToSubject", sender: banner)
            } else if banner.weibo_type == 0 {
                // 进入文章详情
                self.performSegue(withIdentifier: "HomeCellToDetail", sender: banner.weibo_id)
            } else {
                print("未知类型: id:\(banner.weibo_id), type:\(banner.weibo_type)")
            }
            
        }
        
        self.tableView.tableHeaderView = scrollAdView
        
        self.configRefresh()
    }
    
    func checkAdView() {
        
        // 1.判断沙盒中是否存在广告图片，如果存在，直接显示
        let filePath = self.getFilePathWithImageName(imageName: adImageName);
        
        let isExist = FileManager.default.fileExists(atPath: filePath)
        
        if isExist {
            let advertiseView = AdvertiseView(frame: UIApplication.shared.keyWindow!.bounds)
            advertiseView.filePath = filePath
            advertiseView.setAdDismiss(nil, save: { 
               //保存图片
                PhotoAlbumHelper.saveImageToAlbum(UIImage(contentsOfFile: filePath)!, completion: { (result: PhotoAlbumHelperResult, err: NSError?) in
                    if result == .success {
                        self.showSuccess("保存成功!")
                    } else {
                        self.showError(err?.localizedDescription ?? "保存出错")
                    }
                })
            })
            advertiseView.show()
        }
        
        // 2.无论沙盒中是否存在广告图片，都需要重新调用广告接口，判断广告是否更新
        self.refreshImageUrl()
    }
    
    func refreshImageUrl() {
        let startRequest = MLAPPStartRequest()
        startRequest.send(success: { (base, res) in
            guard let url = startRequest.adModel?.path?.absoluteString else {
                return
            }
            
            let lastUrl = UserDefaults.standard.value(forKey: adUrl) as? String ?? ""
            
            if url != lastUrl {
                
                YYWebImageManager.shared().requestImage(with: startRequest.adModel!.path!, options: YYWebImageOptions.ignoreDiskCache, progress: nil, transform: nil, completion: { (image, imageUrl, from, stage, error) in
                    DispatchQueue.global().async(execute: {
                        
                        let data = image!.yy_imageDataRepresentation()
                        try? data?.write(to: URL.init(fileURLWithPath: self.getFilePathWithImageName(imageName: adImageName)))

                        UserDefaults.standard.set(url, forKey: adUrl)
                        UserDefaults.standard.synchronize()
                    })
                    
                })
            }
            
        }) { (base, err) in
            print(err)
        }
    }
    
    func getFilePathWithImageName(imageName: String) -> String {
        let filePath = kCachesPath().appending("/\(imageName)")
        return filePath;
    }
    
    //MARK: - 刷新
    func configRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] () -> Void in
            if self.tableView.mj_footer.isRefreshing() {
                return
            }
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
        
        if page == 1 {
//
            bannerRequest.send(success: {[unowned self] (baseRequest, responseObject) in

                guard let dict = responseObject as? NSDictionary else {
                    return
                }
                
                guard let content = dict["content"] as? [[String:Any]] else {
                    return
                }
                
                let array = content.map({ MLHomeBannerModel(JSON: $0) }) as! [MLHomeBannerModel]
                
                self.bannerSource.removeAll()
                self.bannerSource.append(contentsOf: array)
                
                let urls = array.flatMap({ $0.path })

                let scrollAdView = self.tableView.tableHeaderView as! GMBScrollAdView
                scrollAdView.updateImages(urls, titles: nil)
                
            }) { (baseRequest, error) in
                print(error)
            }
        }
        
        
        homeRequest.page = page
        homeRequest.send(success: {[unowned self] (baseRequest, responseObject) in
            self.tableView.mj_header.endRefreshing()

            var array: [MLHomePageModel]? = nil
            if let list = ((responseObject as! NSDictionary)["content"] as! NSDictionary)["artlist"] as? [[String:Any]] {
                array = list.map({ MLHomePageModel(JSON: $0) }) as? [MLHomePageModel]
            }
            
            
            if (array?.count)! > 0 {
                if page == 1 {
                    self.dataSource.removeAll()
                    self.dataSource.append(contentsOf: array!)
                    self.tableView.reloadData()
                } else {
                    self.tableView.beginUpdates()
                    let lastItem = self.dataSource.count
                    self.dataSource.append(contentsOf: array!)
                    let indexPaths = (lastItem..<self.dataSource.count).map { IndexPath(row: $0, section: 0) }
                    self.tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.fade)
                    self.tableView.endUpdates()
                }
                
                if array!.count < 20 {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = self.dataSource[(indexPath as NSIndexPath).row] as MLHomePageModel
        
        if model.type == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MLHomePageCell") as? MLHomePageCell
            cell?.setInfo(self.dataSource[(indexPath as NSIndexPath).row]);
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MLHomePageAlbumCell") as? MLHomePageAlbumCell
            cell?.setInfo(self.dataSource[(indexPath as NSIndexPath).row]);
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.dataSource[(indexPath as NSIndexPath).row]
        if model.type == 1 {
            self.performSegue(withIdentifier: "HomeCellToDetail", sender: model.tid)
        } else {
            self.performSegue(withIdentifier: "HomeAlbumCellToDetail", sender: model)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.dataSource[(indexPath as NSIndexPath).row] as MLHomePageModel
        if model.type != 1 {
            return MLHomePageAlbumCell.height(model)
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "HomeCellToDetail" {
            let vc = segue.destination as! MLHomeDetailController
            vc.aid = sender as! String
            
            let aids = (self.dataSource.filter({ $0.type == 1 })).map({ $0.tid })
            
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
            vc.tag_id = (sender as! MLHomeBannerModel).weibo_id
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
