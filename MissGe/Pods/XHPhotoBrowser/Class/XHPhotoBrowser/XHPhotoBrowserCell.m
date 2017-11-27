//
//  YYPhotoGroupCell.m
//  YYKitDemo
//
//  Created by chengxianghe on 15/12/26.
//  Copyright © 2015年 ibireme. All rights reserved.
//

#import "XHPhotoBrowserCell.h"
#import "XHPhotoItem.h"
#import "XHPhotoBrowserHeader.h"

static NSString *const kLayerAnimationKey = @"yytest.fade";

@implementation XHPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.bouncesZoom = YES;
        self.maximumZoomScale = 3;
        self.multipleTouchEnabled = YES;
        self.alwaysBounceVertical = NO;
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.frame = frame;
        
        _imageContainerView = [UIView new];
        _imageContainerView.clipsToBounds = YES;
        [self addSubview:_imageContainerView];
        
        _imageView = [YYAnimatedImageView new];
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        [_imageContainerView addSubview:_imageView];
        
        _progressLayer = [CAShapeLayer layer];
        CGRect progressFrame = _progressLayer.frame;
        progressFrame.size = CGSizeMake(40, 40);
        _progressLayer.frame = progressFrame;
        _progressLayer.cornerRadius = 20;
        _progressLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:(40 / 2 - 7)];
        _progressLayer.path = path.CGPath;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.lineWidth = 4;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 0;
        _progressLayer.hidden = YES;
        [self.layer addSublayer:_progressLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = _progressLayer.frame;
    frame.origin.x = self.xh_width / 2 - frame.size.width * 0.5;
    frame.origin.y = self.xh_height / 2 - frame.size.height * 0.5;
    _progressLayer.frame = frame;
}

- (void)setItem:(XHPhotoItem *)item {
    if (_item == item) return;
    _item = item;
    _itemDidLoad = NO;
    
    [self setZoomScale:1.0 animated:NO];
    self.maximumZoomScale = 1;
    [_imageView yy_cancelCurrentImageRequest];
    [_imageView.layer removeAnimationForKey:kLayerAnimationKey];
    
    _progressLayer.hidden = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [CATransaction commit];
    
    if (!_item) {
        _imageView.image = nil;
        return;
    }
    
    @weakify(self);
    [_imageView yy_setImageWithURL:item.largeImageURL placeholder:item.thumbImage options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        @strongify(self);
        if (!self) return;
        CGFloat progress = receivedSize / (float)expectedSize;
        progress = progress < 0.01 ? 0.01 : progress > 1 ? 1 : progress;
        if (isnan(progress)) progress = 0;
        self.progressLayer.hidden = NO;
        self.progressLayer.strokeEnd = progress;
    } transform:nil completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        @strongify(self);
        if (!self) return;
        if (stage == YYWebImageStageFinished) {
            self.progressLayer.hidden = YES;
            
            self.maximumZoomScale = 3;
            if (image) {
                self->_itemDidLoad = YES;
                
                [self resizeSubviewSize];
                
                CATransition *transition = [CATransition animation];
                transition.duration = 0.1;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                transition.type = kCATransitionFade;
                [self.imageView.layer addAnimation:transition forKey:kLayerAnimationKey];
            }
        } else if (stage == YYWebImageStageCancelled) {
            self.progressLayer.hidden = YES;
        }
        
    }];
    [self resizeSubviewSize];
}

- (void)resizeSubviewSize {
    _imageContainerView.xh_origin = CGPointZero;
    _imageContainerView.xh_width = self.xh_width;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.xh_height / self.xh_width) {
        _imageContainerView.xh_height = floor(image.size.height / (image.size.width / self.xh_width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.xh_width;
        if (height < 1 || isnan(height)) height = self.xh_height;
        height = floor(height);
        _imageContainerView.xh_height = height;
        _imageContainerView.xh_centerY = self.xh_height / 2;
    }
    if (_imageContainerView.xh_height > self.xh_height && _imageContainerView.xh_height - self.xh_height <= 1) {
        _imageContainerView.xh_height = self.xh_height;
    }
    self.contentSize = CGSizeMake(self.xh_width, MAX(_imageContainerView.xh_height, self.xh_height));
    [self scrollRectToVisible:self.bounds animated:NO];
    
    if (_imageContainerView.xh_height <= self.xh_height) {
        self.alwaysBounceVertical = NO;
    } else {
        self.alwaysBounceVertical = YES;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _imageView.frame = _imageContainerView.bounds;
    [CATransaction commit];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = _imageContainerView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}


@end
