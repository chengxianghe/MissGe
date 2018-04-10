//
//  WeixinActivity.swift
//  HuaBanNew
//
//  Created by chengxianghe on 16/6/16.
//  Copyright © 2016年 CXH. All rights reserved.
//

import Foundation

class WeiXinActivity: UIActivity {
    var title: String?
    var shareDescription: String?
    var image: UIImage?
    var url: URL?
    var scene: WXScene = WXSceneSession
    var thumbImage: UIImage?

    override init() {
        super.init()
    }

    // 返回值是告诉系统这个是action类型，还是share类型的，一般默认的是action类型的   
    internal override class var activityCategory: UIActivityCategory {
        return UIActivityCategory.share
    }

    // 用来区分不用的activity的字符串
    override var activityType: UIActivityType? {
        return UIActivityType.init("HuaBanNew" + NSStringFromClass(self.classForCoder))
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() {
            for activityItem in activityItems {
                if (activityItem as AnyObject).isKind(of: UIImage.classForCoder()) {
                    return true
                }

                if (activityItem as AnyObject).isKind(of: NSURL.classForCoder()) {
                    return true
                }

                if (activityItem as AnyObject).isKind(of: NSString.classForCoder()) {
                    return true
                }
            }
        }
        return false
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        for activityItem in activityItems {
            if (activityItem as AnyObject).isKind(of: UIImage.classForCoder()) {
                image = activityItem as? UIImage
            }

            if (activityItem as AnyObject).isKind(of: NSURL.classForCoder()) {
                url = activityItem as? URL
            }

            if (activityItem as AnyObject).isKind(of: NSString.classForCoder()) {
                title = activityItem as? String
            }
        }
    }

    override func perform() {
        let req = SendMessageToWXReq()
        req.scene = Int32(scene.rawValue)
        req.bText = title != nil && (title! as NSString).length > 0 && image == nil && url == nil

        /** 发送消息的类型，包括文本消息和多媒体消息两种，两者只能选择其一，不能同时发送文本和多媒体消息 */
        if req.bText {
            // 文本长度必须大于0且小于10K
            req.text = title
        } else {
            req.message = WXMediaMessage()
            req.message.title = title
            req.message.description = (shareDescription != nil && shareDescription!.length > 100) ? (shareDescription! as NSString).substring(to: 100) : shareDescription

            if url != nil {
                let webObject = WXWebpageObject()
                webObject.webpageUrl = url?.absoluteString
                thumbImage = thumbImage ?? image
                if thumbImage != nil {
                    let thumbImageData = ShareManager.scaleImageDataForSize(thumbImage!, limitDataSize: 30000)
                    print(thumbImageData?.count ?? 0)
                    req.message.thumbData = thumbImageData
                }
                req.message.mediaObject = webObject
            } else if image != nil {
                let imageObject = WXImageObject()
                // 原图 最多不能超过10M 10485760
                let imageData = ShareManager.scaleImageDataForSize(image!, limitDataSize: 10000000)
                imageObject.imageData = imageData
                //缩略图数据大小不能超过32K - 32768
                thumbImage = thumbImage ?? image
                let thumbImageData = ShareManager.scaleImageDataForSize(thumbImage!, limitDataSize: 30000)
                print(thumbImageData?.count ?? 0)
                req.message.thumbData = thumbImageData
                req.message.mediaObject = imageObject
            }
        }
        WXApi.send(req)

        self.activityDidFinish(true)
    }

}

class WeiXinSessionActivity: WeiXinActivity {
    override init() {
        super.init()
        scene = WXSceneSession
    }

    // ios8.0 是支持彩色团素材的，返回的是你所要点击的图标，
    override var activityImage: UIImage? {
//        if Int(UIDevice.currentDevice().systemVersion) >= 8 {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_session-8" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        } else {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_session" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        }

        return UIImage(named: "WeiXinActivity.bundle" + "/icon_session-8" + (UIScreen.main.scale > 1 ? "@2x" : "")  + ".png")
    }

    // 返回的是选项图标下面的文字
    override var activityTitle: String? {
        return NSLocalizedString("weixin-session", tableName: "WeiXinActivity", bundle: Bundle.main, value: "", comment: "")
    }
}

class WeiXinTimelineActivity: WeiXinActivity {
    override init() {
        super.init()
        scene = WXSceneTimeline
    }

    override var activityImage: UIImage? {
//        if Int(UIDevice.currentDevice().systemVersion) >= 8 {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline-8" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        } else {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        }
        return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline-8" + (UIScreen.main.scale > 1 ? "@2x" : "")  + ".png")
    }

    override var activityTitle: String? {
        return NSLocalizedString("weixin-timeline", tableName: "WeiXinActivity", bundle: Bundle.main, value: "", comment: "")
    }
}

class WeiXinFavoriteActivity: WeiXinActivity {
    override init() {
        super.init()
        scene = WXSceneFavorite
    }
    // default is UIActivityCategoryAction.
    internal override class var activityCategory: UIActivityCategory {
        return UIActivityCategory.action
    }
    override var activityImage: UIImage? {
//        if Int(UIDevice.currentDevice().systemVersion) >= 8 {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline-8" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        } else {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        }
        return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline-8" + (UIScreen.main.scale > 1 ? "@2x" : "")  + ".png")
    }

    override var activityTitle: String? {
        return NSLocalizedString("weixin-favorite", tableName: "WeiXinActivity", bundle: Bundle.main, value: "", comment: "")
    }
}
