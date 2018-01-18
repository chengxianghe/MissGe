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

class MLDiscoverVM: NSObject {
    var bag : DisposeBag = DisposeBag()
    let provider = MoyaProvider<APIManager>(endpointClosure: kAPIManagerEndpointClosure, requestClosure: kAPIManagerRequestClosure)
    let requestNewDataCommond = PublishSubject<Bool>()
    var modelObserable = Variable<[MLHomePageModel]> ([])
    var tableView: UITableView!
    var refreshStateObserable = Variable<LLRefreshStatus>(.none)
    
    func SetConfig() {
        //MARK: Rx 绑定tableView数据
        modelObserable.asObservable().bind(to: tableView.rx.items) { tableView, row, model in
            var cell = tableView.dequeueReusableCell(withIdentifier: "MLDiscoverCell") as? MLDiscoverCell
            if cell == nil {
                cell = MLDiscoverCell(style: .default, reuseIdentifier: "MLDiscoverCell")
            }
            cell!.setInfo(model.cover);

            return cell!
            }.disposed(by: bag)
        
        
        requestNewDataCommond.subscribe { (event : Event<Bool>) in
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
            }.disposed(by: bag)
        
        
        refreshStateObserable.asObservable().subscribe(onNext: { (state) in
            switch state{
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
