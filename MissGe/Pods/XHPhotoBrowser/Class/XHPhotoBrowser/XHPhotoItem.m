//
//  XHPhotoItem.m
//  YYKitDemo
//
//  Created by chengxianghe on 15/12/26.
//  Copyright © 2015年 ibireme. All rights reserved.
//

#import "XHPhotoItem.h"

@implementation XHPhotoItem

+ (BOOL)shouldClipToTopWithView:(UIView * _Nullable)view {
    if (view != nil) {
        if (view.layer.contentsRect.size.height < 1) {
            return YES;
        }
    }
    return NO;
}

- (UIImage *)thumbImage {
    if ([_thumbView respondsToSelector:@selector(image)]) {
        return [(UIImageView *)_thumbView image];
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    XHPhotoItem *item = [self.class new];
    return item;
}

@end
