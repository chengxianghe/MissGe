//
//  MLTopicCommentCellLayout.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/21.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import YYText

class MLTopicCommentCellLayout: NSObject {
    var height: CGFloat = 0
    var joke: MLTopicCommentModel!
    
    // 顶部留白
    var marginTop: CGFloat = 0 //顶部灰色留白
    var textMarginTop: CGFloat = 0 //文字上方留白
    
    // 头像
    var iconHeight: CGFloat = 0
    var iconWidth: CGFloat = 0
    var iconX: CGFloat = 0
    var iconY: CGFloat = 0
    
    var menuWidth: CGFloat = 0
    var menuHeight: CGFloat = 0
    
    var nameTextHeight: CGFloat = 0
    var nameTextLeft: CGFloat = 0
    var nameTextLayout: YYTextLayout! //文本
    
    var timeTextHeight: CGFloat = 0
    var timeTextLayout: YYTextLayout?
    
    var textTop: CGFloat = 0
    var textHeight: CGFloat = 0
    var textLayout: YYTextLayout!
    
    // 下边留白
    var textMarginBottom: CGFloat = 0
    var marginBottom: CGFloat = 0
    
    override init() {
        super.init()
    }
    
    convenience init(model: MLTopicCommentModel) {
        self.init()
        self.joke = model
        self.layout()
    }
    
    func layout() {
        marginTop = kTopicCommentCellTopMargin;
        marginBottom = kTopicCommentCellBottomMargin;
        
        textMarginTop = kTopicCommentCellContentTopMargin;
        textMarginBottom = kTopicCommentCellContentBottomMargin;
        
        textTop = kTopicCommentCellContentLeftMargin;
        textHeight = 0;
        
        // 文本排版，计算布局
        self.layoutIcon()
        self.layoutName()
        self.layoutTime()
        self.layoutText()
        
        // 计算高度
        height = 0;
        height += marginTop;
        height += textMarginTop;
        
        height += nameTextHeight;
        height += timeTextHeight;
        height += textTop;
        height += textHeight;
        height += textMarginBottom;
        
        height += kTopicCommentCellBottomImageHeight
        height += marginBottom;
    }
    
    func layoutIcon() {
        // 文本排版，计算布局
        iconHeight = kTopicCommentCellIconHeight;
        iconWidth = kTopicCommentCellIconHeight;
        iconX = kTopicCommentCellIconLeftMargin;
        iconY = kTopicCommentCellIconTopMargin;
    }
    
    func layoutName() {
        nameTextHeight = 0;
        nameTextLayout = nil;
        
        var name = joke.nickname ?? joke.uname;
        if (name == nil || name!.length == 0) {
            name = "";
        };
        
        let text = NSMutableAttributedString(string: name!)
        
        // 加入事件
        text.yy_color = kTopicCommentCellNameColor;
        text.yy_font = UIFont.systemFont(ofSize: kTopicCommentCellNameFontSize)
        
        let container = YYTextContainer(size: CGSize(width: kTopicCommentCellContentWidth - menuWidth, height: kTopicCommentCellNameHeight))
        container.maximumNumberOfRows = 1;
        nameTextLayout = YYTextLayout(container: container, text: text);
        nameTextHeight = kTopicCommentCellNameHeight;
        nameTextLeft = iconWidth + iconX * 2;
    }
    
    func layoutTime() {
        
        timeTextHeight = kTopicCommentCellTimeHeight;
        timeTextLayout = nil;
        
        let time = joke.showTime;
        if (time?.length == 0) {return};
        
        let text = NSMutableAttributedString(string: time!)
        
        text.yy_color = kTopicCommentCellTimeColor;
        text.yy_font = UIFont.systemFont(ofSize: kTopicCommentCellTimeFontSize)
        
        let container = YYTextContainer(size: CGSize(width: kTopicCommentCellContentWidth, height: kTopicCommentCellTimeHeight))
        
        container.maximumNumberOfRows = 1;
        timeTextLayout = YYTextLayout(container: container, text: text)
    }
    
    /// 文本
    func layoutText() {
        
        textHeight = 0;
        textLayout = nil;
        
        var content: String = joke.content ?? ""
        
        if joke.quote != nil {
            let beReplyName: String = joke.quote!.nickname ?? joke.quote!.uname ?? "";
            content = "@\(beReplyName) : " + content
        }
        let text = JokeHelper.textWithText(originStr: content, linkKey: kSquareLinkAtName, fontSize: kTopicCommentCellTextFontSize, textColor: kTopicCommentCellTextColor, textHighlighColor: kTopicCommentCellTextHighlightColor, highlightBackgroundColor: kTopicCommentCellTextHighlightBackgroundColor)

        if (text == nil || text!.length == 0) {return};
        
        text!.yy_lineSpacing = 5.0;
        //    text.yy_kern = @1.0;
        
        
        //    WBTextLinePositionModifier *modifier = [WBTextLinePositionModifier new];
        //    modifier.font = [UIFont fontWithName:@"Heiti SC" size:kWBCellTextFontSize];
        //    modifier.paddingTop = kWBCellPaddingText;
        //    modifier.paddingBottom = kWBCellPaddingText;
        
        let container = YYTextContainer()
        
        container.size = CGSize(width: kTopicCommentCellContentWidth, height: CGFloat.greatestFiniteMagnitude);
        //    container.linePositionModifier = modifier;
        textLayout = YYTextLayout(container: container, text: text!);
        textHeight = textLayout != nil ? (textLayout.textBoundingRect.maxY) : 0;
        //    _textHeight = [modifier heightForLineCount:_textLayout.rowCount];
    }
    
}
