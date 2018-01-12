//
//  MLHomeDetailVM.swift
//  MissGe
//
//  Created by chengxianghe on 2018/1/12.
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

class MLHomeDetailVM: NSObject {
    var bag : DisposeBag = DisposeBag()
    let provider = MoyaProvider<APIManager>(endpointClosure: kAPIManagerEndpointClosure, requestClosure: kAPIManagerRequestClosure)
    let requestNewDataCommond =  PublishSubject<Bool>()
    var aid: String = ""
    weak var detailVC: MLHomeDetailController! = nil

    func SetConfig() {    
        requestNewDataCommond.subscribe {[weak self] (event : Event<Bool>) in
            guard let weak_self = self else {
                return
            }
            // 假装在请求第一页
            weak_self.provider
                .rx
                .request(.HomePageDetail(weak_self.aid))
                .filterSuccessfulStatusCodes()
                .mapObject((MLHomeDetailModel.self), keyPath: "content")
                .subscribe(onSuccess: { (detailModel) in
                    
                    weak_self.detailVC.detailModel = detailModel
                    
                    weak_self.detailVC.title = detailModel.title
                    weak_self.detailVC.likeLabel.text = String(format: "%d", detailModel.like )
                    weak_self.detailVC.favoriteButton.isSelected = (detailModel.is_collect)
                    print("is_collect:\(String(describing: detailModel.is_collect)), \(String(describing: detailModel.is_special))")
                    
                    
                    if let next = weak_self.detailVC.nextClosure?(weak_self.aid) {
                        weak_self.detailVC.nextButton.isEnabled = true
                        weak_self.detailVC.nextAid = next
                    } else {
                        weak_self.detailVC.nextButton.isEnabled = false
                        weak_self.detailVC.nextAid = nil
                    }
                    
                    //http://t.gexiaojie.com/index.php?m=mobile&c=explorer&a=article&aid=5677
                    let url = "http://t.gexiaojie.com/index.php?m=mobile&c=explorer&a=article&aid=\(weak_self.aid)"
                    weak_self.detailVC.webView.load(URLRequest(url: URL(string: url)!))
                    
                    SVProgressHUD.dismiss()
                    
                }, onError: { ( error) in
                    print(error)
                    SVProgressHUD.dismiss()
                }).disposed(by: weak_self.bag)
            }.disposed(by: self.bag)
        
    }
    
}
