//
//  MLHomeSubjectVM.swift
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

class MLHomeSubjectVM: NSObject {
    var bag: DisposeBag = DisposeBag()
    let provider = MoyaProvider<APIManager>(endpointClosure: kAPIManagerEndpointClosure, requestClosure: kAPIManagerRequestClosure)
    let requestNewDataCommond = PublishSubject<Bool>()
    var tag_id: String = ""
    var subjectType: SubjectType = SubjectType.tag
    var pageIndex: Int = 1

    var modelObserable = Variable<[MLHomePageModel]> ([])
    var tableView: UITableView!
    var refreshStateObserable = Variable<LLRefreshStatus>(.none)

    func SetConfig() {
        // MARK: Rx 绑定tableView数据
        modelObserable.asObservable().bind(to: tableView.rx.items) { tableView, row, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: "MLHomePageCell") as? MLHomePageCell
                cell?.setInfo(model)
                return cell!
            }
            .disposed(by: bag)

        requestNewDataCommond.subscribe { (event: Event<Bool>) in
            if event.element! {
                // 假装在请求第一页
                let page = 1
                self.showLoading("正在加载...")
                self.provider
                    .rx
                    .request(.DiscoverDetail(page: page, tag_id: self.tag_id, type: self.subjectType))
                    .filterSuccessfulStatusCodes()
                    .mapArray((MLHomePageModel.self), keyPath: "content.artlist")
                    .subscribe(onSuccess: { (array) in
                        self.hideHud()
                        //                        var array: [MLHomePageModel]? = nil
                        //                        if let list = ((responseObject as! NSDictionary)["content"] as! NSDictionary)["artlist"] as? [[String:Any]] {
                        //                            array = list.map({ MLHomePageModel(JSON: $0) }) as? [MLHomePageModel]
                        //                        }

                        self.modelObserable.value = array
                        self.refreshStateObserable.value = .endHeaderRefresh

                        if self.modelObserable.value.count < 20 {
                            self.refreshStateObserable.value = .noMoreData
                        } else {
                            self.pageIndex = 1
                            self.refreshStateObserable.value = .endFooterRefresh
                        }
                    }, onError: { ( error) in
                        self.hideHud()
                        print(error)
                        self.refreshStateObserable.value = .endHeaderRefresh
                    }).disposed(by: self.bag)
            } else {
                //  假装请求第二页数据
                let page = self.pageIndex + 1

                self.provider
                    .rx
                    .request(.DiscoverDetail(page: page, tag_id: self.tag_id, type: self.subjectType))
                    .filterSuccessfulStatusCodes()
                    .mapParseJSON()
                    .subscribe(onSuccess: { (responseObject) in
                        //.mapObject(type: MLHomePageModel.self)
                        var array: [MLHomePageModel]? = nil
                        if let list = ((responseObject as! NSDictionary)["content"] as! NSDictionary)["artlist"] as? [[String: Any]] {
                            array = list.map({ MLHomePageModel(JSON: $0) }) as? [MLHomePageModel]
                        }

                        self.modelObserable.value += array ?? []

                        if array!.count < 20 {
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
            switch state {
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
