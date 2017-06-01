//
//  TUIBTextField.m
//  BathroomScale
//
//  Created by chengxianghe on 2017/5/31.
//  Copyright © 2017年 cn. All rights reserved.
//

#import "TUIBTextField.h"

@implementation TUIBTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    _placeHolderColor = placeHolderColor;
    NSString *holderText = self.placeholder;
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
    [placeholder addAttribute:NSForegroundColorAttributeName value:placeHolderColor range:NSMakeRange(0, holderText.length)];
//    [placeholder addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, holderText.length)];
    self.attributedPlaceholder = placeholder;
}

- (void)setClearButtonColor:(UIColor *)clearButtonColor {
    _clearButtonColor = clearButtonColor;
    UIButton *clearButton = [self valueForKey:@"_clearButton"];
    if (clearButton && [clearButton isKindOfClass:[UIButton class]]) {
        [clearButton setImage:[clearButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [clearButton setTintColor:clearButtonColor];
    }
}

- (void)setBorderStyleNone:(BOOL)borderStyleNone {
    _borderStyleNone = borderStyleNone;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (_borderStyleNone) {
        self.borderStyle = UITextBorderStyleNone;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIScrollView *view in self.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            CGPoint offset = view.contentOffset;
            if (offset.y != 0) {
                offset.y = 0;
                view.contentOffset = offset;
            }
            break;
        }
    }
}

@end
