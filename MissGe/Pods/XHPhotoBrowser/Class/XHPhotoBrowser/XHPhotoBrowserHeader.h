
#ifndef XHPhotoGroupHeader_h
#define XHPhotoGroupHeader_h

#import "UIView+XHAdd.h"

#if __has_include(<YYWebImage/YYWebImage.h>)
#import <YYWebImage/YYWebImage.h>
#else
@import YYWebImage;
#endif

#ifndef XH_CLAMP // return the clamped value
#define XH_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

#ifndef XH_SWAP // swap two value
#define XH_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif

/**
 Synthsize a weak or strong reference.
 
 Example:
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

// 屏幕大小
#ifndef kScreenSize
#define kScreenSize     [[UIScreen mainScreen] bounds].size
#endif

#ifndef kScreenWidth
#define kScreenWidth    [[UIScreen mainScreen] bounds].size.width
#endif

#ifndef kScreenHeight
#define kScreenHeight   [[UIScreen mainScreen] bounds].size.height
#endif

#ifndef kScreenOneScale
#define kScreenOneScale (1.0 / [UIScreen mainScreen].scale)
#endif

//#ifndef kStatusBarHeight
//#define kStatusBarHeight CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
//#endif


/* 屏幕尺寸判断 ===============================================================================*/
/** 判断是否为3.5inch 320*480 640*960 */
#ifndef kIs_Inch3_5
#define kIs_Inch3_5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#endif

/** 判断是否为4.0inch 320*568 640*1136 */
#ifndef kIs_Inch4_0
#define kIs_Inch4_0 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#endif
/** 判断是否为4.7inch 375*667 750*1334 */
#ifndef kIs_Inch4_7
#define kIs_Inch4_7 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#endif

/** 判断是否为5.5inch 414*1104 1242*2208 */
#ifndef kIs_Inch5_5
#define kIs_Inch5_5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#endif

///** 判断是否为X 5.8inch 375*812 1125*2436 */
//#ifndef kIs_Inch5_8
//#define kIs_Inch5_8 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
//#endif

/** 是否为iphoneX系列设备 判断是否为刘海屏 （x、xs)(2436 x 1125) xsmax(2688 x 1242) xr(1792 x 828) */
#ifndef kiPhoneX
#define kiPhoneX (kScreenHeight == 812 || kScreenWidth == 812 || kScreenHeight == 896 || kScreenWidth == 896)
#endif

//状态栏高度
#ifndef kStatusBarHeight
#define kStatusBarHeight (kiPhoneX ? 44.0f : 20.0f)
#endif

//顶部nav导航+状态条
#ifndef kNavBarHeight
#define kNavBarHeight (44 + kStatusBarHeight)
#endif

//底部tabbar高度
#ifndef kTabbarHeight
#define kTabbarHeight (kiPhoneX ? 83.0f : 49.0f)
#endif

/** iPhone X 默认的按钮边距 */
#ifndef k_IPhoneX_SafeWidth
#define k_IPhoneX_SafeWidth 44.0
#endif

/** iPhone X 默认的UITextView的文字内边距 */
#ifndef k_IPhoneX_TextDefaultInset
#define k_IPhoneX_TextDefaultInset 6.0
#endif

#endif /* XHPhotoGroupHeader_h */
