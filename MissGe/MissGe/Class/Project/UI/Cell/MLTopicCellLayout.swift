//
//  MLTopicCellLayout.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/20.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import YYText

class MLTopicCellLayout: NSObject {

    var height: CGFloat = 0
    var joke: MLSquareModel!

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

    //@property (nonatomic, assign) CGFloat timeTextWidth;
    var timeTextHeight: CGFloat = 0
    var timeTextLayout: YYTextLayout?

    var textTop: CGFloat = 0
    var textHeight: CGFloat = 0
    var textLayout: YYTextLayout!

    // 图片
    var picViewHeight: CGFloat = 0
    var picSize = CGSize.zero

    // 工具栏
    var toolbarHeight: CGFloat = 0
    var toolbarCommentTextWidth: CGFloat = 0
    var toolbarCommentTextLayout: YYTextLayout!
    var toolbarLikeTextWidth: CGFloat = 0
    var toolbarLikeTextLayout: YYTextLayout!

    // 下边留白
    var textMarginBottom: CGFloat = 0
    var marginBottom: CGFloat = 0

    override init() {
        super.init()
    }

    convenience init(model: MLSquareModel) {
        self.init()
        self.joke = model
        self.layout()
    }

    func layout() {
        marginTop = kSquareCellTopMargin
        marginBottom = kSquareCellBottomMargin

        textMarginTop = kSquareCellTextTopMargin
        textMarginBottom = kSquareCellTextBottomMargin

        textTop = kSquareCellTextLeftMargin
        textHeight = 0

        // 文本排版，计算布局
        self.layoutIcon()
        self.layoutLike()
        self.layoutName()
        self.layoutTime()
        self.layoutText()
        self.layoutPics()
        self.layoutToolbar()

        // 计算高度
        height = 0
        height += marginTop
        height += textMarginTop

        height += nameTextHeight
        height += timeTextHeight
        height += textTop
        height += textHeight
        height += textMarginBottom

        height += picViewHeight
        height += picViewHeight == 0 ? 0 : kSquareCellPaddingPic
        height += toolbarHeight
        height += kSquareCellBottomImageHeight
        height += marginBottom
    }

    func layoutIcon() {
        // 文本排版，计算布局
        iconHeight = kSquareCellIconHeight
        iconWidth = kSquareCellIconHeight
        iconX = kSquareCellIconLeftMargin
        iconY = kSquareCellIconTopMargin
    }

    func layoutName() {
        nameTextHeight = 0
        nameTextLayout = nil

        var text = NSMutableAttributedString(string: "")

        if joke.isAnonymous {
            text = NSMutableAttributedString(string: "匿名")
        } else {
            let name = joke.nickname ?? joke.uname
            if (name != nil || name!.length > 0) {
                text = NSMutableAttributedString(string: name!)
            }
        }

        // 加入事件
        text.yy_color = kSquareCellNameColor
        text.yy_font = UIFont.systemFont(ofSize: kSquareCellNameFontSize)

        let container = YYTextContainer(size: CGSize(width: kSquareCellContentWidth - menuWidth, height: kSquareCellNameHeight))
        container.maximumNumberOfRows = 1
        nameTextLayout = YYTextLayout(container: container, text: text)
        nameTextHeight = kSquareCellNameHeight
        nameTextLeft = iconWidth + iconX * 2
    }

    func layoutTime() {

        timeTextHeight = kSquareCellTimeHeight
        timeTextLayout = nil

        let time = joke.showTime
        if (time == nil || time?.length == 0) {return}

        let text = NSMutableAttributedString(string: time!)

        text.yy_color = kSquareCellTimeColor
        text.yy_font = UIFont.systemFont(ofSize: kSquareCellTimeFontSize)

        let container = YYTextContainer(size: CGSize(width: kSquareCellContentWidth, height: kSquareCellTimeHeight))

        container.maximumNumberOfRows = 1
        timeTextLayout = YYTextLayout(container: container, text: text)
    }

    func layoutLike() {

        menuWidth = 30
        menuHeight = 10
    }

    func layoutToolbar() {

        let kJokeCellToolbarHeight: CGFloat = 35
        // should be localized
        let font = UIFont.systemFont(ofSize: 12.0)
        let container = YYTextContainer.init(size: CGSize(width: kScreenWidth, height: kJokeCellToolbarHeight))
        container.maximumNumberOfRows = 1

        let commentText = NSMutableAttributedString(string: (joke.replies as NSString).integerValue <= 0 ? "评论" : JokeHelper.shortedNumberDesc(number: (joke.replies as NSString).integerValue))
        commentText.yy_font = font
        commentText.yy_color =  kColorFromHexA(0x929292)
        toolbarCommentTextLayout = YYTextLayout(container: container, text: commentText)

        toolbarCommentTextWidth = YYTextCGFloatPixelRound(toolbarCommentTextLayout.textBoundingRect.size.width)

        let likeText = NSMutableAttributedString(string: (joke.like as NSString).integerValue <= 0 ? "赞" : JokeHelper.shortedNumberDesc(number: (joke.like as NSString).integerValue))

        likeText.yy_font = font
        likeText.yy_color = joke.isLike ? kColorFromHexA(0xdf422d) : kColorFromHexA(0x929292)
        toolbarLikeTextLayout = YYTextLayout(container: container, text: likeText)
        toolbarLikeTextWidth = YYTextCGFloatPixelRound(toolbarLikeTextLayout.textBoundingRect.size.width)

        toolbarHeight = kJokeCellToolbarHeight

    }

    /// 文本
    func layoutText() {

        textHeight = 0
        textLayout = nil

        let text = JokeHelper.textWithText(originStr: joke.content, linkKey: kSquareLinkAtName, fontSize: kSquareCellTextFontSize, textColor: kSquareCellTextColor, textHighlighColor: kTopicCommentCellTextHighlightColor, highlightBackgroundColor: kTopicCommentCellTextHighlightBackgroundColor)

        if (text == nil || text!.length == 0) {return}

        text!.yy_lineSpacing = 5.0
        //    text.yy_kern = @1.0;

        //    WBTextLinePositionModifier *modifier = [WBTextLinePositionModifier new];
        //    modifier.font = [UIFont fontWithName:@"Heiti SC" size:kWBCellTextFontSize];
        //    modifier.paddingTop = kWBCellPaddingText;
        //    modifier.paddingBottom = kWBCellPaddingText;

        let container = YYTextContainer()
        container.size = CGSize(width: kSquareCellContentWidth, height: CGFloat.greatestFiniteMagnitude)
        //    container.linePositionModifier = modifier;
        textLayout = YYTextLayout(container: container, text: text!)
        textHeight = textLayout != nil ? (textLayout.textBoundingRect.maxY) : 0
        //    _textHeight = [modifier heightForLineCount:_textLayout.rowCount];
    }

    func layoutPics() {
        picViewHeight = 0
        picSize = CGSize.zero

        var len1_3 = (kSquareCellContentWidth + kSquareCellPaddingPic) / 3 - kSquareCellPaddingPic
        len1_3 = YYTextCGFloatPixelRound(len1_3)

        if joke.imglist != nil && joke.imglist!.count > 0 {
            switch (joke.imglist!.count) {
            case 1:
                let pic = joke.imglist!.first!
                let temWidth = CGFloat((pic.width as NSString).floatValue)
                let temHeight = CGFloat((pic.height as NSString).floatValue)

                if (temWidth < 1 || temHeight < 1) {
                    var maxLen: CGFloat = kSquareCellContentWidth / 2.0
                    maxLen = YYTextCGFloatPixelRound(maxLen)
                    picSize = CGSize(width: maxLen, height: maxLen)
                    picViewHeight = maxLen
                } else {
                    let maxLen: CGFloat = len1_3 * 2 + kSquareCellPaddingPic
                    if (temWidth < temHeight) {
                        picSize.width = temWidth / temHeight * maxLen
                        picSize.height = maxLen
                    } else {
                        picSize.width = maxLen
                        picSize.height = temHeight / temWidth * maxLen
                    }
                    picSize = YYTextCGSizePixelRound(picSize)
                    picViewHeight = picSize.height
                }
            case 2:
                fallthrough
            case 3:
                picSize = CGSize(width: len1_3, height: len1_3)
                picViewHeight = len1_3
            case 4:
                fallthrough
            case 5:
                fallthrough
            case 6:
                picSize = CGSize(width: len1_3, height: len1_3)
                picViewHeight = len1_3 * 2 + kSquareCellPaddingPic
            default:
                // 7, 8, 9
                picSize = CGSize(width: len1_3, height: len1_3)
                picViewHeight = len1_3 * 3 + kSquareCellPaddingPic * 2
            }

            return
        }

        if joke.thumb_small == nil || joke.thumb_small!.count == 0 {
            return
        }

        switch (joke.thumb_small!.count) {
        case 1:
            picSize = CGSize(width: len1_3, height: len1_3 * 1.5)
            picViewHeight = len1_3 * 1.5
        case 2:
            fallthrough
        case 3:
            picSize = CGSize(width: len1_3, height: len1_3)
            picViewHeight = len1_3
        case 4:
        fallthrough
        case 5:
        fallthrough
        case 6:
            picSize = CGSize(width: len1_3, height: len1_3)
            picViewHeight = len1_3 * 2 + kSquareCellPaddingPic
        default:
            // 7, 8, 9
            picSize = CGSize(width: len1_3, height: len1_3)
            picViewHeight = len1_3 * 3 + kSquareCellPaddingPic * 2
        }
    }

}
