//
//  UITextView+Placeholder.h
//  Higo
//
//  Created by sichenwang on 16/2/24.
//  Copyright © 2016年 Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Placeholder)

@property (nonatomic, copy)IBInspectable NSString *placeholder;

@property (nonatomic, strong)IBInspectable UIColor *placeholderColor;

@property (nonatomic, strong) NSAttributedString *attributedPlaceholder;

@property (nonatomic, assign)IBInspectable NSInteger maxLength;

@property (nonatomic, copy) void (^textDidChange)(NSString *text);

@end
