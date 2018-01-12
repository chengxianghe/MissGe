//
//  MLHomeDetailController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/22.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import ObjectMapper
import YYText
import WebKit
import SVProgressHUD
import YYWebImage
import RxSwift
import RxCocoa
import Moya

//
typealias MLHomeDetailControllerNextClosure = (_ aid: String) -> String?

class MLHomeDetailController: BaseViewController {

    var aid: String!
    var showTitle: String?
    var nextClosure: MLHomeDetailControllerNextClosure?

    var nextAid: String?
    var webView = WKWebView()
    var detailModel: MLHomeDetailModel?
    var progressView: UIProgressView!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    let viewModel = MLHomeDetailVM()
    var bag : DisposeBag = DisposeBag()
    
    deinit {
        // 取消监听支持KVO的属性
        self.webView.removeObserver(self, forKeyPath: "loading")
        self.webView.removeObserver(self, forKeyPath: "title")
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        SVProgressHUD.dismiss()
    }
    
    convenience init(aid: String, title: String?) {
        self.init()
        self.aid = aid
        self.showTitle = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.title = self.showTitle
        self.webView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: kScreenHeight - 64 - 46)
        self.view.addSubview(self.webView)
        self.view.bringSubview(toFront: bottomView)
        
        self.progressView = UIProgressView(progressViewStyle: .default)
        self.progressView.frame.size.width = self.view.frame.size.width
        self.progressView.frame.size.height = 6
        self.progressView.progressTintColor = UIColor.red
        // 更改进度条高度
        self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0);
        self.view.addSubview(self.progressView)
        
        // 监听支持KVO的属性
        self.webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        self.viewModel.detailVC = self
        self.viewModel.SetConfig()
        self.getCurrentData(aid: aid)
        
        self.nextButton.isEnabled = false
    }
    
    func getCurrentData(aid: String?) {
        guard aid != nil else {
            return
        }
        self.aid = aid
        self.viewModel.aid = aid!
        self.viewModel.requestNewDataCommond.onNext(true)
    }

//    func updateData() {
//        self.title = detailModel?.title
//        self.likeLabel.text = String(format: "%d", detailModel?.like ?? 0)
//        self.favoriteButton.isSelected = (detailModel?.is_collect)!
//        print("is_collect:\(String(describing: detailModel?.is_collect)), \(String(describing: detailModel?.is_special))")
//
//        //            print(self.detailModel!.detail)
//        //            self.webView.loadHTMLString(detailModel!.detail, baseURL: nil)
//        self.aid = detailModel!.tid
//
//        if let next = self.nextClosure?(self.aid) {
//            self.nextButton.isEnabled = true
//            self.nextAid = next
//        } else {
//            self.nextButton.isEnabled = false
//            self.nextAid = nil
//        }
//
//        //http://t.gexiaojie.com/index.php?m=mobile&c=explorer&a=article&aid=5677
//        let url = "http://t.gexiaojie.com/index.php?m=mobile&c=explorer&a=article&aid=\(self.aid ?? "")"
//        self.webView.load(URLRequest(url: URL(string: url)!))
//    }
//
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loading" {
            print("loading")
        } else if keyPath == "title" {
//            self.title = self.webView.title
        } else if keyPath == "estimatedProgress" {
            print(webView.estimatedProgress)
            if self.progressView.alpha == 0 {
                self.progressView.alpha = 1
            }
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        
        // 已经完成加载时，我们就可以做我们的事了
        if !webView.isLoading {
            UIView.animate(withDuration: 0.3, animations: { 
                self.progressView.alpha = 0.0;
            }, completion: { (finish) in
                self.progressView.setProgress(0, animated: false)
            })
        }
    }
    

    @IBAction func onShareButtonClick(_ sender: UIButton) {
        
        guard let model: MLHomeDetailModel = self.detailModel else {
            return
        }
            
            ShareManager.manager().showShareViewWithBlock({ (type) -> () in
         
                let title = model.title
                let desc = model.summary
                let link = model.link_url!.absoluteString
                let imageUrl: String = model.cover!.absoluteString
                
                var result = false

                if type == .qZoneShare || type == .qqShare {
                    if type == .qZoneShare {
                        print("分享到QQ空间");
                        result = QQShareHelp.currentHelp().sendLinkUrlToQZone(title, description: desc, imageUrl: imageUrl, url: link)
                    } else {
                        print("分享到QQ");
                        result = QQShareHelp.currentHelp().sendLinkUrl(title, description: desc, imageUrl: imageUrl, url: link)
                    }
                    print(result)
                } else {
                    YYWebImageManager.shared().requestImage(with: model.cover!, options: YYWebImageOptions.avoidSetImage, progress: nil, transform: nil, completion: { (requestImage, url, yyType, stage, error) in
                        if error != nil || requestImage == nil {
                            print(result)
                            return
                        }
                        let image = requestImage!
                        
                        switch (type) {
                        case .weiBoShare:
                            print("分享到新浪微博");
                            result = SinaShareHelp.currentHelp().shareLink(title: title, desc: desc, url: link, thumbImage: image, objectID: model.tid)
                        case .weiXinFriendsShare:
                            print("分享到朋友圈");
                            //    weixin
                            result = WeiXinShareHelp.currentHelp().sendLinkURL(link, title: title, description: desc, thumbImage: image, InScene: WXSceneTimeline)
                        case .weiXinShare:
                            print("分享到微信好友");
                            result = WeiXinShareHelp.currentHelp().sendLinkURL(link, title: title, description: desc, thumbImage: image, InScene: WXSceneSession)
                        case .weiXinFavoriteShare:
                            print("分享到微信收藏");
                            result = WeiXinShareHelp.currentHelp().sendLinkURL(link, title: title, description: desc, thumbImage: image, InScene: WXSceneFavorite)
                        default:
                            print("分享错误")
                        }
                        
                        print(result)
                    })
                    
 
                }
            })
    }
    @IBAction func onFavoriteButtonClick(_ sender: UIButton) {
        MLRequestHelper.favoriteWith(self.aid, succeed: { (base, responseObject) in
            self.showSuccess(sender.isSelected ? "已取消收藏" :"收藏成功!")
            sender.isSelected = !sender.isSelected
            }) { (base, error) in
                self.showError(error.localizedDescription)
        }
        
    }
    @IBAction func onLikeButtonClick(_ sender: UIButton) {
        if sender.isSelected {
            self.showMessage("您已经点过赞啦")
            return
        }
        MLRequestHelper.likeArticleWith(self.aid, succeed: { (base, responseObject) in
            self.showSuccess("点赞成功!")
            self.likeButton.isSelected = true
            self.likeLabel.text = "\((self.likeLabel.text! as NSString).integerValue + 1)"
            self.showLoveAnimation()
            
        }) { (base, error) in
            self.showError(error.localizedDescription)
        }
    }
    
    func showLoveAnimation() {
//        let heart = DMHeartFlyView.init(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
//        self.view.addSubview(heart)
//        let fountainSource = CGPoint(x: kScreenWidth/2, y: self.view.bounds.size.height - 36/2.0 - 10);
//        heart.center = fountainSource;
//        heart.animate(in: self.view)

    }
    
    @IBAction func onCommentButtonClick(_ sender: UIButton) {
        self.performSegue(withIdentifier: "HomeDetailToComment", sender: nil)
    }
    
    @IBAction func onNextButtonClick(_ sender: UIButton) {
        self.getCurrentData(aid: self.nextAid)
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
        if segue.identifier == "HomeDetailToComment" {
            let vc = segue.destination as! MLHomeCommentController
            vc.aid = self.aid
        }

    }

}
