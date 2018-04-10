//
//  AppDelegate.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/12.
//  Copyright © 2017年 cn. All rights reserved.
//

import UIKit
import SVProgressHUD
import ESTabBarController_swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?

    var tencentOAuth: TencentOAuth!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SVProgressHUD.JCHUDConfig()
        
        let navigationBarAppearance = UINavigationBar.appearance() as UINavigationBar
        navigationBarAppearance.setBackgroundImage(UIImage(named: "nav_bg_320x64_")?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 5), for: UIBarMetrics.default)
        navigationBarAppearance.isTranslucent = false
        
        navigationBarAppearance.tintColor = kColorFromHexA(0xffffff)
        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17),
                                                       NSAttributedStringKey.foregroundColor:kColorFromHexA(0xffffff)]
        
        self.configThird()
        
        self.configThirdLoginAndShare()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = self.customIrregularityStyle(delegate: self)
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: - 第三方登录－分享
    func configThirdLoginAndShare() {
        
        //注册微信api
        WXApi.registerApp(kWeiXinAppID)
        
        //新浪微博注册
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(kWeiBoAppKey)
        
        //QQ
        self.tencentOAuth = TencentOAuth(appId: kQQAppID, andDelegate: nil)
        self.tencentOAuth.redirectURI = kQQRedirectURI;
    }
    
    func configThird() {
        //bugtags
        let options = BugtagsOptions()
        options.trackingUserSteps = true // 具体可设置的属性请查看 Bugtags.h
        Bugtags.start(withAppKey: kBugAppKey, invocationEvent: BTGInvocationEventShake, options: options)
    }
    
    // 打开第三方应用
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        //        let QQ = "tencent1104929797://response_from_qq?error_description=dGhlIHVzZXIgZ2l2ZSB1cCB0aGUgY3VycmVudCBvcGVyYXRpb24=&source=qq&source_scheme=mqqapi&error=-4&version=1"
        // let WeiBo = "wb1511606524://response?id=DA7C7270-25A9-4357-8736-721BECDC4FE7&sdkversion=2.5"
        
        return
            TencentOAuth.handleOpen(url) ||
                WXApi.handleOpen(url, delegate: WeiXinshareDelegate.currenWeiXinshareDelegate) ||
                WeiboSDK.handleOpen(url, delegate:SinaShareDelegate.currenSinaShareDelegate)
        
    }
    
    // 第三方应用的回调
    // 两个方法都存在的时候 优先调用 openURL: sourceApplication:annotation:
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        QQApiInterface.handleOpen(url, delegate: QQShareDelegate.currenQQshareDelegate)
        
        return
            TencentOAuth.handleOpen(url) ||
                WXApi.handleOpen(url, delegate: WeiXinshareDelegate.currenWeiXinshareDelegate) ||
                WeiboSDK.handleOpen(url, delegate:SinaShareDelegate.currenSinaShareDelegate)
    }
    
//MARK: tabbar
    func customIrregularityStyle(delegate: UITabBarControllerDelegate?) -> ESTabBarController {
        let tabBarController = ESTabBarController()
        tabBarController.delegate = delegate
        tabBarController.title = "Irregularity"
        tabBarController.tabBar.shadowImage = UIImage(named: "tabbar_transparent")
        tabBarController.tabBar.backgroundImage = UIImage(named: "tabbar_bg_nor")?.stretchableImage(withLeftCapWidth: 10, topCapHeight: 10)
        tabBarController.shouldHijackHandler = {
            tabbarController, viewController, index in
            if index == 2 {
                return true
            }
            return false
        }
        tabBarController.didHijackHandler = {
            [weak tabBarController] tabbarController, viewController, index in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
                let takePhotoAction = UIAlertAction(title: "Take a photo", style: .default, handler: nil)
                alertController.addAction(takePhotoAction)
                let selectFromAlbumAction = UIAlertAction(title: "Select from album", style: .default, handler: nil)
                alertController.addAction(selectFromAlbumAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                tabBarController?.present(alertController, animated: true, completion: nil)
            }
        }
        
        let v1 = kLoadVCFromSB("HomeViewController", stroyBoard: nil)!
        let nav1 = MLBaseNavigationController.init(rootViewController: v1)

        let v2 = kLoadVCFromSB("MLDiscoverController", stroyBoard: nil)!
        let nav2 = MLBaseNavigationController.init(rootViewController: v2)

        let v3 = kLoadVCFromSB("MLPostTopicController", stroyBoard: "Publish")!
        let nav3 = MLBaseNavigationController.init(rootViewController: v3)

        let v4 = kLoadVCFromSB("MLSquareViewController", stroyBoard: nil)!
        let nav4 = MLBaseNavigationController.init(rootViewController: v4)

        let v5 = kLoadVCFromSB("MLMineViewController", stroyBoard: nil)!
        let nav5 = MLBaseNavigationController.init(rootViewController: v5)

        nav1.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(),
                                            title: nil,
                                            image: UIImage(named: "tabbar_home_nor"),
                                            selectedImage: UIImage(named: "tabbar_home_sel"))
        nav2.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(),
                                            title: nil,
                                            image: UIImage(named: "tabbar_discover_nor"),
                                            selectedImage: UIImage(named: "tabbar_discover_sel"))
        nav3.tabBarItem = ESTabBarItem.init(ExampleIrregularityContentView(),
                                            title: nil,
                                            image: UIImage(named: "photo_verybig"),
                                            selectedImage: UIImage(named: "photo_verybig"))
        nav4.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(),
                                            title: nil,
                                            image: UIImage(named: "tabbar_social_nor"),
                                            selectedImage: UIImage(named: "tabbar_social_sel"))
        nav5.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(),
                                            title: nil,
                                            image: UIImage(named: "tabbar_mine_nor"),
                                            selectedImage: UIImage(named: "tabbar_mine_sel"))

        (nav1.tabBarItem as! ESTabBarItem).contentView?.renderingMode = .automatic;
        (nav2.tabBarItem as! ESTabBarItem).contentView?.renderingMode = .automatic;
//        (nav3.tabBarItem as! ESTabBarItem).contentView?.renderingMode = .automatic;
        (nav4.tabBarItem as! ESTabBarItem).contentView?.renderingMode = .automatic;
        (nav5.tabBarItem as! ESTabBarItem).contentView?.renderingMode = .automatic;

        tabBarController.viewControllers = [nav1, nav2, nav3, nav4, nav5]
        
        return tabBarController
    }
    
}


class ExampleBouncesContentView: ESTabBarItemContentView {
    
    public var duration = 0.3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }
    
    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
//        self.bounceAnimation()
//        completion?()
    }
    
    func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
}


class ExampleIrregularityBasicContentView: ExampleBouncesContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        textColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
//        highlightTextColor = UIColor.init(red: 23/255.0, green: 149/255.0, blue: 158/255.0, alpha: 1.0)
//        iconColor = UIColor.init(red: 124/255.0, green: 114/255.0, blue: 119/255.0, alpha: 1.0)
//        highlightIconColor = UIColor.init(red: 249/255.0, green: 33/255.0, blue: 164/255.0, alpha: 1.0)
//        backdropColor = UIColor.init(red: 10/255.0, green: 66/255.0, blue: 91/255.0, alpha: 1.0)
//        highlightBackdropColor = UIColor.init(red: 10/255.0, green: 66/255.0, blue: 91/255.0, alpha: 1.0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ExampleIrregularityContentView: ESTabBarItemContentView, CAAnimationDelegate {
    
    var scaleCompletion: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //128*99
        self.imageView.backgroundColor = UIColor.init(red: 251/255.0, green: 0/255.0, blue: 153/255.0, alpha: 1.0)
        self.imageView.layer.borderWidth = 3.0
        self.imageView.layer.borderColor = UIColor.init(white: 235 / 255.0, alpha: 1.0).cgColor
        self.imageView.layer.cornerRadius = 35
        self.insets = UIEdgeInsetsMake(-32, 0, 0, 0)
        let transform = CGAffineTransform.identity
        self.imageView.transform = transform
        self.superview?.bringSubview(toFront: self)
        
        textColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        highlightTextColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        iconColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        highlightIconColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        backdropColor = .clear
        highlightBackdropColor = .clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let p = CGPoint.init(x: point.x - imageView.frame.origin.x, y: point.y - imageView.frame.origin.y)
        return sqrt(pow(imageView.bounds.size.width / 2.0 - p.x, 2) + pow(imageView.bounds.size.height / 2.0 - p.y, 2)) < imageView.bounds.size.width / 2.0
    }
    
    public override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        
        let view = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: 2.0, height: 2.0)))
        view.layer.cornerRadius = 1.0
        view.layer.opacity = 0.5
        view.backgroundColor = UIColor.init(red: 180/255.0, green: 0/255.0, blue: 91/255.0, alpha: 1.0)
        self.addSubview(view)
        playMaskAnimation(animateView: view, target: self.imageView, completion: {
            [weak view] in
            view?.removeFromSuperview()
            completion?()
        })
    }
    
    public override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
//        completion?()
    }
    
    public override func deselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public override func highlightAnimation(animated: Bool, completion: (() -> ())?) {
        UIView.beginAnimations("small", context: nil)
        UIView.setAnimationDuration(0.2)
        let transform = self.imageView.transform.scaledBy(x: 0.8, y: 0.8)
        self.imageView.transform = transform
        UIView.commitAnimations()
        completion?()
    }
    
    public override func dehighlightAnimation(animated: Bool, completion: (() -> ())?) {
        UIView.beginAnimations("big", context: nil)
        UIView.setAnimationDuration(0.2)
        let transform = CGAffineTransform.identity
        self.imageView.transform = transform
        UIView.commitAnimations()
        completion?()
    }
    
    private func playMaskAnimation(animateView view: UIView, target: UIView, completion: (() -> ())?) {
        view.center = CGPoint.init(x: target.frame.origin.x + target.frame.size.width / 2.0, y: target.frame.origin.y + target.frame.size.height / 2.0)
        

        let scale = CABasicAnimation.init(keyPath: "transform.scale")
        scale.fromValue = NSValue.init(cgSize: CGSize.init(width: 1.0, height: 1.0))
        scale.toValue = NSValue.init(cgSize: CGSize.init(width: 36.0, height: 36.0))
        scale.beginTime = CACurrentMediaTime()
        scale.duration = 0.3
        scale.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        scale.isRemovedOnCompletion = true
        scale.delegate = self

        let alpha = CABasicAnimation(keyPath: "opacity")
        alpha.fromValue = 0.6
        alpha.toValue = 0.6
        alpha.beginTime = CACurrentMediaTime()
        alpha.duration = 0.25
        alpha.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        alpha.isRemovedOnCompletion = true
        
        view.layer.add(scale, forKey: "scale")
        view.layer.add(alpha, forKey: "alpha")
        
        self.scaleCompletion = completion
//        scale.completionBlock = ({ animation, finished in
//            completion?()
//        })
    }
    
    //    func animationDidStart(_ anim: CAAnimation) {
    //
    //    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //方法中的flag参数表明了动画是自然结束还是被打断,比如调用了removeAnimationForKey:方法或removeAnimationForKey方法，flag为NO，如果是正常结束，flag为YES。
        scaleCompletion?()
    }
}
