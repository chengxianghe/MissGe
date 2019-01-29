//
//  XHPhotoBrowserController.m
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/27.
//  Copyright © 2016年 cn. All rights reserved.
//

#import "XHPhotoBrowserController.h"
#import "XHPhotoBrowserHeader.h"

@interface XHPhotoBrowserController () <XHPhotoBrowserDelegate, XHPhotoBrowserDataSource, UIGestureRecognizerDelegate> {
    BOOL _previousNavBarHidden;
}

@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL navBarAnimating;
@property (nonatomic, strong) UIView *customNavView;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *customNavTitleLabel;

@end

@implementation XHPhotoBrowserController {
    id<UIGestureRecognizerDelegate> _delegate;
}

- (id)init {
    if ((self = [super init])) {
        [self _initialisation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        [self _initialisation];
    }
    return self;
}

- (void)dealloc {
    [_browser dismissAnimated:NO completion:nil];
    _browser = nil;
}

- (void)_initialisation {
    self.hidesBottomBarWhenPushed = YES;
    _showBrowserWhenDidload = YES;
    _previousNavBarHidden = self.navigationController.navigationBar.hidden;
    _alwaysShowStatusBar = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    XHPhotoBrowser *browser = [[XHPhotoBrowser alloc] init];
    browser.delegate = self;
    browser.dataSource = self;
    browser.showDeleteButton = NO;
    browser.toolBarShowStyle = XHShowStyleShow;
    browser.showCloseButton = NO;
    browser.upDownDismiss = NO;
    browser.fromItemIndex = 0;
    browser.blurEffectBackground = NO;
    browser.showToolBarWhenScroll = NO;
    browser.showCaptionWhenScroll = NO;
    browser.isFullScreen = NO;
    browser.isFullScreenWord = NO;
    browser.singleTapOption = XHSingleTapOptionNone;
    browser.pager.style = XHPageControlStyleNone;
    _browser = browser;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_previousNavBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    if (self.navigationController.viewControllers.count > 1 && [self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        _delegate = self.navigationController.interactivePopGestureRecognizer.delegate;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!_previousNavBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = _delegate;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat navH = kiPhoneX ? 88 : 64;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && [UIApplication sharedApplication].isStatusBarHidden) {
        navH = 44;
    }
    CGFloat statusH = kStatusBarHeight;
    
    self.customNavView = [[UIView alloc] init];
    [self.customNavView setFrame:CGRectMake(0, 0, kScreenWidth, navH)];
    self.customNavView.backgroundColor = [UIColor blackColor];
    self.customNavView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.customNavView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    self.customNavTitleLabel = titleLabel;
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [titleLabel setFrame:CGRectMake(0, 0, 200, 40)];
    [titleLabel setCenter:CGPointMake(kScreenWidth * 0.5, (navH + statusH) * 0.5)];
    [self.customNavView addSubview:titleLabel];
    if (!kiPhoneX) {
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightBtn = rightBtn;
    if (self.rightImage == nil) {
        self.rightImage = [UIImage xh_imageNamedFromMyBundle:@"images/btn_common_more_wh"];
    }
    [rightBtn setFrame:CGRectMake(kScreenWidth - 60, statusH, 50, 40)];
    [rightBtn setImage:self.rightImage forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavView addSubview:rightBtn];
    [rightBtn setCenter:CGPointMake(kScreenWidth - 25, (navH + statusH) * 0.5)];
    if (kiPhoneX) {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            rightBtn.xh_left = kScreenWidth - 60 - k_IPhoneX_SafeWidth;
        }
    } else {
        rightBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backBtn = backBtn;
    if (self.leftImage == nil) {
        self.leftImage = [UIImage xh_imageNamedFromMyBundle:@"images/btn_common_back_wh"] ;
    }
    [backBtn setFrame:CGRectMake(5, statusH + 10, 50, 40)];
    [backBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    backBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    [backBtn setImage:self.leftImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setCenter:CGPointMake(20, (navH + statusH) * 0.5)];
    [self.customNavView addSubview:backBtn];
    if (kiPhoneX) {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            backBtn.xh_left = k_IPhoneX_SafeWidth;
        }
    } else {
        backBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    
    self.browser.fromItemIndex = self.fromItemIndex;
    if (_showBrowserWhenDidload) {
        [_browser showInContaioner:self.view animated:NO completion:nil];
    }
    
    // 适配屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:)name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.statusBarHidden) {
        [self.view bringSubviewToFront:self.customNavView];
    }
}

#pragma mark - Action

- (void)onMore:(id)sender {
    if (_moreBlock) {
        _moreBlock();
    }
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIStatusBar

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)prefersStatusBarHidden {
    return _alwaysShowStatusBar ? NO : _statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

// MARK: - NSNotification 屏幕旋转
- (void)statusBarOrientationChange:(NSNotification *)notification{
    
    CGFloat statusH = kStatusBarHeight;
    if (!kiPhoneX) {
        CGFloat navH = 64;
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && [UIApplication sharedApplication].isStatusBarHidden) {
            navH = 44;
        }
        [self.customNavView setFrame:CGRectMake(0, 0, kScreenWidth, navH)];
    } else {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            CGFloat navH = 44;
            [self.customNavView setFrame:CGRectMake(0, 0, kScreenWidth, navH)];
            [self.backBtn setCenter:CGPointMake(18 + 30, (navH + kStatusBarHeight) * 0.5)];
            [self.rightBtn setCenter:CGPointMake(kScreenWidth - 30 - 40, (navH + statusH) * 0.5)];
            [self.customNavTitleLabel setCenter:CGPointMake(kScreenWidth * 0.5, (navH + statusH) * 0.5)];
        } else {
            CGFloat navH = 88;
            statusH = 44;
            [self.customNavView setFrame:CGRectMake(0, 0, kScreenWidth, navH)];
            [self.backBtn setCenter:CGPointMake(18, (navH + statusH) * 0.5)];
            [self.rightBtn setCenter:CGPointMake(kScreenWidth - 30, (navH + statusH) * 0.5)];
            [self.customNavTitleLabel setCenter:CGPointMake(kScreenWidth * 0.5, (navH + statusH) * 0.5)];
        }
    }
    self.customNavView.xh_top = self.statusBarHidden ? -self.customNavView.xh_height : 0;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.navigationController.childViewControllers.count > 1;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return self.navigationController.viewControllers.count > 1;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    [otherGestureRecognizer requireGestureRecognizerToFail:gestureRecognizer];
    return NO;
}

#pragma mark - XHPhotoBrowserDataSource

- (NSInteger)xh_numberOfImagesInPhotoBrowser:(XHPhotoBrowser *)photoBrowser {
    return self.groupItems.count;
}

- (id<XHPhotoProtocol>)xh_photoBrowser:(XHPhotoBrowser *)photoBrowser photoAtIndex:(NSInteger)index {
    return self.groupItems[index];
}

#pragma mark - XHPhotoBrowserDelegate

- (void)xh_photoBrowserSingleTap:(XHPhotoBrowser *)photoBrowser {
    if (self.navBarAnimating) return;
    
    CGFloat duration = 0.2;
    self.navBarAnimating = YES;
    
    [UIView animateWithDuration:duration animations:^{
        self.statusBarHidden = self.customNavView.xh_top >= 0;
        self.customNavView.xh_top = self.statusBarHidden ? -self.customNavView.xh_height : 0;
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        if (finished) {
            self.navBarAnimating = NO;
        }
    }];
}

- (void)xh_photoBrowser:(XHPhotoBrowser *)photoBrowser didDisplayingImageAtIndex:(NSInteger)index fromIndex:(NSInteger)fromIndex {
    self.title = [NSString stringWithFormat:@"%d / %d", (int)index + 1, (int)photoBrowser.groupItems.count];
    [self.customNavTitleLabel setText:self.title];
}

- (void)xh_photoBrowserDidDismiss:(XHPhotoBrowser *)photoBrowser {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

