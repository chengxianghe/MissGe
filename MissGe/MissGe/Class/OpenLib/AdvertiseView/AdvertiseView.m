//
//  AdvertiseView.m
//  zhibo
//
//  Created by 周焕强 on 16/5/17.
//  Copyright © 2016年 zhq. All rights reserved.
//

#import "AdvertiseView.h"

#define kscreenWidth [UIScreen mainScreen].bounds.size.width
#define kscreenHeight [UIScreen mainScreen].bounds.size.height
#define kUserDefaults [NSUserDefaults standardUserDefaults]

@interface AdvertiseView()

@property (nonatomic, strong) UIImageView *adView;

@property (nonatomic, strong) UIButton *countBtn;
@property (nonatomic, strong) UIButton *saveBtn;

@property (nonatomic, strong) NSTimer *countTimer;

@property (nonatomic, assign) int count;

@property (nonatomic, copy) AdBlock dismissBlock;
@property (nonatomic, copy) AdBlock saveBlock;


@end

// 广告显示的时间
static int const showtime = 3;

@implementation AdvertiseView

- (void)dealloc {
    NSLog(@"%s", __func__);
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [self removeFromSuperview];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        // 1.广告图片
        _adView = [[UIImageView alloc] initWithFrame:frame];
        _adView.userInteractionEnabled = YES;
        _adView.contentMode = UIViewContentModeScaleAspectFill;
        _adView.clipsToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToAd)];
        [_adView addGestureRecognizer:tap];

        // 2.跳过按钮
        CGFloat btnW = 60;
        CGFloat btnH = 30;
        _countBtn = [[UIButton alloc] initWithFrame:CGRectMake(kscreenWidth - btnW - 24, btnH, btnW, btnH)];
        [_countBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_countBtn setTitle:[NSString stringWithFormat:@"跳过%d", showtime] forState:UIControlStateNormal];
        _countBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_countBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _countBtn.backgroundColor = [UIColor colorWithRed:38 /255.0 green:38 /255.0 blue:38 /255.0 alpha:0.6];
        _countBtn.layer.cornerRadius = 4;
        
        // 2.保存按钮
        _saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(24, kscreenHeight - btnH - 20, btnW, btnH)];
        [_saveBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
        [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveBtn.backgroundColor = [UIColor colorWithRed:38 /255.0 green:38 /255.0 blue:38 /255.0 alpha:0.6];
        _saveBtn.layer.cornerRadius = 4;
        
        [self addSubview:_adView];
        [self addSubview:_countBtn];
        [self addSubview:_saveBtn];

    }
    return self;
}

- (void)setAdDismissBlock:(AdBlock)dismissBlock saveBlock:(AdBlock)saveBlock {
    _dismissBlock = dismissBlock;
    _saveBlock = saveBlock;
}

- (void)setFilePath:(NSString *)filePath
{
    _filePath = filePath;
    _adView.image = [UIImage imageWithContentsOfFile:filePath];
}

- (void)pushToAd{
    
    [self dismiss];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:pushNotiName object:nil userInfo:nil];
}

- (void)countDown
{
    _count --;
    [_countBtn setTitle:[NSString stringWithFormat:@"跳过%d",_count] forState:UIControlStateNormal];
    if (_count == 0) {

        [self dismiss];
    }
}

- (void)show
{
    [self startTimer];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

// 定时器倒计时
- (void)startTimer
{
    _count = showtime;
    self.countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.countTimer forMode:NSRunLoopCommonModes];
}

// 移除广告页面
- (void)dismiss
{
    [self.countTimer invalidate];
    self.countTimer = nil;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        if (_dismissBlock) {
            _dismissBlock();
        }
        [self removeFromSuperview];
    }];

}

// 保存图片
- (void)saveImage {
    if (_saveBlock) {
        _saveBlock();
    }
}

@end
