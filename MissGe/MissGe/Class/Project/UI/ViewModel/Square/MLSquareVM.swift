//
//  MLSquareVM.swift
//  MissGe
//
//  Created by chengxianghe on 2018/1/26.
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

class MLSquareVM: NSObject {
    var bag : DisposeBag = DisposeBag()
    let provider = MoyaProvider<APIManager>(endpointClosure: kAPIManagerEndpointClosure, requestClosure: kAPIManagerRequestClosure)
    let requestNewDataCommond = PublishSubject<Bool>()
    var modelObserable = Variable<[MLTopicCellLayout]> ([])
    
    var tableView: UITableView!
    var refreshStateObserable = Variable<LLRefreshStatus>(.none)
    var pageIndex = Int()
    var delegate: MLSquareCellDelegate?
    
    func SetConfig() {
        //MARK: Rx 绑定tableView数据
        modelObserable.asObservable().bind(to: tableView.rx.items) { tableView, row, model in
            var cell = tableView.dequeueReusableCell(withIdentifier: "MLTopicCell") as? MLTopicCell
            if cell == nil {
                cell = MLTopicCell(style: .default, reuseIdentifier: "MLTopicCell")
                cell?.delegate = self.delegate
            }
            cell!.setInfo(model);
            return cell!
            }.disposed(by: bag)
        
        requestNewDataCommond.subscribe { (event : Event<Bool>) in
            if event.element! {
                // 假装在请求第一页
                let page = 1
                
                self.provider
                    .rx
                    .request(.Square(page: page))
                    .filterSuccessfulStatusCodes()
                    .mapArray((MLSquareModel.self), keyPath: "content.artlist")
                    .subscribe(onSuccess: { (modelArray) in
                        
                        let array = modelArray.map({ (model) -> MLTopicCellLayout in
                            return MLTopicCellLayout(model: model)
                        })
                        
                        self.modelObserable.value = array
                        self.refreshStateObserable.value = .endHeaderRefresh
                        
                        if self.modelObserable.value.count < 20 {
                            self.refreshStateObserable.value = .noMoreData
                        } else {
                            self.pageIndex = 1
                            self.refreshStateObserable.value = .endFooterRefresh
                        }
                    }, onError: { ( error) in
                        print(error)
                        self.refreshStateObserable.value = .endHeaderRefresh
                    }).disposed(by: self.bag)
            }else{
                //  假装请求第二页数据
                let page = self.pageIndex + 1
                
                self.provider
                    .rx
                    .request(.Square(page: page))
                    .filterSuccessfulStatusCodes()
                    .mapArray((MLSquareModel.self), keyPath: "content.artlist")
                    .subscribe(onSuccess: { (modelArray) in
                        //.mapObject(type: MLHomePageModel.self)
                        let array = modelArray.map({ (model) -> MLTopicCellLayout in
                            return MLTopicCellLayout(model: model)
                        })
                        
                        self.modelObserable.value += array                        
                        if array.count < 20 {
                            self.refreshStateObserable.value = .noMoreData
                        } else {
                            self.pageIndex = page
                            self.refreshStateObserable.value = .endFooterRefresh
                        }
                        
                    }, onError: { (error) in
                        print(error)
                        self.refreshStateObserable.value = .endFooterRefresh
                    }).disposed(by: self.bag)
                
            }
            }.disposed(by: bag)
        
        refreshStateObserable.asObservable().subscribe(onNext: { (state) in
            switch state{
            case .beginHeaderRefresh:
                self.tableView.mj_header.beginRefreshing()
            case .endHeaderRefresh:
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.resetNoMoreData()
            case .beginFooterRefresh:
                self.tableView.mj_footer.beginRefreshing()
            case .endFooterRefresh:
                self.tableView.mj_footer.endRefreshing()
            case .noMoreData:
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            default:
                break
            }
        }).disposed(by: bag)
        
    }
}
