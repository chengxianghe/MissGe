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

class MLHomeCommentController: BaseViewController, UITableViewDelegate {

    var aid = ""
    let viewModel = MLHomeCommentVM()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        self.configRefresh()
        viewModel.tableView = tableView
        viewModel.vc = self
        viewModel.aid = aid
        viewModel.SetConfig()
    }

    // MARK: - 刷新
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

        self.performSegue(withIdentifier: "HomeCommentToPublish", sender: self.viewModel.modelObserable.value[(indexPath as NSIndexPath).row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.viewModel.modelObserable.value[(indexPath as NSIndexPath).row]
        return MLTopicCommentCell.height(model)
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
                print("HomeCommentToPublish \(isSucceed)")
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
        let text = label.textLayout!.text
        if (textRange.location >= text.length) {return}

        let highlight = text.yy_attribute(YYTextHighlightAttributeName, at: UInt(textRange.location)) as! YYTextHighlight

        let info = highlight.userInfo

        if (info?.count == 0) {return}

        if (info?[kSquareLinkAtName] != nil) {
            let name = info![kSquareLinkAtName]
            print("didClickTextInLabel Name: \(String(describing: name))")
            //        name = [name stringByURLEncode];
            //        if (name.length) {
            //            NSString *url = [NSString stringWithFormat:@"http://m.weibo.cn/n/%@",name];
            //            YYSimpleWebViewController *vc = [[YYSimpleWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
            //            [self.navigationController pushViewController:vc animated:YES];
            //        }
            return
        }

    }

}
