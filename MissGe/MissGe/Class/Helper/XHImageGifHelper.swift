//
//  XHImageGifHelper.swift
//  MissGe
//
//  Created by chengxianghe on 2017/5/18.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import AssetsLibrary
import Photos
import MobileCoreServices

typealias kGIFCheckClosure = (_ isGif: Bool, _ gifData: Data?) -> Void
typealias kGetImageDataClosure = (_ isGif: Bool, _ imageData: Data?, _ error: Error?) -> Void

class XHImageGifHelper {

    class func checkGIFWithAsset(asset: AnyObject, completion: kGIFCheckClosure?) {
        if let alAsset = asset as? ALAsset {
            let isGif = (alAsset.representation(forUTI: (kUTTypeGIF as String)) != nil)
            completion?(isGif, nil)
        } else if let phAsset = asset as? PHAsset {
            if #available(iOS 9.0, *) {
                let resourceList = PHAssetResource.assetResources(for: phAsset)
                var isGif = false
                for resource in resourceList.enumerated() {
                    if resource.element.uniformTypeIdentifier == (kUTTypeGIF as String) {
                        isGif = true
                        break
                    }
                }
                completion?(isGif, nil)
            } else {
                // Fallback on earlier versions
                let imageManager = PHCachingImageManager.init()
                let options = PHImageRequestOptions.init()
                options.resizeMode = .fast
                options.isSynchronous = true

                imageManager.requestImageData(for: phAsset, options: options, resultHandler: { (imageData, dataUTI, orientation, info) in
                    guard let uti = dataUTI else {
                        completion?(false, nil)
                        return
                    }
                    print("dataUTI:\(uti)")
                    //gif 图片
                    if (uti == (kUTTypeGIF as String)) {
                        //这里获取gif图片的NSData数据
                        completion?(true, imageData)
//                        let cache = (info?[PHImageCancelledKey] as! NSString).boolValue
//                        let error: NSError? = info?[PHImageErrorKey] as? NSError
//                        let downloadFinined = !cache && error == nil;
//                        
//                        if (downloadFinined && (imageData != nil)) {
//                            completion?(true, imageData!)
//                        } else {
//                            completion?(true, imageData)
//                        }
                    } else {
                        //其他格式的图片
                        completion?(false, imageData)
                    }
                })
            }
        }
    }

    private class func getGIFDataWithAsset(asset: AnyObject, completion: ((_ imageData: Data?, _ error: Error?) -> Void)?) {
        if let alAsset = asset as? ALAsset {
            let representation =  alAsset.defaultRepresentation()!
            let error = NSErrorPointer.init(nilLiteral: ())
            let imageBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(representation.size()))
            let bufferSize = representation.getBytes(imageBuffer, fromOffset: Int64(0),
                                                     length: Int(representation.size()), error: error)
            let imageData: NSData =  NSData(bytesNoCopy: imageBuffer, length: bufferSize, freeWhenDone: true)

            completion?(imageData as Data, error as? Error)

        } else if let phAsset = asset as? PHAsset {
            let imageManager = PHCachingImageManager.init()
            let options = PHImageRequestOptions.init()
            options.resizeMode = .fast
            options.isSynchronous = true

            imageManager.requestImageData(for: phAsset, options: options, resultHandler: { (imageData, dataUTI, orientation, info) in
                print("dataUTI:\(String(describing: dataUTI))")
                completion?(imageData, info?[PHImageErrorKey] as? Error)
            })
        }
    }

    /// 获取图片ALAsset/PHAsset的图片data 兼容gif
    ///
    /// - Parameters:
    ///   - asset: ALAsset/PHAsset
    ///   - completion: isGif imageData error
    class func getImageDataWithAsset(asset: AnyObject, completion: kGetImageDataClosure?) {
        self.checkGIFWithAsset(asset: asset) { (isGif, gifData) in
            if gifData != nil {
                completion?(isGif, gifData, nil)
            } else {
                self.getGIFDataWithAsset(asset: asset, completion: { (imageData: Data?, error: Error?) in
                    completion?(isGif, imageData, error)
                })
            }
        }
    }

}
