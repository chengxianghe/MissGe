//
//  AdvertiseView.h
//  zhibo
//
//  Created by 周焕强 on 16/5/17.
//  Copyright © 2016年 zhq. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const adImageName = @"adImageName";
static NSString *const adUrl = @"ad_image_url";
static NSString *const adImage = @"ad_image";
static NSString *const pushNotiName = @"push_to_root";

typedef void(^AdBlock)();

@interface AdvertiseView : UIView

/** 显示广告页面方法*/
- (void)show;

/** 图片路径*/
@property (nonatomic, copy) NSString *filePath;

- (void)setAdDismissBlock:(AdBlock)dismissBlock saveBlock:(AdBlock)saveBlock;

@end
