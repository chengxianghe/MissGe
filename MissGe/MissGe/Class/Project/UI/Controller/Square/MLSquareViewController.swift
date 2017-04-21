//
//  MLTopicViewController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/20.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import MJRefresh
import YYText
import XHPhotoBrowser

class MLSquareViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var dataSource = [MLTopicCellLayout]()
    let squareRequest = MLSquareRequest()
    var currentIndex = 0
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 64 - 49), style: UITableViewStyle.plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.view.addSubview(self.tableView)
        
        self.configRefresh()
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
        self.showLoading("正在加载...")
        squareRequest.page = page
        squareRequest.send(success: {[unowned self] (baseRequest, responseObject) in
            self.showSuccess("加载完成")
            self.tableView.mj_header.endRefreshing()

            guard let artlist = ((responseObject as! NSDictionary)["content"] as! NSDictionary)["artlist"]! as? [[String:Any]] else {
                return
            }
            
            let modelArray = artlist.map({ MLSquareModel(JSON: $0) }) as! [MLSquareModel];
 
            let array = modelArray.map({ (model) -> MLTopicCellLayout in
                return MLTopicCellLayout(model: model)
            })
            
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

    @IBAction func onPublishBtnClick(_ sender: UIButton) {
        if MLNetConfig.isUserLogin() {
            self.performSegue(withIdentifier: "SquareToPublish", sender: nil)
        } else {
            if !MLNetConfig.isUserLogin() {
                let goLogin = UIAlertAction.init(title: "去登录", style: UIAlertActionStyle.default, handler: {[weak self] (action) in
                    let loginVCNav = kLoadVCFromSB(nil, stroyBoard: "Account")!
                    self?.present(loginVCNav, animated: true, completion: nil)
                })
                
                let cancel = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
                self.showAlert("您还未登录", message: nil, actions: [cancel, goLogin])
                
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MLTopicCell") as? MLTopicCell
        if cell == nil {
            cell = MLTopicCell(style: .default, reuseIdentifier: "MLTopicCell")
            cell?.delegate = self
        }
        cell!.setInfo(self.dataSource[(indexPath as NSIndexPath).row]);
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.dataSource[(indexPath as NSIndexPath).row]
        return MLTopicCell.height(model)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
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
        
        if segue.identifier == "TopicToDetail" {
            let vc = segue.destination as! MLTopicDetailController
            vc.topic = sender as! MLTopicCellLayout
        } else if segue.identifier == "TopicToUser" {
            let vc = segue.destination as! MLUserController
            vc.uid = "\((sender as! MLTopicCellLayout).joke.uid)"
        } else if segue.identifier == "SquareToPublish" {
            let vc = (segue.destination as! UINavigationController).topViewController as! MLPostTopicController
            vc.postType = PostTopicType.postTopic
            vc.dismissClosure = {(isSucceed) in
                print("SquareToPublish \(isSucceed)");
            }
        }

    }

}

extension MLSquareViewController: MLSquareCellDelegate {

    func topicCellDidClickShare(_ cell: MLTopicCell) {
        
        let model = cell.layout.joke

        ShareManager.manager().showShareViewWithBlock({[weak cell] (type) -> () in
            guard let _cell = cell else {
                return
            }
   
            let title = model?.content ?? "";
            let describ = model?.content ?? "";
            
            var image: UIImage? = nil
            if (_cell.statusView.picViews?.count)! > 0 {
                image = _cell.statusView.picViews![0].image
            }
            
            
            var result = false
            
            switch (type) {
            case .weiBoShare:
                print("分享到新浪微博");
                result = SinaShareHelp.currentHelp().shareText(title, shareImage: image, url: "")
            case .weiXinFriendsShare:
                print("分享到朋友圈");
                //    weixin
                if image != nil {
                    result = WeiXinShareHelp.currentHelp().sendImageData(image, InScene: WXSceneTimeline)
                } else {
                    result = WeiXinShareHelp.currentHelp().sendText(describ, InScene: WXSceneTimeline)
                }
            case .weiXinShare:
                print("分享到微信好友");
                if image != nil {
                    result = WeiXinShareHelp.currentHelp().sendImageData(image, InScene: WXSceneSession)
                } else {
                   result = WeiXinShareHelp.currentHelp().sendText(describ, InScene: WXSceneSession)
                }
            case .weiXinFavoriteShare:
                print("分享到微信收藏");
                if image != nil {
                    result = WeiXinShareHelp.currentHelp().sendImageData(image, InScene: WXSceneFavorite)
                } else {
                   result = WeiXinShareHelp.currentHelp().sendText(describ, InScene: WXSceneFavorite)
                }
            case .qZoneShare:
                print("分享到QQ空间");
                result = QQShareHelp.currentHelp().sendLinkUrlToQZone(title, description: describ, imageUrl: "", url: "www.baidu.com")
            case .qqShare:
                print("分享到QQ");
                result = QQShareHelp.currentHelp().sendImage(image, title: title, desc: describ)
            }
            
            print(result)
        })
    }
    
    func topicCellDidClickIcon(_ cell: MLTopicCell) {
        self.performSegue(withIdentifier: "TopicToUser", sender: cell.layout)
    }
    
    func topicCellDidClickName(_ cell: MLTopicCell) {
        self.performSegue(withIdentifier: "TopicToUser", sender: cell.layout)
    }
    
    /// 点击了评论
    func topicCellDidClickComment(_ cell: MLTopicCell) {
        self.performSegue(withIdentifier: "TopicToDetail", sender: cell.layout)
    }
        
    /// 点击了图片
    func topicCell(_ cell: MLTopicCell, didClickImageAtIndex index: UInt) {
        print("点击了图片")

        var items = [XHPhotoItem]()
        let status = cell.layout.joke;
        
        guard let thumb = status?.thumb else {
            return
        }
        
        for i in 0..<thumb.count {
            let imgView = cell.statusView.picViews![i];
            let pic = thumb[i];

            let item = XHPhotoItem()
            item.thumbView = imgView;
            item.largeImageURL = URL(string: pic);
//            item.largeImageSize = CGSizeMake(layout.iconWidth, layout.iconHeight);
            items.append(item)
        }
    
        let v = XHPhotoBrowser.init(groupItems: items)
        v.fromItemIndex = Int(index)
        v.toolBarShowStyle = .show
        v.showCloseButton = false
        v.show(inContaioner: self.tabBarController!.view, animated: true, completion: nil)
    }
    
    /// 点击了 Label 的链接
    func topicCell(_ cell: MLTopicCell, didClickInLabel label: YYLabel!, textRange: NSRange) {
        
        let text = label.textLayout!.text;
        if (textRange.location >= text.length) {return};
        
        let highlight = text.yy_attribute(YYTextHighlightAttributeName, at: UInt(textRange.location)) as! YYTextHighlight
        
        let info = highlight.userInfo;
        
        if (info?.count == 0) {return};
        
        if (info?[kSquareLinkAtName] != nil) {
            let name = info![kSquareLinkAtName];
            print("kJokeLinkAtName: \(String(describing: name))");
            //        name = [name stringByURLEncode];
            //        if (name.length) {
            //            NSString *url = [NSString stringWithFormat:@"http://m.weibo.cn/n/%@",name];
            //            YYSimpleWebViewController *vc = [[YYSimpleWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
            //            [self.navigationController pushViewController:vc animated:YES];
            //        }
            return;
        }
    }
}
