//
//  XHPhotoBrowserController.m
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/27.
//  Copyright © 2016年 cn. All rights reserved.
//

#import "XHPhotoBrowserController.h"
#import "XHPhotoBrowserHeader.h"

@interface XHPhotoBrowserController () <XHPhotoBrowserDelegate, XHPhotoBrowserDataSource>
{
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _viewIsActive;
    BOOL _leaveStatusBarAlone;
    BOOL _viewHasAppearedInitially;
    
    // Appearance
    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTranslucent;
    UIBarStyle _previousNavBarStyle;
    UIStatusBarStyle _previousStatusBarStyle;
    UIColor *_previousNavBarTintColor;
    UIColor *_previousNavBarBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigationBarBackgroundImageDefault;
    UIImage *_previousNavigationBarBackgroundImageLandscapePhone;

}

@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL navBarAnimating;

@end

@implementation XHPhotoBrowserController

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
    _viewIsActive = NO;
    _didSavePreviousStateOfNavBar = NO;
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
    browser.singleTapOption = XHSingleTapOptionNone;
    browser.pager.style = XHPageControlStyleNone;
    _browser = browser;
}

#pragma mark - Appearance

- (BOOL)presentingViewControllerPrefersStatusBarHidden {
    UIViewController *presenting = self.presentingViewController;
    if (presenting) {
        if ([presenting isKindOfClass:[UINavigationController class]]) {
            presenting = [(UINavigationController *)presenting topViewController];
        }
    } else {
        // We're in a navigation controller so get previous one!
        if (self.navigationController && self.navigationController.viewControllers.count > 1) {
            presenting = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        }
    }
    if (presenting) {
        return [presenting prefersStatusBarHidden];
    } else {
        return NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // Super
    [super viewWillAppear:animated];
    
    // Status bar
    if (!_viewHasAppearedInitially) {
        _leaveStatusBarAlone = [self presentingViewControllerPrefersStatusBarHidden];
        // Check if status bar is hidden on first appear, and if so then ignore it
        if (CGRectEqualToRect([[UIApplication sharedApplication] statusBarFrame], CGRectZero)) {
            _leaveStatusBarAlone = YES;
        }
    }
    // Set style
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    }
    
    // Navigation bar appearance
    if (!_viewIsActive && [self.navigationController.viewControllers objectAtIndex:0] != self) {
        [self storePreviousNavBarAppearance];
    }
    [self setNavBarAppearance:animated];
    
    // Layout
    [self.view setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
    _viewHasAppearedInitially = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // Check that we're disappearing for good
    // self.isMovingFromParentViewController just doesn't work, ever. Or self.isBeingDismissed
    // old:   if ((self.navigationController.isBeingDismissed) ||
    // ([self.navigationController.viewControllers objectAtIndex:0] != self && ![self.navigationController.viewControllers containsObject:self])) {
    
    if ((self.navigationController.isBeingDismissed) ||
        ([self.navigationController.viewControllers objectAtIndex:0] != self)) {
        
        // State
        _viewIsActive = NO;
        
        // Bar state / appearance
        [self restorePreviousNavBarAppearance:animated];
    }
    
    // Controls
    [self.navigationController.navigationBar.layer removeAllAnimations]; // Stop all animations on nav bar
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
    
    // Status bar
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    }
    
    // Super
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);

    if (self.rightImage == nil) {
        self.rightImage = [UIImage imageNamed:@"XHPhotoBrowser.bundle/images/btn_common_more_wh"];
    }
    [btn setImage:self.rightImage forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *toolActionButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = toolActionButton;

    self.browser.fromItemIndex = self.fromItemIndex;

    if (_showBrowserWhenDidload) {
        [_browser showInContaioner:self.view animated:NO completion:nil];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.navigationController.navigationBar.xh_top = self.statusBarHidden ? -self.navigationController.navigationBar.xh_height : [UIApplication sharedApplication].statusBarFrame.size.height;
}

#pragma mark - Action

- (void)onMore:(UIBarButtonItem *)sender {
    if (_moreBlock) {
        _moreBlock();
    }
}

#pragma mark - UIStatusBar

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
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

#pragma mark - Nav Bar Appearance

- (void)setNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    navBar.barTintColor = [UIColor clearColor];
    navBar.shadowImage = nil;
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleBlackTranslucent;

    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
#ifdef __IPHONE_8_0
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
#else
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
#endif
}

- (void)storePreviousNavBarAppearance {
    _didSavePreviousStateOfNavBar = YES;
    _previousNavBarBarTintColor = self.navigationController.navigationBar.barTintColor;
    _previousNavBarTranslucent = self.navigationController.navigationBar.translucent;
    _previousNavBarTintColor = self.navigationController.navigationBar.tintColor;
    _previousNavBarHidden = self.navigationController.navigationBarHidden;
    _previousNavBarStyle = self.navigationController.navigationBar.barStyle;
    _previousNavigationBarBackgroundImageDefault = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    
#ifdef __IPHONE_8_0
    _previousNavigationBarBackgroundImageLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsCompact];
#else
    _previousNavigationBarBackgroundImageLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsLandscapePhone];
#endif
}

- (void)restorePreviousNavBarAppearance:(BOOL)animated {
    if (_didSavePreviousStateOfNavBar) {
        [self.navigationController setNavigationBarHidden:_previousNavBarHidden animated:animated];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        navBar.tintColor = _previousNavBarTintColor;
        navBar.translucent = _previousNavBarTranslucent;
        navBar.barTintColor = _previousNavBarBarTintColor;
        navBar.barStyle = _previousNavBarStyle;
        [navBar setBackgroundImage:_previousNavigationBarBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
        
#ifdef __IPHONE_8_0
        [navBar setBackgroundImage:_previousNavigationBarBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsCompact];
#else
        [navBar setBackgroundImage:_previousNavigationBarBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsLandscapePhone];
#endif
        // Restore back button if we need to
        if (_previousViewControllerBackButton) {
            UIViewController *previousViewController = [self.navigationController topViewController]; // We've disappeared so previous is now top
            previousViewController.navigationItem.backBarButtonItem = _previousViewControllerBackButton;
            _previousViewControllerBackButton = nil;
        }
    }
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
    __weak typeof(self) weak_self = self;
    [UIView animateWithDuration:duration animations:^{
        weak_self.statusBarHidden = weak_self.navigationController.navigationBar.xh_top > 0;
        [weak_self setNeedsStatusBarAppearanceUpdate];
        weak_self.navigationController.navigationBar.xh_top = weak_self.statusBarHidden ? -weak_self.navigationController.navigationBar.xh_height : [UIApplication sharedApplication].statusBarFrame.size.height;
    } completion:^(BOOL finished) {
        if (finished) {
            weak_self.navBarAnimating = NO;
        }
    }];
}

- (void)xh_photoBrowser:(XHPhotoBrowser *)photoBrowser didDisplayingImageAtIndex:(NSInteger)index fromIndex:(NSInteger)fromIndex {
    self.title = [NSString stringWithFormat:@"%d / %d", (int)index + 1, (int)photoBrowser.groupItems.count];
}

- (void)xh_photoBrowserDidDismiss:(XHPhotoBrowser *)photoBrowser {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
