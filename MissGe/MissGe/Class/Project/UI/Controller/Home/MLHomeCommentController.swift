//
//  MLHomeCommentController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/23.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import MJRefresh
import YYText
import ObjectMapper

class MLHomeCommentController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var aid = ""
    var dataSource = [MLTopicCommentCellLayout]()
    let commentListRequest = MLHomeCommentListRequest()
    var currentIndex = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white

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
        commentListRequest.page = page
        commentListRequest.aid = aid
        commentListRequest.send(success: {[unowned self] (baseRequest, responseObject) in
            self.hideHud()
            self.tableView.mj_header.endRefreshing()
            
            var modelArray: [MLTopicCommentModel]? = nil
            if let list = ((responseObject as! NSDictionary)["content"] as! NSDictionary)["comlist"] as? [[String:Any]] {
                modelArray = list.map({ MLTopicCommentModel(JSON: $0)! })
                //modelArray = NSArray.yy_modelArray(with: MLTopicCommentModel.classForCoder(), json: list) as? [MLTopicCommentModel]
            }
            
            let array = modelArray?.map({ (model) -> MLTopicCommentCellLayout in
                return MLTopicCommentCellLayout(model: model)
            })
            
            if array != nil && array!.count > 0 {
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
    
    @IBAction func onCommentBtnClick(_ sender: UIButton) {
        if !MLNetConfig.isUserLogin() {            
            let goLogin = UIAlertAction.init(title: "去登录", style: UIAlertActionStyle.default, handler: {[weak self] (action) in
                let loginVCNav = kLoadVCFromSB(nil, stroyBoard: "Account")!
                self?.present(loginVCNav, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            self.showAlert("您还未登录", message: nil, actions: [cancel, goLogin])
            
            return
        }
        
        self.performSegue(withIdentifier: "HomeCommentToPublish", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MLTopicCommentCell") as? MLTopicCommentCell
        if cell == nil {
            cell = MLTopicCommentCell(style: .default, reuseIdentifier: "MLTopicCommentCell")
            cell?.delegate = self
        }
        cell!.setInfo(self.dataSource[(indexPath as NSIndexPath).row]);
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !MLNetConfig.isUserLogin() {
            let goLogin = UIAlertAction.init(title: "去登录", style: UIAlertActionStyle.default, handler: {[weak self] (action) in
                let loginVCNav = kLoadVCFromSB(nil, stroyBoard: "Account")!
                self?.present(loginVCNav, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            self.showAlert("您还未登录", message: nil, actions: [cancel, goLogin])
            
            return
        }
        
        self.performSegue(withIdentifier: "HomeCommentToPublish", sender: self.dataSource[(indexPath as NSIndexPath).row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.dataSource[(indexPath as NSIndexPath).row]
        return MLTopicCommentCell.height(model)
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
        if segue.identifier == "HomeCommentToPublish" {
            let vc = (segue.destination as! UINavigationController).topViewController as! MLPostTopicController
            vc.postType = PostTopicType.articleComment
            vc.aid = aid
            vc.dismissClosure = {(isSucceed) in
                print("HomeCommentToPublish \(isSucceed)");
            }
            
            if sender != nil {
                let model = (sender as! MLTopicCommentCellLayout).joke
                vc.cid = (model?.cid)!
            }
        } else if segue.identifier == "CommentToUser" {
            let vc = segue.destination as! MLUserController
            vc.uid = (sender as! MLTopicCommentCellLayout).joke.uid
        }

    }

}

extension MLHomeCommentController: MLTopicCommentCellDelegate {
    func cellDidClickIcon(_ cell: MLTopicCommentCell) {
        self.performSegue(withIdentifier: "CommentToUser", sender: cell.layout)
    }
    
    func cellDidClickName(_ cell: MLTopicCommentCell) {
        self.performSegue(withIdentifier: "CommentToUser", sender: cell.layout)
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
        
        if (info?[kSquareLinkAtName] != nil) {
            let name = info![kSquareLinkAtName];
            print("didClickTextInLabel Name: \(String(describing: name))");
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

