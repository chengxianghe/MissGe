//
//  XHPageControlView.h
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/23.
//  Copyright © 2016年 cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XHPageControlStyle) {
    XHPageControlStyleNum,
    XHPageControlStyleDot,
    XHPageControlStyleAuto,
    XHPageControlStyleNone
};

@interface XHPageControlView : UIView

@property (nonatomic, assign) XHPageControlStyle style;
@property(nullable, nonatomic,strong) UIColor *pageNumColor;

@property(nonatomic, assign) NSInteger numberOfPages;          // default is 0
@property(nonatomic, assign) NSInteger currentPage;            // default is 0. value pinned to 0..numberOfPages-1
@property(nonatomic, assign) BOOL hidesForSinglePage;          // hide the the indicator if there is only one page. default is NO
@property(nullable, nonatomic,strong) UIColor *pageIndicatorTintColor;
@property(nullable, nonatomic,strong) UIColor *currentPageIndicatorTintColor;

@end
