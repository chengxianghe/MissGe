//
//  MLTopicCommentCell.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/21.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import YYText
import YYWebImage


let kTopicCommentCellTopMargin: CGFloat = 0.0
let kTopicCommentCellBottomMargin: CGFloat = 0.0
let kTopicCommentCellLeftMargin: CGFloat = 8.0
let kTopicCommentCellRightMargin: CGFloat = 8.0

let kTopicCommentCellContentTopMargin: CGFloat = 10.0
let kTopicCommentCellContentLeftMargin: CGFloat = 6.0
let kTopicCommentCellContentRightMargin: CGFloat = 6.0
let kTopicCommentCellContentBottomMargin: CGFloat = 6.0

let kTopicCommentCellPaddingPic: CGFloat = 4.0 // 图片间隔

let kTopicCommentCellNameHeight: CGFloat = 18.0   // 名字高度
let kTopicCommentCellNameFontSize: CGFloat = 14.0      // 名字字体大小
let kTopicCommentCellNameColor = kColorFromHexA(0x0099ff) // 名字字体颜色

let kTopicCommentCellTimeHeight: CGFloat = 18.0   // 时间高度
let kTopicCommentCellTimeFontSize: CGFloat = 12.0      // 时间字体大小
let kTopicCommentCellTimeColor = kColorFromHexA(0x333333) // 时间字体颜色


let kTopicCommentCellIconTopMargin: CGFloat = 8.0
let kTopicCommentCellIconLeftMargin = kTopicCommentCellContentLeftMargin
let kTopicCommentCellIconHeight = (kTopicCommentCellNameHeight + kTopicCommentCellTimeHeight)

let kTopicCommentCellLikeButtonLeftMargin: CGFloat = 10.0
let kTopicCommentCellLikeButtonMiddleMargin: CGFloat = 5.0
let kTopicCommentCellLikeImageWidth: CGFloat = 20.0

let kTopicCommentCellBorderWidth: CGFloat = 4.0

let kTopicCommentCellWidth = (kScreenWidth - kTopicCommentCellLeftMargin - kTopicCommentCellRightMargin) // cell背景宽度

let kTopicCommentCellContentWidth = (kTopicCommentCellWidth - kTopicCommentCellContentLeftMargin - kTopicCommentCellContentRightMargin) // text 内容宽度

let kTopicCommentCellToolbarHeight: CGFloat = 35

let kTopicCommentCellLikeWidth: CGFloat = 60           // 喜欢按钮 宽度
let kTopicCommentCellFavoriteWidth: CGFloat = 30       // 收藏按钮 宽度
let kTopicCommentCellCommentWidth: CGFloat = 40        // 评论按钮 宽度
let kTopicCommentCellShareWidth: CGFloat = 30          // 分享按钮 宽度


let kTopicCommentCellLikeHeight: CGFloat = 24   // 喜欢高度
let kTopicCommentCellLikeFontSize: CGFloat = 12      // 喜欢字体大小
let kTopicCommentCellLikeNormalColor = kColorFromHexA(0x929292) // 喜欢一般文本色
let kTopicCommentCellLikeHighlightColor = kColorFromHexA(0xdf422d) // 喜欢高亮文本色

let kTopicCommentCellTextFontSize: CGFloat = 15      // 内容字体大小
let kTopicCommentCellTextColor = UIColor.black // 内容字体颜色

let kTopicCommentCellBackgroundColor = kColorFromHexA(0xf2f2f2)    // Cell背景灰色
let kTopicCommentCellHighlightColor = kColorFromHexA(0xf0f0f0)     // Cell高亮时灰色
let kTopicCommentCellLineColor = UIColor(white: 0.000, alpha: 0.09) //线条颜色
let kTopicCommentCellTextHighlightColor = kColorFromHexA(0x527ead) // Link 文本色
let kTopicCommentCellTextHighlightBackgroundColor = kColorFromHexA(0xbfdffe) // Link 点击背景色

let kTopicCommentCellBottomImageWidth: CGFloat = kTopicCommentCellWidth   // cell底部图片宽度
let kTopicCommentCellBottomImageHeight: CGFloat = kScreenOneScale   // cell底部图片高度

class MLTopicCommentCell: TUBaseTableViewCell {

    var layout: MLTopicCommentCellLayout!
    var statusView: MLTopicCommentCellBodyView!
    var delegate: MLTopicCommentCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.none;
        self.backgroundView?.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        statusView = MLTopicCommentCellBodyView();
        statusView.cell = self;
        self.contentView.addSubview(statusView);
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setInfo(_ layout: MLTopicCommentCellLayout) {
        self.layout = layout;
        self.setHeight(layout.height)
        self.contentView.setHeight(layout.height)
        statusView.setInfo(layout)
    }
    
    class func height(_ layout: MLTopicCommentCellLayout) -> CGFloat {
        return layout.height
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol MLTopicCommentCellDelegate {
    func cell(_ cell: MLTopicCommentCell, didClickTextInLabel label: YYLabel!, textRange: NSRange);
    func cell(_ cell: MLTopicCommentCell, didClickContentWithLongPress longPress: Bool);
    
    func cellDidClickLike(_ cell: MLTopicCommentCell);
    func cellDidClickOther(_ cell: MLTopicCommentCell);
    func cellDidClickName(_ cell: MLTopicCommentCell);
    func cellDidClickIcon(_ cell: MLTopicCommentCell);
    
}

class MLTopicCommentCellBodyView: UIView {
    var contentView: UIView!
    var bestImageView: UIImageView!
    var bottomImageView: UIImageView!
    var iconImageView: YYAnimatedImageView!
//    var otherButton: UIButton!
    var nameLabel: YYLabel!
    var timeLabel: YYLabel!
    var textLabel: YYLabel!
    var layout: MLTopicCommentCellLayout!
    var cell: MLTopicCommentCell!
    
    override init(frame: CGRect) {
        var frame = frame;
        if (frame.size.width == 0 && frame.size.height == 0) {
            frame.size.width = kScreenWidth;
            frame.size.height = 1;
        }
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.isExclusiveTouch = true;
        
        
        contentView = UIView()
        contentView.setWidth(kTopicCommentCellWidth)
        contentView.setHeight(1)
        contentView.setLeft(kTopicCommentCellLeftMargin)
        contentView.backgroundColor = UIColor.white
        self.addSubview(contentView)
        
        nameLabel = YYLabel() ;
        //    nameLabel.setLeft(kTopicCommentCellTextLeftMargin;
        nameLabel.setWidth(kTopicCommentCellContentWidth)
        nameLabel.textAlignment = NSTextAlignment.left;
        nameLabel.displaysAsynchronously = true;
        nameLabel.ignoreCommonProperties = true;
        nameLabel.fadeOnAsynchronouslyDisplay = false;
        nameLabel.fadeOnHighlight = false;
        nameLabel.textTapAction = {[unowned self] (containerView: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) in
            self.cell.delegate?.cellDidClickName(self.cell)
        };
        contentView.addSubview(nameLabel)
        
        timeLabel = YYLabel() ;
        timeLabel.setTop(nameLabel.frame.maxY)
        timeLabel.setLeft(kTopicCommentCellContentLeftMargin);
        timeLabel.setWidth(kTopicCommentCellContentWidth);
        timeLabel.textAlignment = NSTextAlignment.left;
        timeLabel.displaysAsynchronously = true;
        timeLabel.ignoreCommonProperties = true;
        timeLabel.fadeOnAsynchronouslyDisplay = false;
        timeLabel.fadeOnHighlight = false;
        contentView.addSubview(timeLabel)
        
        textLabel = YYLabel() ;
        textLabel.setTop(timeLabel.frame.maxY);
        textLabel.setLeft(kTopicCommentCellContentLeftMargin);
        textLabel.setWidth(kTopicCommentCellContentWidth);
        textLabel.textVerticalAlignment = YYTextVerticalAlignment.top;
        textLabel.displaysAsynchronously = true;
        textLabel.ignoreCommonProperties = true;
        textLabel.fadeOnAsynchronouslyDisplay = false;
        textLabel.fadeOnHighlight = false;
        
        textLabel.highlightTapAction = {[unowned self] (containerView: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) in
            self.cell.delegate?.cell(self.cell, didClickTextInLabel: containerView as! YYLabel, textRange: range)
        };
        contentView.addSubview(textLabel)
        
        
        let imageView = YYAnimatedImageView()
        imageView.clipsToBounds = true;
        imageView.isExclusiveTouch = true;
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapIcon(sender:)))

        imageView.isUserInteractionEnabled = true;
        imageView.addGestureRecognizer(tap)
        
        contentView.addSubview(imageView)
        iconImageView = imageView;
        
//        let likeHeight = kTopicCommentCellLikeHeight;
        
//        otherButton = UIButton.init(type: UIButtonType.Custom)
//        otherButton.setTitle("举报", forState: .Normal)
//        otherButton.titleLabel?.font = UIFont.systemFontOfSize(kTopicCommentCellTimeFontSize)
//        otherButton.setTitleColor(kTopicCommentCellTimeColor, forState: .Normal)
//        otherButton.exclusiveTouch = true;
//        otherButton.frame.size = CGSizeMake(YYTextCGFloatPixelRound(34), likeHeight);
//        otherButton.frame.origin.y = kTopicCommentCellTopMargin
//        otherButton.setRight(kScreenWidth - kTopicCommentCellRightMargin - kTopicCommentCellContentRightMargin)
//        contentView.addSubview(otherButton)
//        
//        otherButton.addBlockForControlEvents(UIControlEvents.TouchUpInside) { (sender) in
//            self.cell.delegate?.cellDidClickOther(self.cell)
//        }
        
        
        bottomImageView = UIImageView(image: UIImage(named: "dotted_line_320x0_"))
        bottomImageView.frame.origin.x = kTopicCommentCellLeftMargin
        bottomImageView.frame.size = CGSize(width: kTopicCommentCellBottomImageWidth, height: kTopicCommentCellBottomImageHeight)
        self.addSubview(bottomImageView)
        
        bestImageView = UIImageView(image: UIImage(named: "social_best_reply_flag_40x40_"))
        bestImageView.frame.size = CGSize(width: kSquareCellBestImageWidth, height: kSquareCellBestImageHeight)
        bestImageView.frame.origin.x = contentView.frame.width - kSquareCellBestImageWidth
        bestImageView.isHidden = true
        contentView.addSubview(bestImageView)
    }
    
    
    func tapIcon(sender: UITapGestureRecognizer) {
        //let sender = sender as! UITapGestureRecognizer
        if (sender.state == UIGestureRecognizerState.ended) {
            let p = sender.location(in: iconImageView)
            if (iconImageView.bounds.contains(p)) {
                self.cell.delegate?.cellDidClickIcon(self.cell)
            }
        }
    }
    
    func setInfo(_ layout: MLTopicCommentCellLayout) {
        self.layout = layout;
        
        self.setHeight(layout.height);
        contentView.setTop(layout.marginTop);
        contentView.setHeight(layout.height - layout.marginTop - layout.marginBottom - kTopicCommentCellBottomImageHeight);
        
        self._setImageView()
        
        var top: CGFloat = layout.textMarginTop;
        nameLabel.setTop(top);
        nameLabel.setLeft(layout.nameTextLeft);
        nameLabel.setWidth(layout.nameTextLayout.textBoundingSize.width)
        nameLabel.setHeight(layout.nameTextHeight);
        nameLabel.textLayout = layout.nameTextLayout;
        top += layout.nameTextHeight;
        
        timeLabel.setTop(top);
        timeLabel.setLeft(layout.nameTextLeft);
        timeLabel.setWidth(layout.timeTextLayout?.textBoundingSize.width ?? 0)
        timeLabel.setHeight(layout.timeTextHeight);
        timeLabel.textLayout = layout.timeTextLayout;
        top += layout.timeTextHeight;
        
        top += layout.textTop;
        textLabel.setTop(top);
        textLabel.setHeight(layout.textHeight);
        textLabel.textLayout = layout.textLayout;
        top += layout.textHeight;
        
        top += layout.textMarginBottom
        
        //        top += layout.toolbarHeight
        bottomImageView.frame.origin.y = layout.height - kTopicCommentCellBottomImageHeight - layout.marginBottom
        
        if layout.joke.best_reply {
            bestImageView.isHidden = false
            contentView.backgroundColor = kColorFromHexA(0xFF99CC)
        } else {
            bestImageView.isHidden = true
            contentView.backgroundColor = UIColor.white
        }
    }
    
    func _setImageView() {
        
        let imageView = self.iconImageView;
        imageView?.frame = CGRect(x: layout.iconX, y: layout.iconY, width: layout.iconWidth, height: layout.iconHeight);
        imageView?.isHidden = false;
        imageView?.layer.removeAnimation(forKey: "contents")
        
        imageView?.yy_setImage(with: layout.joke.isAnonymous ? nil : layout.joke.uface,
                                     placeholder: UIImage(named: layout.joke.randomImage),
                                     options: YYWebImageOptions.avoidSetImage,
                                     manager: JokeHelper.shareInstance.avatarImageManager,
                                     progress: nil,
                                     transform: nil) { (image, url, from, stage, error) in
                                        if (image != nil && stage == YYWebImageStage.finished) {
                                            imageView?.image = image;
                                            if (from != YYWebImageFromType.memoryCacheFast) {
                                                let transition = CATransition()
                                                transition.duration = 0.15;
                                                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut);
                                                transition.type = kCATransitionFade;
                                                imageView?.layer.add(transition, forKey: "contents")
                                            }
                                        }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

