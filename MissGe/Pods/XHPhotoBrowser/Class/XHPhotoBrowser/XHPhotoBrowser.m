//
//  YYPhotoGroupView.m
//  YYKitDemo
//
//  Created by chengxianghe on 15/12/26.
//  Copyright © 2015年 ibireme. All rights reserved.
//

#import "XHPhotoBrowser.h"
#import "XHPhotoBrowserHeader.h"
#import "XHPhotoItem.h"
#import "XHPhotoBrowserCell.h"
#import "XHPageControlView.h"
#import <Accelerate/Accelerate.h>

@interface XHPhotoBrowser() <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic,   weak) UIView *fromView;
@property (nonatomic,   weak) UIView *toContainerView;

@property (nonatomic, strong) UIView *blurBackground;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<__kindof XHPhotoBrowserCell *> *cells;
@property (nonatomic, strong) XHPageControlView *pager;
@property (nonatomic, assign) BOOL fromNavigationBarHidden;

@property (nonatomic, assign) BOOL isPresented;
@property (nonatomic, assign) BOOL isLongPressed;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint panGestureBeginPoint;

@property (nonatomic, assign) BOOL isOrientationChange;

@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *toolPreviousButton;
@property (nonatomic, strong) UIBarButtonItem *toolActionButton;
@property (nonatomic, strong) UIBarButtonItem *toolNextButton;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) CGRect closeButtonShowFrame;
@property (nonatomic, assign) CGRect closeButtonHideFrame;

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, assign) CGRect deleteButtonShowFrame;
@property (nonatomic, assign) CGRect deleteButtonHideFrame;

@property (nonatomic, strong) UITextView *captionView;

@end


@implementation UIImage (XHPhotoBrowser)

+ (UIImage *)xh_imageNamedFromMyBundle:(NSString *)name {
    UIImage *image = [UIImage imageNamed:[@"XHPhotoBrowser.bundle" stringByAppendingPathComponent:name]];
    if (image) {
        return image;
    } else {
        image = [UIImage imageNamed:[@"Frameworks/XHPhotoBrowser.framework/XHPhotoBrowser.bundle" stringByAppendingPathComponent:name]];
        return image;
    }
}

@end

@implementation XHPhotoBrowser

- (void)dealloc {
    [_cells removeAllObjects];
    _groupItems = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithGroupItems:(NSArray<__kindof id<XHPhotoProtocol>> *)groupItems {
    self = [super init];
    if (self) {
        if (groupItems.count == 0) return nil;
        [self setupSubviews];
        _groupItems = [NSMutableArray arrayWithArray:groupItems];
    }
    return self;
}

- (void)setupSubviews {
    // 适配屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:)name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    _blurEffectBackground = YES;
    _upDownDismiss = YES;
    _thumbViewIsCell = NO;
    _showDeleteButton = NO;
    _showCloseButton = YES;
    _toolBarShowStyle = XHShowStyleAuto;
    _showToolBarWhenScroll = YES;
    _showCaptionWhenScroll = YES;
    _singleTapOption = XHSingleTapOptionAuto;
    _imagePadding = 20;
    _maxCaptionHeight = 150;
    
    self.backgroundColor = [UIColor clearColor];
    self.frame = [UIScreen mainScreen].bounds;
    self.clipsToBounds = YES;
    
    _cells = @[].mutableCopy;
    
    _blurBackground = UIView.new;
    _blurBackground.userInteractionEnabled = NO;
    _blurBackground.frame = self.bounds;
    _blurBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _contentView = UIView.new;
    _contentView.frame = self.bounds;
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _scrollView = UIScrollView.new;
    _scrollView.frame = CGRectMake(-_imagePadding / 2, 0, self.xh_width + _imagePadding, self.xh_height);
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    //    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delaysContentTouches = NO;
    _scrollView.canCancelContentTouches = YES;
    
    
    // toolbar
    _toolBar = [[UIToolbar alloc] init];
    _toolBar.xh_width = self.xh_width;
    _toolBar.xh_height = 40;
    _toolBar.center = CGPointMake(self.xh_width / 2, self.xh_height - 20);
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    _toolBar.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    _toolBar.clipsToBounds = true;
    _toolBar.translucent = true;
    [_toolBar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    _pager = [[XHPageControlView alloc] init];
    _pager.hidesForSinglePage = NO;
    _pager.userInteractionEnabled = NO;
    _pager.xh_width = 100;
    _pager.xh_height = 20;
    _pager.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    
    // arrows:back
    UIButton *previousBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *previousImage = [UIImage xh_imageNamedFromMyBundle:@"images/btn_common_back_wh"];
    previousBtn.frame = CGRectMake(0, 0, 44, 44);
    previousBtn.imageEdgeInsets = UIEdgeInsetsMake(13.25, 17.25, 13.25, 17.25);
    [previousBtn setImage:previousImage forState:UIControlStateNormal];
    [previousBtn addTarget:self action:@selector(gotoPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    previousBtn.contentMode = UIViewContentModeCenter;
    _toolPreviousButton = [[UIBarButtonItem alloc] initWithCustomView:previousBtn];
    _toolPreviousButton.style = UIBarButtonItemStylePlain;
    
    // arrows:next
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *nextImage = [UIImage xh_imageNamedFromMyBundle:@"images/btn_common_forward_wh"];
    nextBtn.frame = CGRectMake(0, 0, 44, 44);
    nextBtn.imageEdgeInsets = UIEdgeInsetsMake(13.25, 17.25, 13.25, 17.25);
    [nextBtn setImage:nextImage forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(gotoNextPage) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.contentMode = UIViewContentModeCenter;
    _toolNextButton = [[UIBarButtonItem alloc] initWithCustomView:nextBtn];
    
    UIBarButtonItem *toolCounterButton = [[UIBarButtonItem alloc] initWithCustomView:_pager];
    
    // action button
    _toolActionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed)];
    _toolActionButton.tintColor = [UIColor whiteColor];
    
    [self addSubview:_blurBackground];
    [self addSubview:_contentView];
    [self addSubview:_toolBar];
    [_contentView addSubview:_scrollView];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSMutableArray *items = [NSMutableArray array];
    
    [items addObject:_toolActionButton];
    [items addObject:flexSpace];
    
    [items addObject:_toolPreviousButton];
    [items addObject:flexSpace];
    
    [items addObject:toolCounterButton];
    [items addObject:flexSpace];
    
    [items addObject:_toolNextButton];
    [items addObject:flexSpace];
    
    [items addObject:_toolActionButton];
    
    [_toolBar setItems:items animated:NO];
    
    [self setSettingCloseButton];
    [self setSettingDeleteButton];
    [self setSettingCaptionView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tap.delegate = self;
    [_contentView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.delegate = self;
    tap2.numberOfTapsRequired = 2;
    [tap requireGestureRecognizerToFail: tap2];
    [_contentView addGestureRecognizer:tap2];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    press.delegate = self;
    [_contentView addGestureRecognizer:press];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [_contentView addGestureRecognizer:pan];
        _panGesture = pan;
    }
    
}

- (void)setSettingCaptionView {
    UITextView *captionView = [[UITextView alloc] init];
    captionView.frame = CGRectMake(0, self.xh_height - self.toolBar.xh_height - _maxCaptionHeight, self.xh_width, _maxCaptionHeight);
    captionView.editable = NO;
    captionView.font = [UIFont systemFontOfSize:15.0];
    captionView.textColor = [UIColor whiteColor];
    captionView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    captionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self addSubview:captionView];
    _captionView = captionView;
}

- (void)setSettingCloseButton {
    UIImage *doneImage = [UIImage xh_imageNamedFromMyBundle: @"images/btn_common_close_wh"];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:doneImage forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(15.25, 15.25, 15.25, 15.25);
    } else {
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    }
    closeButton.backgroundColor = [UIColor clearColor];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    closeButton.translatesAutoresizingMaskIntoConstraints = true;
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    _closeButtonHideFrame = CGRectMake(5, -20, 44, 44);
    _closeButtonShowFrame = CGRectMake(5, 20, 44, 44);
    [self addSubview:closeButton];
    
    closeButton.frame = _closeButtonShowFrame;
    _closeButton = closeButton;
}

- (void)setSettingDeleteButton {
    UIImage *deleteImage = [UIImage xh_imageNamedFromMyBundle: @"images/btn_common_delete_wh"];
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setImage:deleteImage forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        deleteButton.imageEdgeInsets = UIEdgeInsetsMake(15.25, 15.25, 15.25, 15.25);
    } else {
        deleteButton.imageEdgeInsets = UIEdgeInsetsMake(12.3, 12.3, 12.3, 12.3);
    }
    deleteButton.backgroundColor = [UIColor clearColor];
    deleteButton.hidden = YES;
    
    [deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    deleteButton.translatesAutoresizingMaskIntoConstraints = true;
    deleteButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    _deleteButtonHideFrame = CGRectMake(self.xh_width - 44, -20, 44, 44);
    _deleteButtonShowFrame = CGRectMake(self.xh_width - 44, 20, 44, 44);
    [self addSubview:deleteButton];
    deleteButton.frame = _deleteButtonShowFrame;
    _deleteButton = deleteButton;
}

// MARK: - Toolbar
- (void)updateCaption:(BOOL)isScroll animated:(BOOL)animated {
    if (_pager.currentPage < _groupItems.count) {
        _captionView.text = _groupItems[_pager.currentPage].caption;
        float oneTime = animated ? 0.2 : 0;
        [UIView animateWithDuration:oneTime animations:^{
            if (isScroll) {
                if (_showCaptionWhenScroll) {
                    _captionView.alpha = (_captionView.text.length ? 1.0 : 0);
                }
                
                if (_showToolBarWhenScroll) {
                    _toolBar.alpha = 1.0;
                    _toolBar.xh_bottom = self.xh_height;
                }
            } else {
                _captionView.alpha = (_captionView.text.length ? 1.0 : 0);
            }
            CGSize size = CGSizeZero;
            if (_captionView.text.length) {
                size = [_captionView sizeThatFits:CGSizeMake(self.xh_width, MAXFLOAT)];
            }
            size.width = self.xh_width;
            if (size.height > _maxCaptionHeight) {
                size.height = _maxCaptionHeight;
            }
            _captionView.xh_top = self.xh_height - size.height - (self.toolBar.alpha < 1.0 ? 0 : self.toolBar.xh_height);
            _captionView.xh_size = size;
        }];
    }
}

- (void)updateToolbar {
    _toolPreviousButton.enabled = _pager.currentPage > 0;
    _toolNextButton.enabled = _pager.currentPage < _groupItems.count - 1;
    _pager.numberOfPages = _groupItems.count;
}

- (void)deleteButtonPressed:(UIButton *)sender {
    sender.enabled = NO;
    
    NSInteger index = _pager.currentPage;
    
    if ([self.delegate respondsToSelector:@selector(xh_photoBrowserDidTapDelete:photoAtIndex:deleteBlock:)]) {
        @weakify(self);
        [self.delegate xh_photoBrowserDidTapDelete:self photoAtIndex:index deleteBlock:^{
            @strongify(self);
            if (!self) { return; }
            [self deletePhotoAtIndex:index sender:sender];
        }];
    } else {
        [self deletePhotoAtIndex:index sender:sender];
    }
}

- (void)deletePhotoAtIndex:(NSInteger)index sender:(UIButton *)sender {
    if (self.groupItems.count - 1 > 0) {
        
        [(NSMutableArray *)self.groupItems removeObjectAtIndex:index];
        
        if (index > 0 && index <= _groupItems.count) {
            
            _isOrientationChange = YES;
            [UIView animateWithDuration:0.25 animations:^{
                _scrollView.contentOffset = CGPointMake(MAX(0, (_pager.currentPage - 1) * _scrollView.xh_width), _scrollView.contentOffset.y);
            } completion:^(BOOL finished) {
                if (finished) {
                    _scrollView.contentSize = CGSizeMake(_scrollView.xh_width * self.groupItems.count, _scrollView.xh_height);
                    _isOrientationChange = NO;
                    XHPhotoBrowserCell *cell = [self cellForPage:index];
                    if (index >= self.groupItems.count) {
                        XHPhotoBrowserCell *cell = [self cellForPage:index];
                        cell.page = -1;
                        cell.item = nil;
                        [cell removeFromSuperview];
                    } else {
                        cell.item = self.groupItems[index];
                    }
                    [self scrollViewDidScroll:self.scrollView];
                    sender.enabled = YES;
                }
            }];
            
        } else {// index == 0
            
            _isOrientationChange = YES;
            [UIView animateWithDuration:0.25 animations:^{
                _scrollView.contentOffset = CGPointMake(_scrollView.xh_width, _scrollView.contentOffset.y);
            } completion:^(BOOL finished) {
                if (finished) {
                    
                    XHPhotoBrowserCell *cell = [self cellForPage:index];
                    cell.page = -1;
                    cell.item = nil;
                    [cell removeFromSuperview];
                    
                    if (index + 1 <= _groupItems.count) {
                        XHPhotoBrowserCell *cell = [self cellForPage:index + 1];
                        cell.xh_left = _imagePadding / 2;
                        cell.page = 0;
                    }
                    
                    if (index + 2 <= _groupItems.count) {
                        XHPhotoBrowserCell *cell = [self cellForPage:index + 2];
                        cell.xh_left = _scrollView.xh_width + _imagePadding / 2;
                        cell.page = 1;
                    }
                    
                    _scrollView.contentSize = CGSizeMake(_scrollView.xh_width * self.groupItems.count, _scrollView.xh_height);
                    _scrollView.contentOffset = CGPointMake(0, _scrollView.contentOffset.y);
                    
                    _isOrientationChange = NO;
                    
                    [self scrollViewDidScroll:self.scrollView];
                    
                    // 更新
                    [self didDisplayPhotoIndex:0 from:NSNotFound];
                    _pager.currentPage = 0;
                    [self updateCaption:YES animated:YES];
                    [self updateToolbar];
                    sender.enabled = YES;
                }
            }];
        }
    } else {
        [self dismiss];
    }
}

- (void)gotoPreviousPage {
    [_scrollView setContentOffset:CGPointMake(MAX(0, (_pager.currentPage - 1) * _scrollView.xh_width), _scrollView.contentOffset.y) animated:YES];
}

- (void)gotoNextPage {
    [_scrollView setContentOffset:CGPointMake(MIN(_scrollView.contentSize.width, (_pager.currentPage + 1) * _scrollView.xh_width), _scrollView.contentOffset.y) animated:YES];
}

// MARK: Action Button
- (void)actionButtonPressed {
    XHPhotoBrowserCell *tile = [self cellForPage:self.currentPage];
    if (!tile.imageView.image) return;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    [self addSubview:indicator];
    [indicator startAnimating];
    
    // try to save original image data if the image contains multi-frame (such as GIF/APNG)
    id imageItem = [tile.imageView.image yy_imageDataRepresentation];
    
    YYImageType type = YYImageDetectType((__bridge CFDataRef)(imageItem));
    if (type != YYImageTypePNG &&
        type != YYImageTypeJPEG &&
        type != YYImageTypeGIF) {
        imageItem = tile.imageView.image;
    }
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[imageItem] applicationActivities:nil];
    
    @weakify(self);
    UIActivityViewControllerCompletionHandler handler = ^(NSString * __nullable activityType, BOOL completed) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        
        @strongify(self)
        if (!self) {
            return;
        }
        //activityType:com.apple.UIKit.activity.SaveToCameraRoll completed:1
        if ([activityType rangeOfString:@"SaveToCameraRoll"].length > 0) {
            [self.class showHUD:completed ? @"保存成功!" : @"保存失败!" inView:self];
        }
        self.isLongPressed = NO;
    };
    
#ifdef __IPHONE_8_0
    activityViewController.completionWithItemsHandler = ^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
        handler(activityType, completed);
    };
#else
    activityViewController.completionHandler = handler;
#endif
    
    UIViewController *toVC = self.toContainerView.xh_viewController;
    if (!toVC) toVC = self.xh_viewController;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [toVC presentViewController:activityViewController animated:YES completion:nil];
    } else {
        UIPopoverController *sharePopover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [sharePopover presentPopoverFromBarButtonItem:_toolActionButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


// MARK: - show

- (void)showInContaioner:(UIView *)container
                animated:(BOOL)animated
              completion:(void (^)(void))completion {
    
    if (self.dataSource != nil) {
        [self reloadData];
    }
    
    if (_fromItemIndex >= _groupItems.count) {
        _fromItemIndex = _groupItems.count - 1;
    }
    
    if (_fromItemIndex < 0) {
        _fromItemIndex = 0;
    }
    
    if (_groupItems.count) {
        UIView *fromView = [self.groupItems[_fromItemIndex] thumbView];
        [self presentFromImageView:fromView toContainer:container currentPage:_fromItemIndex animated:animated completion:completion];
    }
}

- (void)reloadData {
    if ([self.dataSource respondsToSelector:@selector(xh_numberOfImagesInPhotoBrowser:)]) {
        NSInteger count = [self.dataSource xh_numberOfImagesInPhotoBrowser:self];
        _groupItems = [NSMutableArray arrayWithCapacity:count];
        
        for (int i = 0; i < count; i ++) {
            if ([self.dataSource respondsToSelector:@selector(xh_photoBrowser:photoAtIndex:)]) {
                id<XHPhotoProtocol> item = [self.dataSource xh_photoBrowser:self photoAtIndex:i];
                [(NSMutableArray *)_groupItems addObject:item];
            }
        }
        
        if (_isPresented) {
            [_cells removeAllObjects];
            [_scrollView xh_removeAllSubviews];
            _scrollView.contentOffset = CGPointMake(0, _scrollView.contentOffset.y);
            _scrollView.contentSize = CGSizeMake(_scrollView.xh_width * self.groupItems.count, _scrollView.xh_height);
        }
    }
}

- (void)reloadDataInRange:(NSRange)range {
    if (range.location >= _groupItems.count) {
        NSInteger count = range.location + range.length;
        
        for (NSInteger i = range.location; i < count; i ++) {
            if ([self.dataSource respondsToSelector:@selector(xh_photoBrowser:photoAtIndex:)]) {
                id<XHPhotoProtocol> item = [self.dataSource xh_photoBrowser:self photoAtIndex:i];
                [(NSMutableArray *)_groupItems addObject:item];
            }
        }
        
        _scrollView.contentSize = CGSizeMake(_scrollView.xh_width * self.groupItems.count, _scrollView.xh_height);
        [self updateToolbar];
        [self scrollViewDidScroll:_scrollView];
    } else {
        NSInteger maxLength = range.location + range.length;
        
        if (maxLength > _groupItems.count) {
            NSInteger deleteLength = _groupItems.count - range.location;
            [(NSMutableArray *)_groupItems removeObjectsInRange:NSMakeRange(range.location, deleteLength)];
            
            for (NSInteger i = range.location; i < maxLength; i ++) {
                if ([self.dataSource respondsToSelector:@selector(xh_photoBrowser:photoAtIndex:)]) {
                    id<XHPhotoProtocol> item = [self.dataSource xh_photoBrowser:self photoAtIndex:i];
                    [(NSMutableArray *)_groupItems addObject:item];
                }
            }
            _scrollView.contentSize = CGSizeMake(_scrollView.xh_width * self.groupItems.count, _scrollView.xh_height);
            [self updateToolbar];
            [self scrollViewDidScroll:_scrollView];
        } else {
            for (NSInteger i = range.location; i < maxLength; i ++) {
                if ([self.dataSource respondsToSelector:@selector(xh_photoBrowser:photoAtIndex:)]) {
                    id<XHPhotoProtocol> item = [self.dataSource xh_photoBrowser:self photoAtIndex:i];
                    [(NSMutableArray *)_groupItems replaceObjectAtIndex:i withObject:item];
                }
            }
            [self scrollViewDidScroll:_scrollView];
        }
    }
}

- (void)presentFromImageView:(UIView *)fromView
                 toContainer:(UIView *)toContainer
                 currentPage:(NSInteger)currentPage
                    animated:(BOOL)animated
                  completion:(nullable void (^)(void))completion {
    if (!toContainer) return;
    
    self.frame = toContainer.bounds;
    
    _closeButton.hidden = !_showCloseButton;
    _deleteButton.hidden = !_showDeleteButton;
    
    if (_toolBarShowStyle == XHShowStyleHide) {
        _toolBar.xh_height = 0;
        _toolBar.hidden = YES;
    }
    
    if (!_upDownDismiss) {
        [_panGesture removeTarget:self action:@selector(pan:)];
        [_contentView removeGestureRecognizer:_panGesture];
    }
    
    _scrollView.alwaysBounceHorizontal = _groupItems.count > 1;
    _fromView = fromView;
    _toContainerView = toContainer;
    
    _fromItemIndex = currentPage;
    
    if (_blurEffectBackground) {
        UIView *view = nil;
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            view = effectView;
        } else {
            // toolbar 实现比较简单 也可以兼容ios7 但是可能有潜在的问题,所以ios8还是使用UIVisualEffectView
            UIToolbar *toolBar = [[UIToolbar alloc] init];
            toolBar.translucent = YES;
            toolBar.barStyle = UIBarStyleBlackTranslucent;
            toolBar.tintColor = nil;
            toolBar.barTintColor = nil;
            toolBar.barStyle = UIBarStyleBlackTranslucent;
            [toolBar setBackgroundImage:nil forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
            toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            view = toolBar;
        }
        view.frame = _blurBackground.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_blurBackground addSubview:view];
    } else {
        _blurBackground.backgroundColor = [UIColor blackColor];
    }
    
    self.xh_size = _toContainerView.xh_size;
    self.blurBackground.alpha = 0;
    self.pager.numberOfPages = self.groupItems.count;
    self.pager.currentPage = currentPage;
    [self updateToolbar];
    self.toolBar.alpha = 0;
    self.captionView.alpha = 0;
    self.deleteButton.alpha = 0;
    self.closeButton.alpha = 0;
    
    _scrollView.contentSize = CGSizeMake(_scrollView.xh_width * self.groupItems.count, _scrollView.xh_height);
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.xh_width * _pager.currentPage, 0, _scrollView.xh_width, _scrollView.xh_height) animated:NO];
    [self scrollViewDidScroll:_scrollView];
    
    [self moveBrowserToSuperview];
    [_toContainerView addSubview:self];
    
    [UIView setAnimationsEnabled:YES];
    [self willShowPhotoGroup:animated];
    
    XHPhotoBrowserCell *cell = [self cellForPage:currentPage];
    id<XHPhotoProtocol> item = _groupItems[currentPage];
    
    BOOL isFromImageClipped = [item shouldClipToTop];
    
    if (!isFromImageClipped) {
        NSString *imageKey = [[YYWebImageManager sharedManager] cacheKeyForURL:item.largeImageURL];
        if ([[YYWebImageManager sharedManager].cache getImageForKey:imageKey withType:YYImageCacheTypeMemory]) {
            cell.item = item;
        }
    }
    if (!cell.item && item.thumbImage != nil) {
        cell.imageView.image = item.thumbImage;
        [cell resizeSubviewSize];
    }
    
    if (isFromImageClipped) {
        CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell];
        if (_thumbViewIsCell && [UIDevice currentDevice].systemVersion.floatValue < 9.0) {
            fromFrame = [fromView convertRect:fromView.frame toView:cell];
            fromFrame.size = CGSizeMake(fromFrame.size.width * 2, fromFrame.size.height * 2);
        }
        
        fromFrame.origin.y -= _contentOffSetY;
        
        CGRect originFrame = cell.imageContainerView.frame;
        CGFloat scale = fromFrame.size.width / cell.imageContainerView.xh_width;
        
        cell.imageContainerView.xh_centerX = CGRectGetMidX(fromFrame);
        cell.imageContainerView.xh_height = fromFrame.size.height / scale;
        [cell.imageContainerView.layer setValue:@(scale) forKeyPath:@"transform.scale"];
        cell.imageContainerView.xh_centerY = CGRectGetMidY(fromFrame);
        
        float oneTime = animated ? 0.25 : 0;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            _blurBackground.alpha = 1;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:oneTime animations:^{
                self.deleteButton.alpha = 1;
                self.closeButton.alpha = 1;
            }];
        }];
        
        _scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [cell.imageContainerView.layer setValue:@(1) forKeyPath:@"transform.scale"];
            cell.imageContainerView.frame = originFrame;
            [self showToolBar:animated];
        }completion:^(BOOL finished) {
            _isPresented = YES;
            [self scrollViewDidScroll:_scrollView];
            _scrollView.userInteractionEnabled = YES;
            if (completion) completion();
            [self didShowPhotoGroup:animated];
            [self didDisplayPhotoIndex:currentPage from:NSNotFound];
            [self updateCaption:NO animated:animated];
            [self hideToolBar];
        }];
        
    } else {
        //9.3 (CGRect) fromFrame = (origin = (x = 166.5, y = -146.5), size = (width = 70, height = 70))
        //8.1 (CGRect) fromFrame = (origin = (x = 166.5, y = -146.5), size = (width = 35, height = 35))
        CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell.imageContainerView];
        if (_thumbViewIsCell && [UIDevice currentDevice].systemVersion.floatValue < 9.0) {
            fromFrame = [fromView convertRect:fromView.frame toView:cell.imageContainerView];
            fromFrame.size = CGSizeMake(fromFrame.size.width * 2, fromFrame.size.height * 2);
        }
        fromFrame.origin.y -= _contentOffSetY;
        //9.3 (CGRect) fromFrame = (origin = (x = 166.5, y = -82.5), size = (width = 70, height = 70))
        //8.1 (CGRect) fromFrame = (origin = (x = 83.25, y = -122.5), size = (width = 35, height = 35))
        
        cell.imageContainerView.clipsToBounds = NO;
        cell.imageView.frame = fromFrame;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        float oneTime = animated ? 0.18 : 0;
        [UIView animateWithDuration:oneTime*2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            _blurBackground.alpha = 1;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:oneTime animations:^{
                self.deleteButton.alpha = 1;
                self.closeButton.alpha = 1;
            }];
        }];
        
        _scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.imageView.frame = cell.imageContainerView.bounds;
            [cell.imageView.layer setValue:@(1.01) forKeyPath:@"transform.scale"];
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                [cell.imageView.layer setValue:@(1.0) forKeyPath:@"transform.scale"];
                [self showToolBar:animated];
            }completion:^(BOOL finished) {
                cell.imageContainerView.clipsToBounds = YES;
                _isPresented = YES;
                [self scrollViewDidScroll:_scrollView];
                _scrollView.userInteractionEnabled = YES;
                if (completion) completion();
                [self didShowPhotoGroup:animated];
                [self didDisplayPhotoIndex:currentPage from:NSNotFound];
                [self updateCaption:NO animated:animated];
                [self hideToolBar];
            }];
        }];
    }
}

- (void)willShowPhotoGroup:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(xh_photoBrowserWillDisplay:)]) {
        [self.delegate xh_photoBrowserWillDisplay:self];
    }
    _fromNavigationBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
}

- (void)didShowPhotoGroup:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(xh_photoBrowserDidDisplay:)]) {
        [self.delegate xh_photoBrowserDidDisplay:self];
    }
}

- (void)willDismissPhotoGroup:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(xh_photoBrowserWillDismiss:)]) {
        [self.delegate xh_photoBrowserWillDismiss:self];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
}

- (void)moveBrowserToSuperview {
    if ([self.delegate respondsToSelector:@selector(xh_photoBrowserWillMoveToSuperView:)]) {
        [self.delegate xh_photoBrowserWillMoveToSuperView:self];
    }
}

- (void)removeBrowserFromSuperview {
    if ([self.delegate respondsToSelector:@selector(xh_photoBrowserWillRemoveFromSuperView:)]) {
        [self.delegate xh_photoBrowserWillRemoveFromSuperView:self];
    }
}

- (void)didDismissPhotoGroup:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(xh_photoBrowserDidDismiss:)]) {
        [self.delegate xh_photoBrowserDidDismiss:self];
    }
}

- (void)didDisplayPhotoIndex:(NSInteger)index from:(NSInteger)from {
    if ([self.delegate respondsToSelector:@selector(xh_photoBrowser:didDisplayingImageAtIndex:fromIndex:)]) {
        [self.delegate xh_photoBrowser:self didDisplayingImageAtIndex:index fromIndex:from];
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [UIView setAnimationsEnabled:YES];
    
    [self willDismissPhotoGroup:animated];
    
    NSInteger currentPage = self.currentPage;
    XHPhotoBrowserCell *cell = [self cellForPage:currentPage];
    id<XHPhotoProtocol> item = _groupItems[currentPage];
    
    UIView *fromView = nil;
    if (_fromItemIndex == currentPage) {
        fromView = _fromView;
    } else {
        fromView = item.thumbView;
    }
    
    [self cancelAllImageLoad];
    _isPresented = NO;
    BOOL isFromImageClipped = [item shouldClipToTop];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (isFromImageClipped) {
        CGRect frame = cell.imageContainerView.frame;
        cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0);
        cell.imageContainerView.frame = frame;
    }
    cell.progressLayer.hidden = YES;
    [CATransaction commit];
    
    
    BOOL outOfScreen = NO;
    if (fromView != nil) {
        CGRect targetTemp = [fromView convertRect:fromView.bounds toView:self.toContainerView];
        if (_thumbViewIsCell && [UIDevice currentDevice].systemVersion.floatValue < 9.0) {
            targetTemp = [fromView convertRect:fromView.frame toView:self.toContainerView];
            targetTemp.size = CGSizeMake(targetTemp.size.width * 2, targetTemp.size.height * 2);
        }
        
        targetTemp.origin.y -= _contentOffSetY;
        
        if (CGRectGetMidY(targetTemp) - 64 < 0 || CGRectGetMidY(targetTemp) + 49 > [UIScreen mainScreen].bounds.size.height) {
            outOfScreen = YES;
        }
    }
    
    
    if (fromView == nil || outOfScreen) {
        [self removeBrowserFromSuperview];
        [UIView animateWithDuration:animated ? 0.3 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear animations:^{
            self.alpha = 0.0;
            //            [self.scrollView.layer setValue:@(0.95) forKeyPath:@"transform.scale"];
            [self.scrollView.layer setValue:@(2.0) forKeyPath:@"transform.scale"];
            self.scrollView.alpha = 0;
            self.pager.alpha = 0;
            self.blurBackground.alpha = 0;
            self.captionView.alpha = 0;
            self.closeButton.alpha = 0;
            self.deleteButton.alpha = 0;
        }completion:^(BOOL finished) {
            [self.scrollView.layer setValue:@(1) forKeyPath:@"transform.scale"];
            [self removeFromSuperview];
            [self cancelAllImageLoad];
            if (completion) completion();
            
            [self didDismissPhotoGroup:animated];
        }];
        return;
    }
    
    if (isFromImageClipped) {
        if (cell.contentOffset.y > self.xh_height * 4) {
            CGPoint off = cell.contentOffset;
            off.y = 0 - cell.contentInset.top;
            [cell setContentOffset:off animated:NO];
        }
    }
    
    [UIView animateWithDuration:animated ? 0.3 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        _toolBar.alpha = 0.0;
        _blurBackground.alpha = 0.0;
        _captionView.alpha = 0.0;
        _closeButton.alpha = 0;
        _deleteButton.alpha = 0;
        
        if (isFromImageClipped) {
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell];
            if (_thumbViewIsCell && [UIDevice currentDevice].systemVersion.floatValue < 9.0) {
                fromFrame = [fromView convertRect:fromView.frame toView:cell];
                fromFrame.size = CGSizeMake(fromFrame.size.width * 2, fromFrame.size.height * 2);
            }
            
            fromFrame.origin.y -= _contentOffSetY;
            
            CGFloat scale = fromFrame.size.width / cell.imageContainerView.xh_width * cell.zoomScale;
            CGFloat height = fromFrame.size.height / fromFrame.size.width * cell.imageContainerView.xh_width;
            if (isnan(height)) height = cell.imageContainerView.xh_height;
            
            cell.imageContainerView.xh_height = height;
            cell.imageContainerView.center = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMinY(fromFrame));
            [cell.imageContainerView.layer setValue:@(scale) forKeyPath:@"transform.scale"];
            
        } else {
            //8.1 gif (CGRect) fromFrame = (origin = (x = 41.75, y = -154.5), size = (width = 35, height = 35))
            //9.3 gif (CGRect) fromFrame = (origin = (x = 83.5, y = -114.5), size = (width = 70, height = 70))
            
            //8.1 gif 大 (CGRect) fromFrame = (origin = (x = 227.25, y = 8.16666698), size = (width = 11.666667, height = 11.666667))
            //9.3 gif (CGRect) fromFrame = (origin = (x = 241.166672, y = 21.5), size = (width = 23.333334, height = 23.333334))
            
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell.imageContainerView];
            if (_thumbViewIsCell && [UIDevice currentDevice].systemVersion.floatValue < 9.0) {
                fromFrame = [fromView convertRect:fromView.frame toView:cell.imageContainerView];
                fromFrame.size = CGSizeMake(fromFrame.size.width * 2, fromFrame.size.height * 2);
            }
            
            fromFrame.origin.y -= _contentOffSetY/cell.zoomScale;
            
            if ([fromView isKindOfClass:[UIImageView class]]) {
                cell.imageView.contentMode = fromView.contentMode;
            } else {
                cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            }
            
            cell.imageContainerView.clipsToBounds = NO;
            cell.imageView.frame = fromFrame;
        }
    }completion:^(BOOL finished) {
        [self removeBrowserFromSuperview];
        [UIView animateWithDuration:animated ? 0.15 : 0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            [self removeFromSuperview];
            if (completion) completion();
            
            [self didDismissPhotoGroup:animated];
        }];
    }];
    
    
}

//MARK: 单击消失
- (void)dismiss {
    // 停止正在滚动的图片
    XHPhotoBrowserCell *cell = [self cellForPage:_pager.currentPage];
    [cell setContentOffset:cell.contentOffset animated:NO];
    
    [self dismissAnimated:YES completion:nil];
}

- (void)cancelAllImageLoad {
    [_cells enumerateObjectsUsingBlock:^(XHPhotoBrowserCell *cell, NSUInteger idx, BOOL *stop) {
        [cell.imageView yy_cancelCurrentImageRequest];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isOrientationChange) {
        return;
    }
    [self updateCellsForReuse];
    
    CGFloat floatPage = _scrollView.contentOffset.x / _scrollView.xh_width;
    NSInteger page = _scrollView.contentOffset.x / _scrollView.xh_width + 0.5;
    
    for (NSInteger i = page - 1; i <= page + 1; i++) { // preload left and right cell
        if (i >= 0 && i < self.groupItems.count) {
            XHPhotoBrowserCell *cell = [self cellForPage:i];
            if (!cell) {
                XHPhotoBrowserCell *cell = [self dequeueReusableCell];
                cell.page = i;
                cell.xh_left = (self.xh_width + _imagePadding) * i + _imagePadding / 2;
                
                if (_isPresented) {
                    cell.item = self.groupItems[i];
                }
                [self.scrollView addSubview:cell];
            } else {
                if (_isPresented && !cell.item) {
                    cell.item = self.groupItems[i];
                }
            }
        }
    }
    
    NSInteger intPage = floatPage + 0.5;
    intPage = intPage < 0 ? 0 : intPage >= _groupItems.count ? (int)_groupItems.count - 1 : intPage;
    if (_pager.currentPage != intPage) {
        [self didDisplayPhotoIndex:intPage from:_pager.currentPage];
        _pager.currentPage = intPage;
        [self updateCaption:YES animated:YES];
        [self updateToolbar];
    }
    
    if (_showToolBarWhenScroll) {
        [self showToolBar:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self hideToolBar];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self hideToolBar];
}

- (void)showToolBar:(BOOL)animated {
    if (_toolBarShowStyle != XHShowStyleHide) {
        if (_toolBarShowStyle == XHShowStyleAuto) {
            [self hideToolBar];
        }
        
        if (_toolBar.alpha >= 0.99) {
            return;
        }
        
        float oneTime = animated ? 0.2 : 0;
        
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _toolBar.alpha = 1;
        } completion:^(BOOL finish) {
            if (finish) {
                [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    _captionView.xh_top = self.xh_height - _captionView.xh_height - self.toolBar.xh_height;
                } completion:^(BOOL finished) {
                }];
            }
        }];
    }
}

- (void)hideToolBar {
    if (_toolBarShowStyle == XHShowStyleAuto) {
        [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolBarDelay) object:nil];
        [self performSelector:@selector(hideToolBarDelay) withObject:nil afterDelay:1.0];
    }
}

- (void)hideToolBarDelay {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _toolBar.alpha = 0;
    } completion:^(BOOL finish) {
        if (finish) {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _captionView.xh_top = self.xh_height - _captionView.xh_height;
            } completion:nil];
        }
    }];
    
}

/// enqueue invisible cells for reuse
- (void)updateCellsForReuse {
    for (XHPhotoBrowserCell *cell in _cells) {
        if (cell.superview) {
            if (cell.xh_left > _scrollView.contentOffset.x + _scrollView.xh_width * 2
                ||cell.xh_right < _scrollView.contentOffset.x - _scrollView.xh_width) {
                [cell removeFromSuperview];
                cell.page = -1;
                cell.item = nil;
            }
        }
    }
}

/// dequeue a reusable cell
- (XHPhotoBrowserCell *)dequeueReusableCell {
    XHPhotoBrowserCell *cell = nil;
    for (cell in _cells) {
        if (!cell.superview) {
            return cell;
        }
    }
    
    cell = [XHPhotoBrowserCell new];
    cell.frame = self.bounds;
    cell.imageContainerView.frame = self.bounds;
    cell.imageView.frame = cell.bounds;
    cell.page = -1;
    cell.item = nil;
    [_cells addObject:cell];
    return cell;
}

/// get the cell for specified page, nil if the cell is invisible
- (XHPhotoBrowserCell *)cellForPage:(NSInteger)page {
    for (XHPhotoBrowserCell *cell in _cells) {
        if (cell.page == page) {
            return cell;
        }
    }
    return nil;
}

- (NSInteger)currentPage {
    NSInteger page = _pager.currentPage;
    if (page >= _groupItems.count) page = (NSInteger)_groupItems.count - 1;
    if (page < 0) page = 0;
    return page;
}

// MARK: - Gesture
- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (!_isPresented) return;
    
    if ([self.delegate respondsToSelector:@selector(xh_photoBrowserSingleTap:)]) {
        [self.delegate xh_photoBrowserSingleTap:self];
    }
    
    if (_singleTapOption == XHSingleTapOptionDismiss) {
        [self dismiss];
        return;
    }
    
    if (_singleTapOption == XHSingleTapOptionNone) {
        [UIView animateWithDuration:0.2 animations:^{
            if (self.captionView.alpha != 0 || self.toolBar.alpha != 0) {
                self.toolBar.xh_top = self.xh_height;
                self.captionView.xh_bottom = self.xh_height;
                self.captionView.alpha = 0;
                self.toolBar.alpha = 0;
            } else {
                self.captionView.alpha = 1.0;
                self.toolBar.alpha = 1.0;
                self.toolBar.xh_bottom = self.xh_height;
                self.captionView.xh_top = self.xh_height - self.captionView.xh_height - self.toolBar.xh_height;
            }
        } completion:^(BOOL finished) {
        }];
        
        return;
    }
    
    if (_singleTapOption == XHSingleTapOptionAuto) {
        if (self.captionView.text.length <= 0) {
            [self dismiss];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                if (self.captionView.alpha == 0) {
                    self.captionView.alpha = 1.0;
                    self.toolBar.alpha = 1;
                    self.toolBar.xh_bottom = self.xh_height;
                    self.captionView.xh_top = self.xh_height - self.captionView.xh_height - self.toolBar.xh_height;
                } else {
                    self.toolBar.xh_top = self.xh_height;
                    self.captionView.xh_bottom = self.xh_height;
                    self.captionView.alpha = 0;
                    self.toolBar.alpha = 0;
                }
            } completion:^(BOOL finished) {
            }];
        }
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)g {
    if (!_isPresented) return;
    XHPhotoBrowserCell *tile = [self cellForPage:self.currentPage];
    if (tile) {
        if (tile.zoomScale > 1) {
            [tile setZoomScale:1 animated:YES];
        } else {
            CGPoint touchPoint = [g locationInView:tile.imageView];
            CGFloat newZoomScale = tile.maximumZoomScale;
            CGFloat xsize = self.xh_width / newZoomScale;
            CGFloat ysize = self.xh_height / newZoomScale;
            [tile zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        }
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (!_isPresented) return;
    
    if (sender.state == UIGestureRecognizerStateEnded) return;
    
    if (_isLongPressed) {
        return;
    }
    
    _isLongPressed = YES;
    
    [self actionButtonPressed];
}

- (void)pan:(UIPanGestureRecognizer *)g {
    switch (g.state) {
        case UIGestureRecognizerStateBegan: {
            if (_isPresented) {
                _panGestureBeginPoint = [g locationInView:self];
            } else {
                _panGestureBeginPoint = CGPointZero;
            }
            [self willDismissPhotoGroup:YES];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _captionView.xh_top = self.xh_height - _captionView.xh_height - self.toolBar.xh_height;
            } completion:nil];
        } break;
        case UIGestureRecognizerStateChanged: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            _scrollView.xh_top = deltaY;
            
            CGFloat alphaDelta = 160;
            CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
            alpha = XH_CLAMP(alpha, 0, 1);
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                _blurBackground.alpha = alpha;
                _toolBar.alpha = alpha;
                _captionView.alpha = (_captionView.text.length ? alpha : 0);
                _closeButton.alpha = alpha;
                _deleteButton.alpha = alpha;
            } completion:nil];
            
        } break;
        case UIGestureRecognizerStateEnded: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint v = [g velocityInView:self];
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            
            if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
                [self cancelAllImageLoad];
                _isPresented = NO;
                
                [self willDismissPhotoGroup:YES];
                
                BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
                CGFloat vy = fabs(v.y);
                if (vy < 1) vy = 1;
                CGFloat duration = (moveToTop ? _scrollView.xh_bottom : self.xh_height - _scrollView.xh_top) / vy;
                duration *= 0.8;
                duration = XH_CLAMP(duration, 0.05, 0.3);
                
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _blurBackground.alpha = 0;
                    _toolBar.alpha = 0;
                    _captionView.alpha = 0;
                    _closeButton.alpha = 0;
                    _deleteButton.alpha = 0;
                    
                    if (moveToTop) {
                        _scrollView.xh_bottom = 0;
                    } else {
                        _scrollView.xh_top = self.xh_height;
                    }
                } completion:^(BOOL finished) {
                    [self removeBrowserFromSuperview];
                    [self removeFromSuperview];
                    [self didDismissPhotoGroup:YES];
                }];
                
            } else {
                [self willShowPhotoGroup:YES];
                
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _scrollView.xh_top = 0;
                    _captionView.alpha = (_captionView.text.length ? 1.0 : 0);
                    _blurBackground.alpha = 1.0;
                    _deleteButton.alpha = 1.0;
                    _closeButton.alpha = 1.0;
                    [self hideToolBar];
                } completion:^(BOOL finished) {
                    [self didShowPhotoGroup:YES];
                }];
            }
            
        } break;
        case UIGestureRecognizerStateCancelled : {
            _scrollView.xh_top = 0;
            _blurBackground.alpha = 1;
            _closeButton.alpha = 1;
            _deleteButton.alpha = 1;
            _captionView.alpha = (_captionView.text.length ? 1.0 : 0);
            [self didShowPhotoGroup:YES];
        }
        default:break;
    }
}

// MARK: - NSNotification 屏幕旋转
- (void)statusBarOrientationChange:(NSNotification *)notification{
    _isOrientationChange = YES;
    self.frame = _toContainerView.bounds;
    _contentView.frame = self.bounds;
    
    if ([self.delegate respondsToSelector:@selector(xh_photoBrowserDidOrientationChange:)]) {
        [self.delegate xh_photoBrowserDidOrientationChange:self];
    }
    
    _scrollView.frame = CGRectMake(-_imagePadding / 2, 0, self.xh_width + _imagePadding, self.xh_height);
    _scrollView.contentSize = CGSizeMake(_scrollView.xh_width * self.groupItems.count, _scrollView.xh_height);
    _isOrientationChange = NO;
    
    [_cells enumerateObjectsUsingBlock:^(__kindof XHPhotoBrowserCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cell.superview) {
            cell.frame = self.bounds;
            [cell setZoomScale:1.0 animated:NO];
            cell.xh_left = (self.xh_width + _imagePadding) * cell.page + _imagePadding / 2;
            [cell resizeSubviewSize];
        } else {
            cell.frame = self.bounds;
            [cell setZoomScale:1.0 animated:NO];
        }
    }];
    
    if (CGPointEqualToPoint(CGPointMake(_scrollView.xh_width * _pager.currentPage, 0), _scrollView.contentOffset)) {
        [self scrollViewDidScroll:self.scrollView];
    } else {
        [_scrollView setContentOffset:CGPointMake(_scrollView.xh_width * _pager.currentPage, 0) animated:NO];
    }
}

// MARK: - HUD
+ (void)showHUD:(NSString *)msg inView:(UIView *)inView {
    if (!msg.length) return;
    UIFont *font = [UIFont systemFontOfSize:17];
    CGSize size = [self sizeWithText:msg forFont:font size:CGSizeMake(200, 200) mode:NSLineBreakByCharWrapping];
    UILabel *label = [UILabel new];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    label.xh_size = CGSizeMake(ceil(size.width * scale) / scale,
                               ceil(size.height * scale) / scale);
    label.font = font;
    label.text = msg;
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    
    UIView *hud = [UIView new];
    hud.xh_size = CGSizeMake(label.xh_width + 20, label.xh_height + 20);
    hud.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.650];
    hud.clipsToBounds = YES;
    hud.layer.cornerRadius = 8;
    
    label.center = CGPointMake(hud.xh_width / 2, hud.xh_height / 2);
    [hud addSubview:label];
    
    hud.center = CGPointMake(inView.xh_width / 2, inView.xh_height / 2);
    hud.alpha = 0;
    [inView addSubview:hud];
    
    [UIView animateWithDuration:0.4 animations:^{
        hud.alpha = 1;
    }];
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.4 animations:^{
            hud.alpha = 0;
        } completion:^(BOOL finished) {
            [hud removeFromSuperview];
        }];
    });
}

+ (CGSize)sizeWithText:(NSString *)text forFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [text boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [text sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

@end
