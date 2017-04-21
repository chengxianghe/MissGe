//
//  QQShareHelp.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/6.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class QQShareHelp: NSObject {

    static let instance = QQShareHelp()
    class func currentHelp() -> QQShareHelp {
        return instance
    }
    
    func checkQQClient() -> Bool {
        if QQApiInterface.isQQInstalled() == false {
            
            print("抱歉,您没有安装QQ")
            return false;
        }
        
        if QQApiInterface.isQQSupportApi() == false {
            print("请下载最新的QQ")
            return false;
        }
        
        return true
    }
    
    /*!
    *    @分享到qq空间
    *
    *    @brief  分享QQ空间文字，图片，链接
    *
    *    @param text        标题
    *    @param description 副标题
    *    @param image       图片
    *    @param url         链接
    *
    *    @since 1.0
    */
    func sendLinkUrlToQZone(_ text: String, description: String, imageUrl: String, url: String) -> Bool {
        if !self.checkQQClient() {
            return false;
        }
        
        let newsObj = QQApiNewsObject.object(with: URL(string: url), title: text, description: description, previewImageURL: URL(string: imageUrl)) as? QQApiNewsObject
        
        if newsObj == nil {
            return false
        }
        
        let req = SendMessageToQQReq(content: newsObj!)
        let sentCode = QQApiInterface.sendReq(toQZone: req)
        print("将内容分享到qq空间: \(sentCode)")
        return sentCode == EQQAPISENDSUCESS;
    }
    
    func sendLinkUrl(_ text: String, description: String, imageUrl: String, url: String) -> Bool {
        if !self.checkQQClient() {
            return false;
        }
        
        let newsObj = QQApiNewsObject.object(with: URL(string: url), title: text, description: description, previewImageURL: URL(string: imageUrl)) as? QQApiNewsObject

        if newsObj == nil {
            return false
        }
        
        let req = SendMessageToQQReq(content: newsObj!)
        let sentCode = QQApiInterface.send(req)
        print("将内容分享到qq: \(sentCode)")
        return sentCode == EQQAPISENDSUCESS;
    }
    
    /**
     <具体数据内容，必填，最大5M字节
     <预览图像，最大1M字节
     */
    func sendImage(_ image: UIImage?, title: String, desc: String) -> Bool {
        if !self.checkQQClient() {
            return false;
        }
        
        if image == nil {
            return false
        }
        
        // 原图 最大5M字节
        let imageData = ShareManager.scaleImageDataForSize(image!, limitDataSize: 5000000);
        print(imageData?.count ?? 0)
        
        // 预览图像，最大1M字节
        let previewImageData = ShareManager.scaleImageDataForSize(image!, limitDataSize: 1000000);
        print(previewImageData?.count ?? 0)
        
        let imgObj = QQApiImageObject.init(data: imageData, previewImageData: previewImageData, title: title, description: desc)
        
        let req = SendMessageToQQReq.init(content: imgObj);
        
        let sentCode = QQApiInterface.send(req);
        
        print("将图片分享到qq: \(sentCode)")
        return sentCode == EQQAPISENDSUCESS;
    }
}
