//
//  GMBLifeUploadHelper.m
//  GMBuy
//
//  Created by chengxianghe on 15/9/14.
//  Copyright (c) 2015年 cn. All rights reserved.
//

#import "GMBLifeUploadHelper.h"
#include <CommonCrypto/CommonCrypto.h>
#include <zlib.h>

#define MAX_IMAGEBYTES (1024.0*200)

@implementation GMBLifeUploadHelper

+ (NSData *)getUpLoadImageData:(UIImage *)originalImage {
    return [self getUpLoadImageData:originalImage withMaxDataSize:MAX_IMAGEBYTES];
}

+ (NSData *)getUpLoadImageData:(UIImage *)originalImage withMaxDataSize:(long long)maxSize {

    NSData *imageData = UIImageJPEGRepresentation(originalImage, 1);
    long long sizeB = imageData.length;

    // 对图片大小进行压缩--
    if(sizeB > maxSize) {
       float scale = ((float)maxSize) / sizeB;
//        // 对图片进行剪裁 这里可以设置统一规格
//        CGSize toSize = CGSizeMake(originalImage.size.width * 0.5, originalImage.size.height * 0.5);
//        UIImage *cutImage = [self scaleToSize:originalImage size:toSize];
//        imageData = UIImageJPEGRepresentation(cutImage, scale);
        
        //UIImageJPEGRepresentation方法比UIImagePNGRepresentation耗时短 而且文件更小
        imageData = UIImageJPEGRepresentation(originalImage, scale);
    }
    
    return imageData;
}

// 指定图片大小
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

// 临时保存图片
+ (NSString *)saveImage:(id)tempImage withName:(NSString *)imageName {
    
    NSData* imageData = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([tempImage isKindOfClass:[UIImage class]]) {
        //优先使用UIImageJPEGRepresentation
        imageData = UIImageJPEGRepresentation(tempImage, 1);
        if (imageData == nil) {
            imageData = UIImagePNGRepresentation(tempImage);
        }
    } else {
        imageData = tempImage;
    }
    if (imageData == nil) {
        return nil;
    }
    NSString* documentsDirectory = NSTemporaryDirectory();//[paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString* fullPathToFileFirst = [documentsDirectory stringByAppendingPathComponent:@"commentSizeImages"];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:fullPathToFileFirst isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:fullPathToFileFirst
               withIntermediateDirectories:YES
                                attributes:nil error:nil];
    }
    
    if (imageName == nil || imageName.length == 0) {
        imageName = [self md5StringWithData:imageData];
    }
    
    NSString* fullPathToFile = [fullPathToFileFirst stringByAppendingPathComponent:imageName];
    
    if([imageData writeToFile:fullPathToFile atomically:NO]) {
        return fullPathToFile;
    } else {
        return nil;
    }
}


+ (NSString *)md5StringWithData:(NSData *)data {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
