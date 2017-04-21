//
//  XHPageControlView.m
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/23.
//  Copyright © 2016年 cn. All rights reserved.
//

#import "XHPageControlView.h"

@interface XHPageControlView ()

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UILabel *pageNumLabel;

@end

@implementation XHPageControlView

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.bounds.size.width, 20);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.pageControl = [[UIPageControl alloc] initWithFrame:self.bounds];
        self.pageControl.hidden = YES;
        [self addSubview:self.pageControl];
        
        self.pageNumLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.pageNumLabel.textAlignment = NSTextAlignmentCenter;
        self.pageNumLabel.textColor = [UIColor whiteColor];
        self.pageNumLabel.font = [UIFont systemFontOfSize:16.0];
        self.pageNumLabel.textColor = [UIColor whiteColor];
        self.pageNumLabel.shadowColor = [UIColor darkTextColor];
        self.pageNumLabel.shadowOffset = CGSizeMake(0.0, 1.0);
//        self.pageNumLabel.backgroundColor = [UIColor redColor];
        self.pageNumLabel.hidden = YES;
        [self addSubview:self.pageNumLabel];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.pageControl.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.pageNumLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)updatePager {

    if (_numberOfPages < 0) {
        return;
    }
    
    if (_currentPage < 0) {
        _currentPage = 0;
    } else if (_currentPage > _numberOfPages) {
        _currentPage = _numberOfPages;
    }
    
    if (_numberOfPages == 1 && _hidesForSinglePage) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
    
    if (_style == XHPageControlStyleNone) {
        self.hidden = YES;
    } else if (_numberOfPages < 9 && _style != XHPageControlStyleNum) {
        _pageControl.hidden = NO;
        _pageNumLabel.hidden = YES;
        
        _pageControl.numberOfPages = _numberOfPages;
        _pageControl.currentPage = _currentPage;
        _pageControl.hidesForSinglePage = _hidesForSinglePage;
        _pageControl.pageIndicatorTintColor = _pageIndicatorTintColor;
        _pageControl.currentPageIndicatorTintColor = _currentPageIndicatorTintColor;
    } else {
        _pageControl.hidden = YES;
        _pageNumLabel.hidden = NO;
        _pageNumLabel.text = [NSString stringWithFormat:@"%d / %d", (int)_currentPage + 1, (int)_numberOfPages];
    }
    
}

- (void)setStyle:(XHPageControlStyle)style {
    _style = style;
    [self updatePager];
}

- (void)setPageNumColor:(UIColor *)pageNumColor {
    _pageNumColor = pageNumColor;
    _pageNumLabel.textColor = pageNumColor;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self updatePager];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    [self updatePager];
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    [self updatePager];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    _hidesForSinglePage = hidesForSinglePage;
    [self updatePager];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    [self updatePager];
}


@end
