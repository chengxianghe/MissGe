//
//  HomeViewModel.swift
//  RxMissGe
//
//  Created by chengxianghe on 2017/11/27.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Moya
import Alamofire
import MJRefresh
import YYWebImage

enum LLRefreshStatus {
    case none
    case beginHeaderRefresh
    case endHeaderRefresh
    case beginFooterRefresh
    case endFooterRefresh
    case noMoreData
}


//public func defaultAlamofireManager() -> Manager {
//
//    let configuration = URLSessionConfiguration.default
//
//    configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
//
//    let policies: [String: ServerTrustPolicy] = [
//        "ap.grtstar.cn": .disableEvaluation
//    ]
//    let manager = Alamofire.SessionManager(configuration: configuration,serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies))
//
//    manager.startRequestsImmediately = false
//
//    return manager
//}

class MLHomeViewModel: NSObject {
    
    var bag : DisposeBag = DisposeBag()
    
    let provider = MoyaProvider<APIManager>(endpointClosure: kAPIManagerEndpointClosure, requestClosure: kAPIManagerRequestClosure)
    
    var modelObserable = Variable<[MLHomePageModel]> ([])
    var bannerModelObserable = Variable<[MLHomeBannerModel]> ([])

    var refreshStateObserable = Variable<LLRefreshStatus>(.none)
    
    let requestNewDataCommond =  PublishSubject<Bool>()
    
    var pageIndex = Int()
    
    var tableView: UITableView!
    var scrollAdView: GMBScrollAdView!

    func checkAdView() {
        
        // 1.判断沙盒中是否存在广告图片，如果存在，直接显示
        let filePath = self.getFilePathWithImageName(imageName: adImageName);
        
        let isExist = FileManager.default.fileExists(atPath: filePath)
        
        if isExist {
            let advertiseView = AdvertiseView(frame: UIApplication.shared.keyWindow!.bounds)
            advertiseView.filePath = filePath
            advertiseView.setAdDismiss(nil, save: {[weak self] in
                
                //保存图片
                PhotoAlbumHelper.saveImageToAlbum(UIImage(contentsOfFile: filePath)!, completion: { (result: PhotoAlbumHelperResult, err: NSError?) in
                    if result == .success {
                        self?.showSuccess("保存成功!")
                    } else {
                        self?.showError(err?.localizedDescription ?? "保存出错")
                    }
                })
            })
            advertiseView.show()
        }
        
        // 2.无论沙盒中是否存在广告图片，都需要重新调用广告接口，判断广告是否更新
        self.refreshImageUrl()
    }
    
    func refreshImageUrl() {
//        TUNetwork().rx
        self.provider
            .rx
            .request(.AppStart)
            .filterSuccessfulStatusCodes()
//            .mapParseJSON()
//            .map(MLHomeBannerModel.self, atKeyPath: "content", using: JSONDecoder())
            .mapObject((MLHomeBannerModel.self), keyPath: "content")
            .subscribe(onSuccess: { (adModel) in
                guard let url = adModel.path?.absoluteString else {
                    return
                }
                
                let lastUrl = UserDefaults.standard.value(forKey: adUrl) as? String ?? ""
                
                if url != lastUrl {
                    
                    YYWebImageManager.shared().requestImage(with: adModel.path!, options: YYWebImageOptions.ignoreDiskCache, progress: nil, transform: nil, completion: { (image, imageUrl, from, stage, error) in
                        DispatchQueue.global().async(execute: {
                            
                            let data = image!.yy_imageDataRepresentation()
                            try? data?.write(to: URL.init(fileURLWithPath: self.getFilePathWithImageName(imageName: adImageName)))
                            
                            UserDefaults.standard.set(url, forKey: adUrl)
                            UserDefaults.standard.synchronize()
                        })
                        
                    })
                }
            }) { (error) in
                print(error)
        }.disposed(by: bag)
    }
    
    func getFilePathWithImageName(imageName: String) -> String {
        let filePath = kCachesPath().appending("/\(imageName)")
        return filePath;
    }
    
    func SetConfig() {
        //MARK: Rx 绑定tableView数据
        modelObserable.asObservable().bind(to: tableView.rx.items) { tableView, row, model in
            if model.type == 5 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MLHomePageAlbumCell") as? MLHomePageAlbumCell
                cell?.setInfo(model);
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MLHomePageCell") as? MLHomePageCell
                cell?.setInfo(model);
                return cell!
            }
            }
            .disposed(by: bag)
        
        requestNewDataCommond.subscribe { (event : Event<Bool>) in
            if event.element! {
                // 假装在请求第一页
                let page = 1

                self.provider
                    .rx
                    .request(.HomePageBanner)
                    .filterSuccessfulStatusCodes()
//                    .mapObject(MLHomeBannerModel.self, keyPath: "content")
                    .mapArray(MLHomeBannerModel.self, keyPath: "content")
                    .subscribe(onSuccess: { (array) in
//                        guard let dict = responseObject as? NSDictionary else {
//                            return
//                        }
//
//                        guard let content = dict["content"] as? [[String:Any]] else {
//                            return
//                        }
//                        let array = content.map({ MLHomeBannerModel(JSON: $0) }) as! [MLHomeBannerModel]
                        
                        self.bannerModelObserable.value = array
                        
                        let urls = array.flatMap({ $0.path })
                        
                        self.scrollAdView.updateImages(urls, titles: nil)
                        
                    }, onError: { (error) in
                        print(error)
                    }).disposed(by: self.bag)
    
                self.provider
                    .rx
                    .request(.HomePage(page))
                    .filterSuccessfulStatusCodes()
                    .mapArray((MLHomePageModel.self), keyPath: "content.artlist")
                    .subscribe(onSuccess: { (array) in
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
                        print(error)
                        self.refreshStateObserable.value = .endHeaderRefresh
                    }).disposed(by: self.bag)
            }else{
                //  假装请求第二页数据
                let page = self.pageIndex + 1
                
                self.provider
                    .rx
                    .request(.HomePage(page))
                    .filterSuccessfulStatusCodes()
                    .mapParseJSON()
                    .subscribe(onSuccess: { (responseObject) in
                        //.mapObject(type: MLHomePageModel.self)
                        var array: [MLHomePageModel]? = nil
                        if let list = ((responseObject as! NSDictionary)["content"] as! NSDictionary)["artlist"] as? [[String:Any]] {
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
