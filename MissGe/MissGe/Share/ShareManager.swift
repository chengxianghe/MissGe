//
//  ShareManager.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/6.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

enum ShareType: Int {
    case
    weiBoShare = 0, //分享到新浪微博
    weiXinFriendsShare,    //分享到微信朋友圈
    weiXinShare,      //分享到微信好友
    weiXinFavoriteShare,  //分享到微信收藏
    qZoneShare,  //分享到QQ空间
    qqShare       //分享到QQ
}

class ShareManager: NSObject, UITableViewDelegate {

    typealias ShareToThirdWithTypeBlock = ((_ type: ShareType) -> Void)

    var shareView: UIView?;//分享具体UI视图
    var backView: UIView?  //背景黑色蒙层
    var targetView: UIView?;  //目标view
    var shareBlock: ShareToThirdWithTypeBlock?

    /**
     *  分享管理工具
     */
    static let instance = ShareManager()
    class func manager() -> ShareManager {
        return instance
    }

    /**
    *  创建一个可视化分享视图
    */
    fileprivate func createShareView() {
        if self.shareView == nil {
            shareView = UIView(frame: CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: 300*kScreenWidth/320))
            shareView!.backgroundColor = kRGBA(231, g: 231, b: 231, a: 0.95)

            let tipLab = UILabel(frame: CGRect(x: 0, y: 18, width: kScreenWidth, height: 12))
            tipLab.text = "分享到"
            tipLab.backgroundColor = UIColor.clear
            tipLab.textColor = UIColor(hex6: 0x666666, alpha: 1)
            tipLab.font = UIFont.systemFont(ofSize: 14)
            tipLab.textAlignment = NSTextAlignment.center
            shareView!.addSubview(tipLab)

            /*
            shareIconWeibo
            shareIconQzone
            shareIconTcweibo
            
            */
            let titleArr = ["新浪微博", "朋友圈", "微信", "微信收藏", "QQ空间", "QQ"]
            let imageArr = ["share_weibo", "share_friends", "share_weixin", "share_weixin_favorite", "share_zone", "share_qq"]

            var radius = 60*kScreenHeight/560

            if (kScreenWidth>375) {
                radius = 80
            }
            let distance = (kScreenWidth - 36 - radius * 4)/3

            for i in 0 ..< titleArr.count {
                let btn = UIButton()
                btn.frame = CGRect(x: 18 + CGFloat(i%4)*(distance + radius), y: 60 + CGFloat(i/4)*(radius + 52), width: radius, height: radius)
                btn.setImage(UIImage(named: imageArr[i]), for: UIControlState())
                btn.addTarget(self, action: #selector(ShareManager.shareBtClicked(_:)), for: UIControlEvents.touchUpInside)
                shareView!.addSubview(btn)
                btn.tag = 2000+i

                let lab = UILabel(frame: CGRect(x: btn.frame.origin.x, y: btn.frame.origin.y + radius + 5, width: btn.frame.size.width, height: 12))
                lab.text = titleArr[i]
                lab.textColor = UIColor.lightGray
                lab.textAlignment = NSTextAlignment.center
                lab.font = UIFont.systemFont(ofSize: 12)
                shareView!.addSubview(lab)
            }

            let cancelBtn = UIButton()
            cancelBtn.frame = CGRect(x: 0, y: shareView!.frame.size.height - 50, width: kScreenWidth, height: 50)
            cancelBtn.setTitle("取 消", for: UIControlState())
            cancelBtn.titleLabel!.font = UIFont.systemFont(ofSize: 18)
            cancelBtn.titleLabel!.textColor = UIColor(hex6: 0x333333, alpha: 1)
            cancelBtn.setTitleColor(UIColor.darkGray, for: UIControlState())
            cancelBtn.backgroundColor = UIColor.white
            cancelBtn.addTarget(self, action: #selector(ShareManager.tapHideShareView), for: UIControlEvents.touchUpInside)
            shareView!.addSubview(cancelBtn)

            self.backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
            backView!.backgroundColor = UIColor.black
            backView!.alpha = 0

            let gesture = UITapGestureRecognizer(target: self, action: #selector(ShareManager.tapHideShareView))
            self.backView!.addGestureRecognizer(gesture)
        }
    }

    /**
    *  显示分享视图
    */
    func showShareViewWithBlock(_ block: ShareToThirdWithTypeBlock?) {
        self.shareBlock = block

        if (shareView == nil) {
            self.createShareView()
        }

        let window = UIApplication.shared.keyWindow
        window?.addSubview(backView!)
        window?.addSubview(shareView!)

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.shareView!.frame = CGRect(x: 0, y: kScreenHeight - self.shareView!.frame.size.height, width: kScreenWidth, height: self.shareView!.frame.size.height)
            self.backView!.alpha = 0.4

            }, completion: { (finished) -> Void in

        })
    }

    /**
    *  隐藏分享视图
    */
    func hideShareView(_ completion: ((Bool) -> Void)? = nil) {

        UIView.animate(withDuration: 0.3, animations: { () -> Void in

            self.shareView!.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: self.shareView!.frame.size.height)
            self.backView!.alpha = 0

            }, completion: {(finished) -> Void in
                self.backView?.removeFromSuperview()
                completion?(finished)
        })
    }

    // 不能直接selector调用 会默认传参...
    @objc func tapHideShareView() {
        self.hideShareView()
    }

    @objc func shareBtClicked(_ btn: UIButton) {
        self.hideShareView { (finished) in
            self.shareBlock?(ShareType(rawValue: btn.tag - 2000)!)
        }
    }
}

extension ShareManager {
    static func imageCenterImage(_ image: UIImage?) -> UIImage? {
        if image == nil {
            return nil
        }

        // new size
        let readio = image!.size.width/image!.size.height
        var frame = CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height)
        if readio >= 1.0 {// 宽的
            frame.origin.x = (image!.size.width - image!.size.height)/2.0
            frame.size.width = frame.size.height
        } else {// 高的
            frame.origin.y = (image!.size.height - image!.size.width)/2.0
            frame.size.height = frame.size.width
        }

        // Return the new image.
        let newImage = self.imageFromImage(image!, inRect: frame)

        return newImage

    }

    //对图片尺寸进行压缩--
    static func imageWithImage(_ image: UIImage?, scaledToSize newSize: CGSize) -> UIImage? {
        if image == nil {
            return nil
        }
        // Create a graphics image context
        UIGraphicsBeginImageContext(newSize)

        // Tell the old image to draw in this new context, with the desired
        image!.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))

        // Get the new image from the context
        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        // End the context
        UIGraphicsEndImageContext()

        // Return the new image.
        return newImage

    }

    /*!
     *
     *  压缩图片至目标尺寸
     *
     *  @param sourceImage 源图片
     *  @param targetWidth 图片最终尺寸的宽
     *
     *  @return 返回按照源图片的宽、高比例压缩至目标宽、高的图片
     */
    static func compressImage(_ image: UIImage?, toTargetWidth targetWidth: CGFloat) -> UIImage? {
        if image == nil {
            return nil
        }
        let imageSize = image!.size

        let width = imageSize.width
        let height = imageSize.height

        let targetHeight = (targetWidth / width) * height

        UIGraphicsBeginImageContext(CGSize(width: targetWidth, height: targetHeight))
        image!.draw(in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    static func scaleImageDataForSize(_ image: UIImage, limitDataSize: UInt) -> Data? {
        var imageData = UIImageJPEGRepresentation(image, 1.0)
        if imageData?.count == nil {
            return nil
        }

        if UInt(imageData!.count) > limitDataSize {
            imageData = UIImageJPEGRepresentation(image, 0.8)
            if UInt(imageData!.count) > limitDataSize {
                imageData = UIImageJPEGRepresentation(image, 0.5)
                var imageWidth = image.size.width
                while UInt(imageData!.count) > limitDataSize {
                    imageWidth = imageWidth * 0.5
                    let tempImage = self.compressImage(image, toTargetWidth: imageWidth)
                    imageData = UIImageJPEGRepresentation(tempImage!, 0.5)
                }
            }
        }
        return imageData
    }

    /**
     *从图片中按指定的位置大小截取图片的一部分
     * UIImage image 原始的图片
     * CGRect rect 要截取的区域
     */
    static func imageFromImage(_ image: UIImage, inRect rect: CGRect) -> UIImage {
        let sourceImageRef = image.cgImage
        let newImageRef = sourceImageRef?.cropping(to: rect)
        let newImage = UIImage(cgImage: newImageRef!)
        return newImage
    }
}
