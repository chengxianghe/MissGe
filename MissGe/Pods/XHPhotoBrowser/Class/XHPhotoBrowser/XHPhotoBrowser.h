//
//  YYPhotoGroupView.h
//  YYKitDemo
//
//  Created by chengxianghe on 15/12/26.
//  Copyright © 2015年 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHPhotoItem.h"
#import "XHPageControlView.h"

NS_ASSUME_NONNULL_BEGIN

@class XHPhotoBrowser;

/// toolBar的展示风格
typedef NS_ENUM(NSUInteger, XHShowStyle) {
    XHShowStyleAuto, ///< 自动
    XHShowStyleHide, ///< 隐藏
    XHShowStyleShow, ///< 展示
};

/// 单击图片的处理
typedef NS_ENUM(NSUInteger, XHSingleTapOption) {
    XHSingleTapOptionNone, ///< 单击不做相册退出处理, 默认显示/隐藏caption和工具条
    XHSingleTapOptionAuto, ///< 自动(有caption时单击显示/隐藏caption和工具条, 没有caption时单击退出相册)
    XHSingleTapOptionDismiss, ///< 不管有无caption, 单击均退出相册
};

@protocol XHPhotoBrowserDataSource <NSObject>

@required

/**
 *  提供图片item的总数量
 *
 *  @return NSInteger
 */
- (NSInteger)xh_numberOfImagesInPhotoBrowser:(XHPhotoBrowser * _Nonnull)photoBrowser;

/**
 *  提供对应index的item
 *
 *  @param index 图片item所在的index
 *
 *  @return id <XHPhotoProtocol>
 */
- (id <XHPhotoProtocol> _Nonnull)xh_photoBrowser:(XHPhotoBrowser * _Nonnull)photoBrowser photoAtIndex:(NSInteger)index;

@end

@protocol XHPhotoBrowserDelegate <NSObject>

@optional

/**
 *  展示相册(单次触发 只在初始化完相册准备展示的时候触发)
 */
- (void)xh_photoBrowserWillMoveToSuperView:(XHPhotoBrowser * _Nonnull)photoBrowser;

/**
 *  退出相册(单次触发 只在相册准备从父View移除的时候触发)
 */
- (void)xh_photoBrowserWillRemoveFromSuperView:(XHPhotoBrowser * _Nonnull)photoBrowser;

/**
 *  相册正在展示的index和fromIndex
 *
 *  @param photoBrowser photoBrowser
 *  @param index        当前展示的index
 *  @param fromIndex    上一次展示的index(没有上一次时, fromIndex == NSNotFound)
 */
- (void)xh_photoBrowser:(XHPhotoBrowser * _Nonnull)photoBrowser didDisplayingImageAtIndex:(NSInteger)index fromIndex:(NSInteger)fromIndex;

/**
 *  点击删除按钮的回调
 *
 *  @param photoBrowser photoBrowser
 *  @param index        当前图片的index
 *  @param deleteBlock  删除操作的闭包(更新内部UI)
 */
- (void)xh_photoBrowserDidTapDelete:(XHPhotoBrowser * _Nonnull)photoBrowser photoAtIndex:(NSInteger)index deleteBlock:(void(^)(void))deleteBlock;

/**
 *  单击相册图片的回调
 */
- (void)xh_photoBrowserSingleTap:(XHPhotoBrowser * _Nonnull)photoBrowser;

/**
 *  相册进行屏幕旋转完的回调
 */
- (void)xh_photoBrowserDidOrientationChange:(XHPhotoBrowser * _Nonnull)photoBrowser;


//------------------------------------------------------------------------------

/**
 *  将要展示相册(会多次触发: 上下滑动消失->将要展示的时候; 初次将要展示的时候)
 */
- (void)xh_photoBrowserWillDisplay:(XHPhotoBrowser * _Nonnull)photoBrowser;

/**
 *  已经展示相册(会多次触发: 上下滑动消失->展示的时候; 初次展示的时候)
 */
- (void)xh_photoBrowserDidDisplay:(XHPhotoBrowser * _Nonnull)photoBrowser;

/**
 *  将要退出相册(会多次触发: 上下滑动将要消失的时候; 单击相册将要退出的时候;)
 */
- (void)xh_photoBrowserWillDismiss:(XHPhotoBrowser * _Nonnull)photoBrowser;

/**
 *  已经退出相册(会多次触发: 上下滑动消失的时候; 单击相册退出的时候;)
 */
- (void)xh_photoBrowserDidDismiss:(XHPhotoBrowser * _Nonnull)photoBrowser;

@end

/// Used to show a group of images.
@interface XHPhotoBrowser : UIView

@property (nonatomic, weak, nullable) id <XHPhotoBrowserDataSource> dataSource;
@property (nonatomic, weak, nullable) id <XHPhotoBrowserDelegate> delegate;

@property (nonatomic, readonly, nullable) NSArray<__kindof id <XHPhotoProtocol>> *groupItems;
@property (nonatomic, readonly) NSInteger currentPage;


#pragma mark - 可配置属性

/**
 *  初始化展示的第一页
 */
@property (nonatomic, assign) NSInteger fromItemIndex;

/**
 *  展示图片下标的PageControlView
 */
@property (nonatomic, strong, readonly) XHPageControlView *pager;

/**
 *  是否需要模糊背景(Default is YES)
 */
@property (nonatomic, assign) BOOL blurEffectBackground;

/**
 *  工具条显示样式(Default is Auto)
 */
@property (nonatomic, assign) XHShowStyle toolBarShowStyle;

/**
 *  是否在翻页时强制显示toolBar(Default is YES)
 */
@property (nonatomic, assign) BOOL showToolBarWhenScroll;

/**
 *  是否在翻页时强制显示caption(Default is YES)
 */
@property (nonatomic, assign) BOOL showCaptionWhenScroll;

/**
 *  是否上下滑动消失(Default is YES)
 */
@property (nonatomic, assign) BOOL upDownDismiss;

/**
 *  单击图片时的选项(Default is Auto)
 */
@property (nonatomic, assign) XHSingleTapOption singleTapOption;

/**
 *  thumbView是否是cell(Default is NO)
 *  当thumbView是tableView的cell,或者是collectionView的cell的时候需要设置为YES
 */
@property (nonatomic, assign) BOOL thumbViewIsCell;

/**
 *  默认是否展示删除按钮(Default is NO)
 */
@property (nonatomic, assign) BOOL showDeleteButton;

/**
 *  默认是否展示关闭按钮(Default is YES)
 *  当 'caption.length > 0' 的时候 单击会 '显示/隐藏' caption, 这个时候可以通过关闭按钮退出相册
 */
@property (nonatomic, assign) BOOL showCloseButton;

/**
 *  默认的图片间距(Default is 20)
 */
@property (nonatomic, assign) CGFloat imagePadding;

/**
 *  当 'thumbView.superView 是 scrollView' 的时候, 需要设置这个值修正 '打开/关闭' 的动画
 */
@property (nonatomic, assign) CGFloat contentOffSetY;

/**
 *  默认最大的captionView的高度(Default is 150)
 */
@property (nonatomic, assign) CGFloat maxCaptionHeight;

/**
 *  是否正在展示Browser
 */
@property (nonatomic, assign, readonly) BOOL isPresented;

/**
 *  适配iPhone X 是否全屏展示（包含安全区域，只在iPhone X上生效）默认 YES
 */
@property (nonatomic, assign) BOOL isFullScreen;

/**
 *  适配iPhone X 是否全屏展示按钮文字（包含安全区域，只在iPhone X上生效）默认 NO
 */
@property (nonatomic, assign) BOOL isFullScreenWord;

#pragma mark - 初始化

//- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;

/**
 *  初始化
 *  该初始化不需要设置delegate和dataSource,一般简单使用
 *  如果使用该初始化方法,同时设置了dataSource,以dataSource返回的数据为准
 *
 *  @return XHPhotoBrowser
 */
- (instancetype)initWithGroupItems:(NSArray<__kindof id <XHPhotoProtocol>> *)groupItems;

/**
 *  展示
 *
 *  @param container   展示的容器
 *  @param currentPage 展示的初始页面
 *  @param animated    是否需要动画
 *  @param completion  完成的回调
 */
- (void)showInContaioner:(UIView * _Nonnull)container
                animated:(BOOL)animated
              completion:(nullable void (^)(void))completion;

/**
 *  退出
 *
 *  @param animated   是否需要动画
 *  @param completion 完成的回调
 */
- (void)dismissAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;


#pragma mark - 刷新数据

/**
 *  刷新数据只有当设置了dataSource才有作用
 *  数据会清空重新加载
 */
- (void)reloadData;

/**
 *  刷新部分数据
 */
- (void)reloadDataInRange:(NSRange)range;

@end
NS_ASSUME_NONNULL_END
