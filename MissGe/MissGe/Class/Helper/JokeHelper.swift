//
//  JokeHelper.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/13.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import UIKit
import YYText
import YYWebImage
import YYCache

class JokeHelper {

    static let shareInstance = JokeHelper()

    // 微博的 At 只允许 英文数字下划线连字符，和 unicode 4E00~9FA5 范围内的中文字符，这里保持和微博一致。。
    // 目前中文字符范围比这个大
    lazy var regexAt = { () -> NSRegularExpression in
        do {
            let regex = try NSRegularExpression(pattern: "@[-_a-zA-Z0-9\\u4E00-\\u9FA5]+", options: [])
            return regex
        } catch let error as NSError {
            print(error)
        }

        return NSRegularExpression.init()
    }()

    lazy var regexTopic = { () -> NSRegularExpression in
        do {
            let regex = try NSRegularExpression(pattern: "#[^@#]+?#", options: [])
            return regex
        } catch let error as NSError {
            print(error)
        }
        return NSRegularExpression.init()
    }()

    lazy var regexEmoticon = { () -> NSRegularExpression in
        do {
            let regex = try NSRegularExpression(pattern: "\\[[^ \\[\\]]+?\\]", options: [])
            return regex
        } catch let error as NSError {
            print(error)
        }
        return NSRegularExpression.init()
    }()

    static func shortedNumberDesc(number: Int) -> String {
        // should be localized
        if (number <= 9999) {
            return String(format: "%d", number)
        }
        if (number <= 9999999) {
            return String(format: "%.1f万", Float(number) / 10000.0)
        }
        return String(format: "%d千万", number / 10000000)
    }

    static func textWithText(originStr: String?,
                             linkKey: String,
                             fontSize: CGFloat,
                             textColor: UIColor,
                             textHighlighColor: UIColor,
                             highlightBackgroundColor: UIColor) -> NSMutableAttributedString? {

        guard let originText = originStr else {
            return nil

        }

        var string = originText

        if (string.length == 0) {
            //        return [[NSMutableAttributedString alloc] init];
            string = " "
        }

        // 字体
        let font = UIFont.systemFont(ofSize: fontSize)
        // 高亮状态的背景
        let highlightBorder = YYTextBorder()
        //    highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
        highlightBorder.cornerRadius = 2
        highlightBorder.fillColor = highlightBackgroundColor
        highlightBorder.lineJoin = CGLineJoin.round

        let text =  NSMutableAttributedString.init(string: string)
        text.yy_font = font
        text.yy_color = textColor

        // 匹配 @用户名
        let atResults = JokeHelper.shareInstance.regexAt.matches(in: text.string, options: [], range: text.yy_rangeOfAll())

        for at in atResults {
            if at.range.location == NSNotFound && at.range.length <= 1 {
                continue
            }

            if text.yy_attribute(YYTextHighlightAttributeName, at: UInt(at.range.location)) == nil {
                text.yy_setColor(textHighlighColor, range: at.range)

                // 高亮状态
                let highlight = YYTextHighlight()
                highlight.setBackgroundBorder(highlightBorder)

                // 数据信息，用于稍后用户点击
                highlight.userInfo = [linkKey : (text.string as NSString).substring(with: NSMakeRange(at.range.location + 1, at.range.length - 1))]
                text.yy_setTextHighlight(highlight, range: at.range)

            }
        }

//        // 匹配 [表情]
//        let emoticonResults = JokeHelper.shareInstance.regexEmoticon.matches(in: text.string, options: [], range: text.yy_rangeOfAll())
//        
//        var emoClipLength = 0;
//        
//        for emo in emoticonResults {
//            if emo.range.location == NSNotFound && emo.range.length <= 1 {
//                continue
//            }
//            
//            var range = emo.range;
//            range.location = range.location - emoClipLength
//            
//            if text.yy_attribute(YYTextHighlightAttributeName, at: UInt(range.location)) == nil {
//                continue
//            }
//            
//            if text.yy_attribute(YYTextAttachmentAttributeName, at: UInt(range.location)) == nil {
//                continue
//            }
//            
//            let emoString = (text.string as NSString).substring(with: range)
//            
////            NSString *imagePath = [JokeHelper emoticonDic][emoString];
////            UIImage *image = [JokeHelper imageWithPath:imagePath];
////            //        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
////            if (!image) continue;
////            
////            NSAttributedString *emoText = [NSAttributedString yy_attachmentStringWithEmojiImage:image fontSize:fontSize];
////            [text replaceCharactersInRange:range withAttributedString:emoText];
////            emoClipLength += range.length - 1;
//        }

        return text
    }

    static let imageCache: YYMemoryCache = YYMemoryCache(missge: "MissGeImageCache")

    func setddd(ddd: YYWebImageTransformBlock) {

    }

    lazy var avatarImageManager = { () -> YYWebImageManager in
        let cachesPath = kCachesPath()
        let path = cachesPath!.appending("/joke.avatar")
        let cache = YYImageCache(path: path)
        let manager = YYWebImageManager.init(cache: cache, queue: YYWebImageManager.shared().queue)

        manager.sharedTransformBlock = { (image: UIImage?, url) -> UIImage? in
            if image == nil {
                return image
            }
            let w = max(image!.size.width/2, image!.size.height/2)
            return image!.yy_image(byRoundCornerRadius: ceil(w))
        }
        return manager
    }()

}

extension YYMemoryCache {
    convenience init(name: String) {
        self.init()
        self.name = name
    }

    convenience init(missge name: String) {
        self.init()
        self.name = name
        self.shouldRemoveAllObjectsOnMemoryWarning = false
        self.shouldRemoveAllObjectsWhenEnteringBackground = false
    }
}
