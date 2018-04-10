//
//  XHPhotoBrowserController.h
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/27.
//  Copyright © 2016年 cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHPhotoBrowser.h"

typedef void(^XHPhotoBrowserControllerOnMoreBlock)(void);

@interface XHPhotoBrowserController : UIViewController

@property (nonatomic, strong, readonly, nonnull) XHPhotoBrowser *browser;

/** 是否在viewDidload时加载图片浏览器(默认YES) */
@property (nonatomic, assign) BOOL showBrowserWhenDidload;

/** 一直显示状态栏(默认YES，横屏的时候跟随系统，推荐iPhone X上设置为YES) */
@property (nonatomic, assign) BOOL alwaysShowStatusBar;

/** 初始化数据 */
@property (nonatomic, strong, nullable) NSArray<__kindof id <XHPhotoProtocol>> *groupItems;

/** 初始化展示的第一页 */
@property (nonatomic, assign) NSInteger fromItemIndex;

/** 导航栏右侧图片 默认的是"•••" */
@property (nonatomic, strong, nullable) UIImage *rightImage;

/** 点击导航栏右侧更多 */
@property (nonatomic, copy, nullable) XHPhotoBrowserControllerOnMoreBlock moreBlock;


@end
