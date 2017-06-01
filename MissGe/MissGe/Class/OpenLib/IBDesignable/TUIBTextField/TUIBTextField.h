//
//  TUIBTextField.h
//  BathroomScale
//
//  Created by chengxianghe on 2017/5/31.
//  Copyright © 2017年 cn. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface TUIBTextField : UITextField

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;           ///< 圆角
@property (nonatomic, strong) IBInspectable UIColor *borderColor;           ///< 边框颜色
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;            ///< 边框宽度

@property (nonatomic, strong) IBInspectable UIColor *placeHolderColor;      ///< placeHolder color
@property (nonatomic, strong) IBInspectable UIColor *clearButtonColor;      ///< clearButton color


/**
 borderStyleNone
 现象：使用xib将一个UITextField的BorderStyle设置为UITextBorderStyleNone后，在textField中输入中文后文字会下移。使用有框的Style则不会出现这个问题。
 
 解决：
 1.xib中不设置BorderStyle，使用代码设置UITextField的BorderStyle。
 
 - (void)awakeFromNib {
 [super awakeFromNib];
 self.textField.borderStyle = UITextBorderStyleNone;
 }
 2.使用代码添加的UITextField
 */
@property (nonatomic, assign) IBInspectable BOOL borderStyleNone;       ///< borderStyleNone

@end
