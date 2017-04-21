//
//  UITextView+Placeholder.m
//  Higo
//
//  Created by sichenwang on 16/2/24.
//  Copyright © 2016年 Ryan. All rights reserved.
//

#import "UITextView+Placeholder.h"
#import <objc/runtime.h>

@implementation UITextView (Placeholder)

+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"dealloc")),
                                   class_getInstanceMethod(self.class, @selector(swizzledDealloc)));
}

+ (NSArray *)observingKeys {
    return @[@"font",
             @"textAlignment",
             @"bounds",
             @"frame",
             @"text",
             @"attributedText",
             @"textContainerInset"];
}

- (void)swizzledDealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    UILabel *label = objc_getAssociatedObject(self, @selector(placeholderLabel));
    if (label) {
        for (NSString *key in self.class.observingKeys) {
            @try {
                [self removeObserver:self forKeyPath:key];
            }
            @catch (NSException *exception) {
                
            }
        }
    }
    [self swizzledDealloc];
}

// Notification
- (void)textDidChange:(NSNotification *)notification {
    self.placeholderLabel.hidden = self.text.length;
    if (self.text.length > self.maxLength && self.markedTextRange == nil && self.maxLength > 0) {
        self.text = [self.text substringToIndex:self.maxLength];
    }
    if (self.textDidChange) {
        self.textDidChange(self.text);
    }
}

// KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    [self layoutPlaceholderLabel];
}

- (void)layoutPlaceholderLabel {
    
    self.placeholderLabel.hidden = self.text.length || self.attributedText.length;
    self.placeholderLabel.font = self.font;
    self.placeholderLabel.textAlignment = self.textAlignment;
    
    CGFloat x = self.textContainer.lineFragmentPadding + self.textContainerInset.left;
    CGFloat y = self.textContainerInset.top;
    CGFloat w = CGRectGetWidth(self.bounds) - x - self.textContainer.lineFragmentPadding - self.textContainerInset.right;
    CGFloat h = [self.placeholderLabel sizeThatFits:CGSizeMake(w, 0)].height;
    self.placeholderLabel.frame = CGRectMake(x, y, w, h);
}

- (void)listen {
    if (objc_getAssociatedObject(self, @selector(listen)) == nil) {
        objc_setAssociatedObject(self, @selector(listen), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self];
        for (NSString *key in self.class.observingKeys) {
            [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (UILabel *)placeholderLabel {
    UILabel *placeholderLabel = objc_getAssociatedObject(self, @selector(placeholderLabel));
    if (placeholderLabel == nil) {
        placeholderLabel = [[UILabel alloc] init];
        placeholderLabel.font = self.font ? : [UIFont systemFontOfSize:14];
        placeholderLabel.textColor = self.placeholderColor ? : [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
        placeholderLabel.textAlignment = NSTextAlignmentLeft;
        placeholderLabel.userInteractionEnabled = NO;
        placeholderLabel.numberOfLines = 0;
        [self addSubview:placeholderLabel];
        objc_setAssociatedObject(self, @selector(placeholderLabel), placeholderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return placeholderLabel;
}

#pragma mark - Setter

- (void)setPlaceholder:(NSString *)placeholder {
    if (self.placeholder != placeholder) {
        objc_setAssociatedObject(self, @selector(placeholder), placeholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.placeholderLabel.text = placeholder;
        [self layoutPlaceholderLabel];
        [self listen];
    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    if (self.placeholderColor != placeholderColor) {
        objc_setAssociatedObject(self, @selector(placeholderColor), placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.placeholderLabel.textColor = placeholderColor;
    }
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
    if (self.attributedPlaceholder != attributedPlaceholder) {
        objc_setAssociatedObject(self, @selector(attributedPlaceholder), attributedPlaceholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.placeholderLabel.attributedText = attributedPlaceholder;
        [self layoutPlaceholderLabel];
        [self listen];
    }
}

- (void)setMaxLength:(NSInteger)maxLength {
    if (self.maxLength != maxLength && maxLength > 0) {
        objc_setAssociatedObject(self, @selector(maxLength), @(maxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self listen];
    }
}

- (void)setTextDidChange:(void (^)(NSString *))textDidChange {
    if (self.textDidChange != textDidChange) {
        objc_setAssociatedObject(self, @selector(textDidChange), textDidChange, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self listen];
    }
}

#pragma mark - Getter

- (NSString *)placeholder {
    return objc_getAssociatedObject(self, @selector(placeholder));
}

- (UIColor *)placeholderColor {
    return objc_getAssociatedObject(self, @selector(placeholderColor));
}

- (NSAttributedString *)attributedPlaceholder {
    return objc_getAssociatedObject(self, @selector(attributedPlaceholder));
}

- (NSInteger)maxLength {
    return [objc_getAssociatedObject(self, @selector(maxLength)) integerValue];
}

- (void (^)(NSString *text))textDidChange {
    return objc_getAssociatedObject(self, @selector(textDidChange));
}

@end
