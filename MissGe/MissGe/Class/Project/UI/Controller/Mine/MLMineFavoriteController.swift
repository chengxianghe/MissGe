//
//  MLMineFavoriteController.swift
//  MissGe
//
//  Created by chengxianghe on 2017/5/19.
//  Copyright © 2017年 cn. All rights reserved.
//

import UIKit
import MJRefresh
import XHPhotoBrowser

class MLMineFavoriteController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var dataSource = [MLHomePageModel]()
    let favoriteRequest = MLMineFavoriteRequest()
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        print("login:\(MLNetConfig.isUserLogin())")

        self.configRefresh()
    }

    // MARK: - 刷新
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

    // MARK: - 数据请求
    func loadData(_ page: Int) {

        favoriteRequest.page = page
        favoriteRequest.send(success: {[unowned self] (baseRequest, responseObject) in
            self.tableView.mj_header.endRefreshing()

            var array: [MLHomePageModel]? = nil
            if let list = ((responseObject as! NSDictionary)["content"] as! NSDictionary)["collectlist"] as? [[String: Any]] {
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

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let model = self.dataSource[(indexPath as NSIndexPath).row] as MLHomePageModel

        if model.type == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MLHomePageAlbumCell") as? MLHomePageAlbumCell
            cell?.setInfo(self.dataSource[(indexPath as NSIndexPath).row])
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MLHomePageCell") as? MLHomePageCell
            cell?.setInfo(self.dataSource[(indexPath as NSIndexPath).row])
            return cell!
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.dataSource[(indexPath as NSIndexPath).row]
        if model.type == 5 {
            self.performSegue(withIdentifier: "FavoriteToAlbumDetail", sender: model)
        } else {
            self.performSegue(withIdentifier: "FavoriteToDetail", sender: model.tid)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.dataSource[(indexPath as NSIndexPath).row] as MLHomePageModel
        if model.type == 5 {
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
        if segue.identifier == "FavoriteToDetail" {
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
        } else if segue.identifier == "FavoriteToAlbumDetail" {
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
            vc.moreBlock = {[aid = (sender as! MLHomePageModel).tid, _self = self] in
                let commentVC = kLoadVCFromSB("MLHomeCommentController", stroyBoard: "HomeComment") as! MLHomeCommentController
                commentVC.aid = aid
                _self.navigationController?.pushViewController(commentVC, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
