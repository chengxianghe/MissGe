//
//  MLUserController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/23.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import MJRefresh
import YYText
import XHPhotoBrowser
import ObjectMapper

class MLUserController: UITableViewController {

    @IBOutlet weak var bestAnswerLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followNumButton: UIButton!
    @IBOutlet weak var fansNumButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userEditButton: UIButton!
    
    var uid = ""
    
    fileprivate var dataSource = [MLTopicCellLayout]()
    fileprivate let infoRequest = MLUserInfoRequest()
    fileprivate let followRequest = MLUserFollowRequest()
    fileprivate let topicListRequest = MLUserTopicListRequest()
    fileprivate var currentIndex = 0
    fileprivate var isNeedEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if uid == MLNetConfig.shareInstance.userId {
            self.userEditButton.isHidden = false
            self.followButton.isHidden = true
        } else {
            self.userEditButton.isHidden = true
            self.followButton.isHidden = false
        }

        
        self.configRefresh()
    }
    
    //MARK: - 刷新
    func configRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] () -> Void in
            if self.tableView.mj_footer.isRefreshing {
                return
            }
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
        
        if page == 1 {
            infoRequest.uid = self.uid
            infoRequest.send(success: {[unowned self] (baseRequest, responseObject) in
                self.tableView.mj_header.endRefreshing()
                let user = MLUserModel(JSON: (((responseObject as! [String:Any])["content"])as! [String:Any])["userinfo"] as! [String:Any])!
                
//                let user = MLUserModel(JSON: ((responseObject as! NSDictionary)["content"] as! NSDictionary)["userinfo"]!) as MLUserModel
                print(user)
                self.bestAnswerLabel.text = "最佳答案\(user.p_bests)个"
                self.nameLabel.text = user.nickname
                self.followNumButton.setTitle("关注\(user.follow_cnt)", for: UIControlState())
                self.fansNumButton.setTitle("粉丝\(user.fans_cnt)", for: UIControlState())
                self.descLabel.text = "简介: \(user.autograph ?? "")"
                self.followButton.isSelected = user.relation != 0
                self.iconImageView.yy_setImage(with: user.avatar, placeholder: nil)

                self.tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 240 + self.descLabel.text!.height(UIFont.systemFont(ofSize: 17.0), maxWidth: kScreenWidth - 20))
                if user.uid == MLNetConfig.shareInstance.userId {
                    MLNetConfig.updateUser(user)
                }
            }) { (baseRequest, error) in
                print(error)
            }
        }
        topicListRequest.page = page
        topicListRequest.uid = self.uid
        topicListRequest.send(success: {[unowned self] (baseRequest, responseObject) in
            self.hideHud()
            self.tableView.mj_header.endRefreshing()
            
            guard let artlist = (((responseObject as? NSDictionary)?["content"] as? NSDictionary)?["artlist"]) as? [[String:Any]] else {
                return
            }
            
            let tempArr = artlist.map({ MLSquareModel(JSON: $0) })
            
            guard let modelArray = tempArr as? [MLSquareModel] else {
                return
            }
            
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
    
    // MARK: - Action
    
    @IBAction func onFollowBtnClick(_ sender: UIButton) {
        
        if !MLNetConfig.isUserLogin() {
            let goLogin = UIAlertAction.init(title: "去登录", style: UIAlertActionStyle.default, handler: {[weak self] (action) in
                let loginVCNav = kLoadVCFromSB(nil, stroyBoard: "Account")!
                self?.present(loginVCNav, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            self.showAlert("您还未登录", message: nil, actions: [cancel, goLogin])
            
            return
        }
        
        if !sender.isSelected {
            // 去关注
            MLRequestHelper.userFollow(self.uid, succeed: { (base, res) in
                self.showSuccess("关注成功")
                sender.isSelected = true
                }, failed: { (base, err) in
                    self.showError("网络错误")
                    print(err)
            })
        } else {
            // 取消关注
            MLRequestHelper.userFollow(self.uid, succeed: { (base, res) in
                self.showSuccess("已取消关注")
                sender.isSelected = false
                }, failed: { (base, err) in
                    self.showError("网络错误")
                    print(err)
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MLTopicCell") as? MLTopicCell
        if cell == nil {
            cell = MLTopicCell(style: .default, reuseIdentifier: "MLTopicCell")
            cell?.delegate = self
        }
        cell!.setInfo(self.dataSource[(indexPath as NSIndexPath).row]);
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.dataSource[(indexPath as NSIndexPath).row]
        return MLTopicCell.height(model)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "闺蜜圈"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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
        if segue.identifier == "UserToTopicDetail" {
            let vc = segue.destination as! MLTopicDetailController
            vc.topic = sender as! MLTopicCellLayout
        } else if segue.identifier == "UserToUserModify" {
            let vc = segue.destination as! MLUserController
            vc.uid = (sender as! MLTopicCellLayout).joke.uid
        } else if segue.identifier == "UserToEdit" {
//            let vc = segue.destinationViewController as! MLUserEditController
//            vc.uid = (sender as! MLTopicCellLayout).joke.uid
        } else if segue.identifier == "UserToFans" {
            let vc = segue.destination as! MLUserFansController
            vc.uid = self.uid
            vc.isFans = true
        } else if segue.identifier == "UserToFollowers" {
            let vc = segue.destination as! MLUserFansController
            vc.uid = self.uid
            vc.isFans = false
        }
    }

}

extension MLUserController: MLSquareCellDelegate {
    
    func topicCellDidClickOther(_ cell: MLTopicCell) {
        if MLNetConfig.isUserLogin() && MLNetConfig.shareInstance.userId == cell.layout.joke.uid {
            // 删除
            MLRequestHelper.deleteTopicWith(cell.layout.joke.pid, success: {[weak self] (res) in
                guard let _self = self else {
                    return
                }
                _self.showSuccess("已删除")
                let index = _self.dataSource.index(of: cell.layout)!
                _self.dataSource.remove(at: index)
                _self.tableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .automatic)
                }, failure: {[weak self] (error) in
                    guard let _self = self else {
                        return
                    }
                    _self.showError("删除失败\n\(error.localizedDescription)")
            })
        } else {
            // 举报
            self.showSuccess("已举报")
        }
    }
    
    /// 点击了评论
    func topicCellDidClickComment(_ cell: MLTopicCell) {
        self.performSegue(withIdentifier: "UserToTopicDetail", sender: cell.layout)
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
            let name = info![kSquareLinkAtName] as! String
            print("kJokeLinkAtName: \(name)");
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

