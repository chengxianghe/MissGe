//
//  SinaShareHelp.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/6.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class SinaShareHelp: NSObject {
    var wbtoken: String?
    var wbCurrentUserID: String?
    
    static let instance = SinaShareHelp()
    class func currentHelp() -> SinaShareHelp {
        return instance
    }
     
    /*!
    *    @author zhuhao, 15-01-06 15:01:01
    *
    *    @brief  分享文字 图片 链接
    *
    *    @param text       标题
    *    @param shareImage 图片
    *    @param url        链接
    *
    *    @since 1.0
    */
    func shareText(_ text: String, shareImage: UIImage?, url: String?) -> Bool {
        
        if !WeiboSDK.isCanShareInWeiboAPP() {
            print("抱歉,您没有安装微博客户端")
            return false;
        }
        
        let message = WBMessageObject.message() as! WBMessageObject
        
        if text.length > 0 {
            message.text = String(format: "%@%@",text,url ?? "")
        }
        
        if (shareImage != nil) {
            let image = WBImageObject()
            
            // 原图 最多不能超过10M 10485760
            let imageData = ShareManager.scaleImageDataForSize(shareImage!, limitDataSize: 10000000);
            print(imageData?.count ?? 0)
            
            image.imageData = imageData
            message.imageObject = image;
        }
        
        return self.shareWBMessageObject(message)
    }
    
    func shareText(_ text: String, shareImagePath: String, url: String) -> Bool {
        let data = try? Data(contentsOf: URL(fileURLWithPath: shareImagePath))
        if data != nil {
            return self.shareText(text, shareImage: UIImage(data: data!), url: url)
        } else {
            return self.shareText(text, shareImage: nil, url: url)
        }
    }
    
    func shareLink(title: String, desc: String, url: String, thumbImage: UIImage?, objectID: String = "0") -> Bool {
        
        let message = WBMessageObject.message() as! WBMessageObject

        let web: WBWebpageObject = WBWebpageObject()
        web.objectID = objectID
        web.webpageUrl = url
        web.title = title
        web.description = desc
        if let shareImage = thumbImage {
            // 多媒体内容中缩略图大小不能大于32K 例如：data.count=39805不能通过 31790就可以通过
            let imageData = ShareManager.scaleImageDataForSize(shareImage, limitDataSize: 32000);
            web.thumbnailData = imageData
        }
        message.mediaObject = web
        message.text = title
        return self.shareWBMessageObject(message)
    }
    
    fileprivate func shareWBMessageObject(_ message: WBMessageObject) -> Bool {
        
        let authRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        authRequest.redirectURI = "https://api.weibo.com/oauth2/default.html"
        authRequest.scope = "all";
        
        let request = WBSendMessageToWeiboRequest.request(withMessage: message, authInfo:authRequest,access_token: self.wbtoken) as! WBSendMessageToWeiboRequest
        
        request.userInfo = [
            "ShareMessageFrom" : "ViewController",
            "Other_Info_1":123,
            "Other_Info_2":["obj1","obj2"],
            "Other_Info_3":["key1":"obj1", "key2":"obj2"]]
        
        //   request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
        return WeiboSDK.send(request)
    }
    
}
