//
//  MLDiscoverVM.swift
//  MissGe
//
//  Created by chengxianghe on 2018/1/18.
//  Copyright © 2018年 cn. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import Alamofire
import MJRefresh
import YYWebImage
import WebKit
import SVProgressHUD
import RxDataSources

struct MLSectionTagModel {
    var header: String
    var items: [MLDiscoverTagModel]
}
extension MLSectionTagModel: SectionModelType {
    init(original: MLSectionTagModel, items: [MLDiscoverTagModel]) {
        self = original
        self.items = items
    }
}

class MLDiscoverVM: NSObject {
    var bag: DisposeBag = DisposeBag()
    let provider = MoyaProvider<APIManager>(endpointClosure: kAPIManagerEndpointClosure, requestClosure: kAPIManagerRequestClosure)
    let requestNewDataCommond = PublishSubject<Bool>()
    var modelObserable = Variable<[MLHomePageModel]> ([])
    let sectionModelObserable = Variable<[MLSectionTagModel]> ([])

    var tableView: UITableView!
    var collectionView: UICollectionView!
    var refreshStateObserable = Variable<LLRefreshStatus>(.none)

    func SetConfig() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<MLSectionTagModel>(configureCell: { (ds: CollectionViewSectionedDataSource<MLSectionTagModel>, collectionView: UICollectionView, indexPath: IndexPath, model: MLSectionTagModel.Item) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MLDiscoverHeaderCell", for: indexPath) as! MLDiscoverHeaderCell
            //0  1  2  3  4  5  6  7  8  9   10 11
            //0. 4. 1. 5. 2. 6. 3. 7, 8  12  9  13
//            var index = 0
//            if (indexPath as NSIndexPath).row % 2 == 0 {
//                index = (indexPath as NSIndexPath).row / 2 + (indexPath as NSIndexPath).section * 8
//            } else {
//                index = (indexPath as NSIndexPath).row + 3 - ((indexPath as NSIndexPath).row / 2) + (indexPath as NSIndexPath).section * 8
//            }
//
            cell.setInfo(model)

            return cell
        })

        sectionModelObserable
            .asObservable()
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        // MARK: Rx 绑定tableView数据
        modelObserable.asObservable().bind(to: tableView.rx.items) { tableView, row, model in
            var cell = tableView.dequeueReusableCell(withIdentifier: "MLDiscoverCell") as? MLDiscoverCell
            if cell == nil {
                cell = MLDiscoverCell(style: .default, reuseIdentifier: "MLDiscoverCell")
            }
            cell!.setInfo(model.cover)

            return cell!
            }.disposed(by: bag)

        requestNewDataCommond.subscribe { (event: Event<Bool>) in
            self.showLoading("正在加载...")
                self.provider
                    .rx
                    .request(.Discover)
                    .filterSuccessfulStatusCodes()
                    .mapArray((MLHomePageModel.self), keyPath: "content.artlist")
                    .subscribe(onSuccess: { (array) in
                        self.hideHud()
                        self.modelObserable.value = array
                        self.refreshStateObserable.value = .endHeaderRefresh
                    }, onError: { ( error) in
                        self.hideHud()
                        print(error)
                        self.refreshStateObserable.value = .endHeaderRefresh
                    }).disposed(by: self.bag)

            self.provider
                .rx
                .request(.DiscoverTag)
                .filterSuccessfulStatusCodes()
                .mapArray((MLDiscoverTagModel.self), keyPath: "content.list")
                .subscribe(onSuccess: { (array) in
                    self.hideHud()
                    var models = array
                    let sectionNum = array.count / 8
                    var sections = [MLSectionTagModel]()
                    for _ in 0..<sectionNum {
                        let model = MLSectionTagModel.init(header: "", items: Array(models.prefix(8)))
                        models.removeSubrange(Range.init(0..<8))
                        sections.append(model)
                    }
                    self.sectionModelObserable.value = sections
//                    self.refreshStateObserable.value = .endHeaderRefresh
                }, onError: { ( error) in
                    self.hideHud()
                    print(error)
//                    self.refreshStateObserable.value = .endHeaderRefresh
                }).disposed(by: self.bag)
            }.disposed(by: bag)

//        discoverTagRequest.send(success: {[unowned self] (baseRequest, responseObject) in
//            self.tableView.mj_header.endRefreshing()
//            
//            var array: [MLDiscoverTagModel]? = nil
//            if let list = ((responseObject as! NSDictionary)["content"] as! NSDictionary)["list"] as? [[String:Any]] {
//                array = list.map({ MLDiscoverTagModel(JSON: $0)! })
//                //modelArray = NSArray.yy_modelArray(with: MLTopicCommentModel.classForCoder(), json: list) as? [MLTopicCommentModel]
//            }
//            
//            if array != nil && array!.count > 0 {
//                self.tagsArray.removeAll()
//                self.tagsArray.append(contentsOf: array!)
//            }
//            
//            self.collectionView.reloadData()
//            
//        }) { (baseRequest, error) in
//            self.tableView.mj_header.endRefreshing()
//            print(error)
//        }

        refreshStateObserable.asObservable().subscribe(onNext: { (state) in
            switch state {
            case .beginHeaderRefresh:
                self.tableView.mj_header.beginRefreshing()
            case .endHeaderRefresh:
                self.tableView.mj_header.endRefreshing()
            default:
                break
            }
        }).disposed(by: bag)

    }
}
