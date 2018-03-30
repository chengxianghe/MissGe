//
//  XHImageCompressHelper.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/25.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation

class XHImageCompressHelper {
    /**
     *  根据一张原图返回一张上传规格的图片Data
     *
     *  @param originalImage 原图
     *  @param maxSize       默认限制大小200k
     *
     *  @return 图片Data
     */
    class func getUpLoadImageData(originalImage: UIImage, isOriginalPhoto: Bool, MaxDataSize maxSize: UInt = 200 * 1024) -> Data? {

        guard let imageData = UIImageJPEGRepresentation(originalImage, 1) else {
            return nil
        }

        if isOriginalPhoto {
            return imageData
        }

        let sizeB = UInt(imageData.count)

        var data = imageData

        // 对图片大小进行压缩--
        if sizeB > maxSize {
            let scale = CGFloat(maxSize) / CGFloat(sizeB)

            //        // 对图片进行剪裁 这里可以设置统一规格
            //        CGSize toSize = CGSizeMake(originalImage.size.width * 0.5, originalImage.size.height * 0.5);
            //        UIImage *cutImage = [self scaleToSize:originalImage size:toSize];
            //        imageData = UIImageJPEGRepresentation(cutImage, scale);

            //UIImageJPEGRepresentation方法比UIImagePNGRepresentation耗时短 而且文件更小
            if let tempData = UIImageJPEGRepresentation(originalImage, scale) {
                data = tempData
            }
        }

        return data
    }

    /**
     *  指定图片大小
     *
     *  @param originalImage  图片
     *  @param size 指定的大小
     *
     *  @return 缩放过的图片
     */
    static func scale(originalImage: UIImage, toSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        originalImage.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

    /**
     *  临时存储一张图片
     *
     *  @param tempImage 图片
     *  @param imageName 图片名称
     *
     *  @return 存储完整路径
     */
    static func save(image tempImage: UIImage, withName imageName: String) -> String? {
        var imageData: Data? = nil

        //优先使用UIImageJPEGRepresentation
        imageData = UIImageJPEGRepresentation(tempImage, 1)
        if (imageData == nil) {
            imageData = UIImagePNGRepresentation(tempImage)
        }

        if (imageData == nil) {
            return nil
        }

        return self.save(imageData: imageData!, withName: imageName)
    }

    static func save(imageData: Data, withName imageName: String) -> String? {
        let fileManager = FileManager.default

        let documentsDirectory = NSTemporaryDirectory();//[paths objectAtIndex:0]; 包含了'/'
        // Now we get the full path to the file

        let fullPathToFileFirst = documentsDirectory.appendingFormat("%@", documentsDirectory.hasSuffix("/") ? "commentSizeImages" : "/commentSizeImages", "commentSizeImages")

        var isDir: ObjCBool = false
        let existed = fileManager.fileExists(atPath: fullPathToFileFirst, isDirectory: &isDir)

        if !(isDir.boolValue && existed) {
            try? fileManager.createDirectory(atPath: fullPathToFileFirst, withIntermediateDirectories: true, attributes: nil)
        }

        let fullPathToFile = fullPathToFileFirst.appendingFormat("/%@", imageName)

        do {
            try imageData.write(to: URL.init(fileURLWithPath: fullPathToFile), options: [])
            return fullPathToFile
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
}
