//
//  MLTopicDetailController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/21.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import MJRefresh
import YYText
import XHPhotoBrowser
import ObjectMapper
import RxSwift
import RxCocoa
import Moya

protocol MLTopicDetailControllerDelegate {
    func topicCellDidClickOtherFromDetail(_ topic: MLTopicCellLayout!);
}

class MLTopicDetailController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var topic: MLTopicCellLayout!
    var delegate: MLTopicDetailControllerDelegate?
    
    fileprivate var dataSource = [MLTopicCommentCellLayout]()
    fileprivate let topicDetailRequest = MLTopicDetailRequest()
    fileprivate let commentListRequest = MLTopicCommentListRequest()
    fileprivate var currentIndex = 0
    fileprivate var tableView: UITableView!
    
    let viewModel = MLHomeViewModel()
    var bag : DisposeBag = DisposeBag()
    let provider = MoyaProvider<APIManager>(endpointClosure: kAPIManagerEndpointClosure, requestClosure: kAPIManagerRequestClosure)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.title = "评论详情"
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 64), style: UITableViewStyle.plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.separatorStyle = .none
        
        self.view.addSubview(self.tableView)
        
        self.configRefresh()
    }
    
    @IBAction func onPublishButtonPressed(_ sender: Any) {

        if !MLNetConfig.isUserLogin() {
            let goLogin = UIAlertAction.init(title: "去登录", style: UIAlertActionStyle.default, handler: {[weak self] (action) in
                guard let _self = self else {
                    return
                }
                let loginVCNav = kLoadVCFromSB(nil, stroyBoard: "Account")!
                _self.present(loginVCNav, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            self.showAlert("您还未登录", message: nil, actions: [cancel, goLogin])
            
            return
        }
        
        self.performSegue(withIdentifier: "TopicDetailToPublish", sender: nil)
        
    }

    //MARK: - 刷新
    func configRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] () -> Void in
            guard let _self = self else {
                return
            }
            if _self.tableView.mj_footer.isRefreshing {
                return
            }
            _self.loadData(1)
        })
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            guard let _self = self else {
                return
            }
            if _self.tableView.mj_header.isRefreshing {
                return
            }
            _self.loadData(_self.currentIndex + 1)
        })
        
        (self.tableView.mj_footer as! MJRefreshAutoNormalFooter).huaBanFooterConfig()
        (self.tableView.mj_header as! MJRefreshNormalHeader).huaBanHeaderConfig()
        
        self.tableView.mj_header.beginRefreshing()
    }
    
    //MARK: - 数据请求
    func loadData(_ page: Int){
        self.showLoading("正在加载...")
        
        if page == 1 {
            // 刷新详情
            topicDetailRequest.pid = "\(self.topic.joke.pid)"
            topicDetailRequest.send(success: {[weak self] (baseRequest, responseObject) in
                guard let _self = self else {
                    return
                }
                _self.tableView.mj_header.endRefreshing()
                
                let squareModel = MLSquareModel(JSON: (responseObject as! NSDictionary)["content"] as! [String:Any])
                if squareModel != nil {
                    _self.topic = MLTopicCellLayout(model: squareModel!)
                    _self.tableView.reloadSections(IndexSet.init(integer: 0), with: UITableViewRowAnimation.fade)
                }
                
            }) {[weak self] (baseRequest, error) in
                guard let _self = self else {
                    return
                }
                _self.tableView.mj_header.endRefreshing()
                print(error)
            }

        }
        
        commentListRequest.page = page
        commentListRequest.pid = "\(self.topic.joke.pid)"
        commentListRequest.send(success: {[weak self] (baseRequest, responseObject) in
            guard let _self = self else {
                return
            }
            _self.hideHud()
            _self.tableView.mj_header.endRefreshing()
            
            var modelArray: [MLTopicCommentModel]? = nil
            if let list = ((responseObject as! NSDictionary)["content"] as! NSDictionary)["repostlist"] as? [[String:Any]] {
                modelArray = list.map({ MLTopicCommentModel(JSON: $0)! })
            }
            
            let array = modelArray?.map({ (model) -> MLTopicCommentCellLayout in
                return MLTopicCommentCellLayout(model: model)
            })
            
            if array != nil && array!.count > 0 {
                if page == 1 {
                    _self.dataSource.removeAll()
                    _self.dataSource.append(contentsOf: array!)
                    _self.tableView.reloadData()
                } else {
                    _self.tableView.beginUpdates()
                    let lastItem = _self.dataSource.count
                    _self.dataSource.append(contentsOf: array!)
                    let indexPaths = (lastItem..<_self.dataSource.count).map { IndexPath(row: $0, section: 1) }
                    _self.tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.fade)
                    _self.tableView.endUpdates()
                }
                
                if array!.count < 20 {
                    _self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    _self.currentIndex = page
                    _self.tableView.mj_footer.endRefreshing()
                }
            } else {
                if page == 1 {
                    _self.dataSource.removeAll()
                    _self.tableView.reloadData()
                }
                _self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            
        }) {[weak self] (baseRequest, error) in
            guard let _self = self else {
                return
            }
            _self.tableView.mj_header.endRefreshing()
            _self.tableView.mj_footer.endRefreshing()
            
            print(error)
        }
    }
    
    
    @IBAction func onPublishBtnClick(_ sender: UIButton) {
        
//        self.presentViewController(BaseNavigationController.init(rootViewController: self.loadVCFromSB("MLPostTopicController")!), animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = (indexPath as NSIndexPath).section
        if section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "MLTopicCell") as? MLTopicCell
            if cell == nil {
                cell = MLTopicCell(style: .default, reuseIdentifier: "MLTopicCell")
                cell?.delegate = self
            }
            cell!.setInfo(self.topic);
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "MLTopicCommentCell") as? MLTopicCommentCell
            if cell == nil {
                cell = MLTopicCommentCell(style: .default, reuseIdentifier: "MLTopicCommentCell")
                cell?.delegate = self
            }
            cell!.setInfo(self.dataSource[(indexPath as NSIndexPath).row]);
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return MLTopicCell.height(self.topic)
        }
        return MLTopicCommentCell.height(self.dataSource[(indexPath as NSIndexPath).row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !MLNetConfig.isUserLogin() {
            let goLogin = UIAlertAction.init(title: "去登录", style: UIAlertActionStyle.default, handler: {[weak self] (action) in
                guard let _self = self else {
                    return
                }
                let loginVCNav = kLoadVCFromSB(nil, stroyBoard: "Account")!
                _self.present(loginVCNav, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            self.showAlert("您还未登录", message: nil, actions: [cancel, goLogin])
            
            return
        }
        if indexPath.section == 1 {
            let layout = self.dataSource[indexPath.row]
            let isSelf = MLNetConfig.isUserLogin() && MLNetConfig.shareInstance.userId == layout.joke.uid
            self.actionSheet(nil, message: nil, firstTitlt: "回复", firstHandler: {[weak self] in
                guard let _self = self else {
                    return
                }
                _self.performSegue(withIdentifier: "TopicDetailToPublish", sender: layout)
            }, destructiveTitlt: isSelf ? "删除" : "举报", destructiveHandler: {[weak self] in
                guard let _self = self else {
                    return
                }
                if isSelf {
                   _self.deleteComment(layout: layout)
                } else {
                    // 举报
                    _self.showSuccess("已举报")
                }
            }, cancelTitle: "取消", cancelHandler: nil)
        }
    }
    
    func deleteComment(layout: MLTopicCommentCellLayout) {
        // 删除
        MLRequestHelper.deleteTopicWith(layout.joke.pid, success: {[weak self] (res) in
            guard let _self = self else {
                return
            }
            _self.showSuccess("删除成功")
            let index = _self.dataSource.index(of: layout)!
            _self.dataSource.remove(at: index)
            _self.tableView.deleteRows(at: [IndexPath.init(row: index, section: 1)], with: .bottom)
            }, failure: {[weak self] (error) in
                guard let _self = self else {
                    return
                }
                _self.showError("删除失败\n\(error.localizedDescription)")
        })
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
        if segue.identifier == "TopicDetailToUser" {
            let vc = segue.destination as! MLUserController
            vc.uid = sender as! String
        } else if segue.identifier == "TopicDetailToPublish" {
            let vc = (segue.destination as! UINavigationController).topViewController as! MLPostTopicController
            vc.postType = PostTopicType.postTopicComment
            vc.dismissClosure = {[weak self] (isActionSucceed: Bool) in
                guard let _self = self else {
                    return
                }
                if isActionSucceed {
                    // 评论成功 刷新
                    _self.tableView.mj_header.beginRefreshing()
                }
            }
            if sender == nil || !(sender! as AnyObject).isKind(of: MLTopicCommentCellLayout.classForCoder()) {
                vc.tid = "\(self.topic.joke.pid)"
            } else {
                let model = (sender as! MLTopicCommentCellLayout).joke
                vc.tid = (model?.tid)!
                vc.quote = (model?.pid)!
            }
        }

     }
    
}

extension MLTopicDetailController: MLTopicCommentCellDelegate {
    func cellDidClickIcon(_ cell: MLTopicCommentCell) {
        print("cellDidClickIcon")
        self.performSegue(withIdentifier: "TopicDetailToUser", sender: cell.layout.joke.uid)
    }
    
    func cellDidClickName(_ cell: MLTopicCommentCell) {
        print("cellDidClickName")
    }
    
    func cellDidClickOther(_ cell: MLTopicCommentCell) {
        print("cellDidClickOther")
    }
    
    func cellDidClickLike(_ cell: MLTopicCommentCell) {
        print("cellDidClickLike")
    }
    
    func cell(_ cell: MLTopicCommentCell, didClickContentWithLongPress longPress: Bool) {
        print("didClickContentWithLongPress")
    }
    
    func cell(_ cell: MLTopicCommentCell, didClickTextInLabel label: YYLabel!, textRange: NSRange) {
        let text = label.textLayout!.text;
        if (textRange.location >= text.length) {return};
        
        let highlight = text.yy_attribute(YYTextHighlightAttributeName, at: UInt(textRange.location)) as! YYTextHighlight
        
        let info = highlight.userInfo;
        
        if (info?.count == 0) {return};
        
        if !MLNetConfig.isUserLogin() {
            let goLogin = UIAlertAction.init(title: "去登录", style: UIAlertActionStyle.default, handler: {[weak self] (action) in
                guard let _self = self else {
                    return
                }
                let loginVCNav = kLoadVCFromSB(nil, stroyBoard: "Account")!
                _self.present(loginVCNav, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            self.showAlert("您还未登录", message: nil, actions: [cancel, goLogin])
            
            return
        }
        
        if (info?[kSquareLinkAtName] != nil) {
            let name = info![kSquareLinkAtName] as! String;
            print("didClickTextInLabel Name: \(name)");
            //        name = [name stringByURLEncode];
            //        if (name.length) {
            //            NSString *url = [NSString stringWithFormat:@"http://m.weibo.cn/n/%@",name];
            //            YYSimpleWebViewController *vc = [[YYSimpleWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
            //            [self.navigationController pushViewController:vc animated:YES];
            //        }
            
            self.performSegue(withIdentifier: "TopicDetailToUser", sender: cell.layout.joke.quote!.uid)
            
            return;
        }

    }
    
}

extension MLTopicDetailController: MLSquareCellDelegate {
    
    func topicCellDidClickOther(_ cell: MLTopicCell) {
        if MLNetConfig.isUserLogin() && MLNetConfig.shareInstance.userId == cell.layout.joke.uid {
            // 删除
            self.alert(title: "提示", message: "确定要删除", doneTitlt: "确定", doneHandler: {
                MLRequestHelper.deleteTopicWith(cell.layout.joke.pid, success: {[weak self] (res) in
                    guard let _self = self else {
                        return
                    }
                    
                    _self.navigationController?.popViewController(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + .milliseconds(300)), execute: {
                        // Do something
                        _self.delegate?.topicCellDidClickOtherFromDetail(_self.topic)
                    })
                    
                    }, failure: {[weak self] (error) in
                        guard let _self = self else {
                            return
                        }
                        _self.showError("删除失败\n\(error.localizedDescription)")
                })
            }, cancelTitle: "取消", cancelHandler: nil)
        } else {
            // 举报
            self.alert(title: "提示", message: "确定要举报", doneTitlt: "确定", doneHandler: {[weak self] in
                self?.showSuccess("已举报")
            }, cancelTitle: "取消", cancelHandler: nil)
        }
    }
    
    func topicCellDidClickIcon(_ cell: MLTopicCell) {
        if !MLNetConfig.isUserLogin() {
            let goLogin = UIAlertAction.init(title: "去登录", style: UIAlertActionStyle.default, handler: {[weak self] (action) in
                guard let _self = self else {
                    return
                }
                let loginVCNav = kLoadVCFromSB(nil, stroyBoard: "Account")!
                _self.present(loginVCNav, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            self.showAlert("您还未登录", message: nil, actions: [cancel, goLogin])
            
            return
        }
        self.performSegue(withIdentifier: "TopicDetailToUser", sender: cell.layout.joke.uid)
    }
    
    func topicCellDidClickName(_ cell: MLTopicCell) {
        if !MLNetConfig.isUserLogin() {
            let goLogin = UIAlertAction.init(title: "去登录", style: UIAlertActionStyle.default, handler: {[weak self] (action) in
                guard let _self = self else {
                    return
                }
                let loginVCNav = kLoadVCFromSB(nil, stroyBoard: "Account")!
                _self.present(loginVCNav, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            self.showAlert("您还未登录", message: nil, actions: [cancel, goLogin])
            
            return
        }
        self.performSegue(withIdentifier: "TopicDetailToUser", sender: cell.layout.joke.uid)
    }
    
    /// 点击了评论
    func topicCellDidClickComment(_ cell: MLTopicCell) {
        print("点击了评论")
    }
    
    /// 点击了图片
    func topicCell(_ cell: MLTopicCell, didClickImageAtIndex index: UInt) {
        print("点击了图片")

        var items = [XHPhotoItem]()
        let status = cell.layout.joke;
        
        guard let imglist = status!.imglist else {
            return
        }
        
        for i in 0..<imglist.count {
            let imgView = cell.statusView.picViews![i];
            let pic = imglist[i]
            
            let item = XHPhotoItem()
            item.thumbView = imgView;
            item.largeImageURL = pic.thumb;
            //            item.largeImageURL = pic.thumb;
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
