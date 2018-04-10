//
//  PhotoAlbumHelper.swift
//  HuaBanNew
//
//  Created by chengxianghe on 16/6/13.
//  Copyright © 2016年 CXH. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary

//操作结果枚举
enum PhotoAlbumHelperResult {
    case success, error, denied
}

typealias PhotoSaveBlock = (_ result: PhotoAlbumHelperResult, _ error: NSError?) -> Void

//相册操作工具类
@available(iOS 8.0, *)
class PhotoAlbumHelper: NSObject {

    /**
     请求授权
     */
    class func requestAuthorization(_ handler: ((PHAuthorizationStatus) -> Void)?) {
        PHPhotoLibrary.requestAuthorization { (status) in
            handler?(status)
        }
    }

    /**
     保存图片到相册 相册名默认为空 保存在系统相册
     
     - parameter image:      图片
     - parameter albumName:  相册名
     - parameter completion: completion
     */
    class func saveImageToAlbum(_ image: UIImage, albumName: String = "", completion: ((_ result: PhotoAlbumHelperResult, _ error: NSError?) -> Void)?) {

        //权限验证
        self.requestAuthorization { (status) in
            if status != PHAuthorizationStatus.authorized {
                completion?(.denied, nil)
                return
            } else {
                if albumName.isEmpty {
                    self.saveImageToCameraAlbum(image, completion: completion)
                } else {
                    self.getAlbum(albumName) { (assetAlbum) in
                        self.saveImage(image, to: assetAlbum, completion: completion)
                    }
                }
            }
        }
    }

    // OC调用
    class func saveVideoToAlbum(_ videoFileURL: URL, albumName: String = "", completion: ((_ result: Bool, _ error: NSError?) -> Void)?) {
        self.saveVideo(videoFileURL, to: albumName) { (result, error) in
            if result == PhotoAlbumHelperResult.error || result == PhotoAlbumHelperResult.denied {
                completion?(false, error)
            } else {
                completion?(true, error)
            }
        }
    }

    class func saveVideo(_ videoFileURL: URL, to albumName: String = "", completion: ((_ result: PhotoAlbumHelperResult, _ error: NSError?) -> Void)?) {
        //权限验证
        self.requestAuthorization { (status) in
            if status != PHAuthorizationStatus.authorized {
                completion?(.denied, nil)
                return
            } else {
                if albumName.isEmpty {
                    self.saveVideoToCameraAlbum(videoFileURL, completion: completion)
                } else {
                    self.getAlbum(albumName) { (assetAlbum) in
                        self.saveVideo(videoFileURL, to: assetAlbum, completion: completion)
                    }
                }
            }
        }
    }

    class func getAlbum(_ albumName: String = "", handler: ((PHAssetCollection?) -> Void)?) {
        var assetAlbum: PHAssetCollection?

        //如果指定的相册名称为空，则返回相机胶卷。（否则返回指定相册）
        if albumName.isEmpty {
            let list = PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            assetAlbum = list.firstObject
            handler?(assetAlbum)
        } else {
            //看保存的指定相册是否存在
            let list = PHAssetCollection
                .fetchAssetCollections(with: .album, subtype: .any, options: nil)

            list.enumerateObjects({ (album, index, isStop) in
                let assetCollection = album
                if albumName == assetCollection.localizedTitle {
                    assetAlbum = assetCollection
                    isStop.pointee = true
                    handler?(assetAlbum)
                }
            })

            //不存在的话则创建该相册
            if assetAlbum == nil {
                var assetAlbumId: String?
                PHPhotoLibrary.shared().performChanges({
                    let assetRequest = PHAssetCollectionChangeRequest
                        .creationRequestForAssetCollection(withTitle: albumName)
                    assetAlbumId = assetRequest.placeholderForCreatedAssetCollection.localIdentifier

                    print(assetRequest, assetAlbumId ?? "")
                    }, completionHandler: { (isSuccess, error) in
                        //看保存的指定相册是否存在
                        if isSuccess && assetAlbumId != nil {
                            assetAlbum = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetAlbumId!], options: nil).firstObject! as PHAssetCollection
                        }

                        handler?(assetAlbum)
                })
            }
        }
    }

    /// 保存图片到系统相册
    fileprivate class func saveImageToCameraAlbum(_ image: UIImage, completion: PhotoSaveBlock?) {
//        var assetId: String?;
        // 1. 存储图片到"相机胶卷"
        PHPhotoLibrary.shared().performChanges({ // 这个block里保存一些"修改"性质的代码
            // 返回PHAsset(图片)的字符串标识
            _ = PHAssetChangeRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset?.localIdentifier

            }, completionHandler: { (isSuccess, error) in
                if (error != nil) {
                    completion?(.error, error as NSError?)
                } else {
                    completion?(.success, nil)
                }
        })

    }

    /// 保存图片到自定义相册
    fileprivate class func saveImage(_ image: UIImage, to assetAlbum: PHAssetCollection?, completion: PhotoSaveBlock?) {
        //保存图片
        PHPhotoLibrary.shared().performChanges({
            //添加的相机胶卷
            let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
            //是否要添加到相簿
            if assetAlbum != nil {
                let assetPlaceholder = result.placeholderForCreatedAsset
                let albumChangeRequset = PHAssetCollectionChangeRequest(for:
                    assetAlbum!)

                albumChangeRequset!.addAssets([assetPlaceholder!] as NSFastEnumeration)
            }
            }, completionHandler: { (isSuccess: Bool, error: Error?) in
                DispatchQueue.main.async(execute: {
                    //这里返回主线程，写需要主线程执行的代码
                    if isSuccess {
                        completion?(.success, nil)
                    } else {
                        print(error!.localizedDescription)
                        completion?(.error, error as NSError?)
                    }
                })
        })
    }

    /// 保存视频到系统相册
    fileprivate class func saveVideoToCameraAlbum(_ videoFileURL: URL, completion: PhotoSaveBlock?) {
//        var assetId: String?;
        // 1. 存储图片到"相机胶卷"
        PHPhotoLibrary.shared().performChanges({ // 这个block里保存一些"修改"性质的代码
            // 返回PHAsset(图片)的字符串标识
            _ = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoFileURL)?.placeholderForCreatedAsset?.localIdentifier

            }, completionHandler: { (isSuccess, error) in
                if (error != nil) {
                    completion?(.error, error as NSError?)
                } else {
                    completion?(.success, nil)
                }
        })

    }

    /// 保存视频到自定义相册
    fileprivate class func saveVideo(_ videoFileURL: URL, to assetAlbum: PHAssetCollection?, completion: PhotoSaveBlock?) {
        //保存视频
        PHPhotoLibrary.shared().performChanges({
            //添加的相机胶卷
            let result = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoFileURL)

            if result == nil {
                completion?(.error, NSError(domain: "获取视频资源失败", code: -1, userInfo: nil))
                return
            }
            //是否要添加到相簿
            if assetAlbum != nil {
                let assetPlaceholder = result!.placeholderForCreatedAsset
                let albumChangeRequset = PHAssetCollectionChangeRequest(for:
                    assetAlbum!)
                albumChangeRequset!.addAssets([assetPlaceholder!].enumerated() as! NSFastEnumeration)
            }
            }, completionHandler: { (isSuccess: Bool, error: Error?) in
                DispatchQueue.main.async(execute: {
                    //这里返回主线程，写需要主线程执行的代码
                    if isSuccess {
                        completion?(.success, nil)
                    } else {
                        print(error!.localizedDescription)
                        completion?(.error, error as NSError?)
                    }
                })
        })
    }
}
