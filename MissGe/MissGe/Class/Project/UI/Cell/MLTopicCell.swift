//
//  MLTopicCell.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/20.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import YYText
import YYWebImage
import SVProgressHUD

let kSquareCellTopMargin: CGFloat = 8.0
let kSquareCellBottomMargin: CGFloat = 0.0
let kSquareCellLeftMargin: CGFloat = 8.0
let kSquareCellRightMargin: CGFloat = 8.0

let kSquareCellTextTopMargin: CGFloat = 10.0
let kSquareCellTextLeftMargin: CGFloat = 6.0
let kSquareCellTextRightMargin: CGFloat = 6.0
let kSquareCellTextBottomMargin: CGFloat = 6.0

let kSquareCellPaddingPic: CGFloat = 4.0 // 图片间隔

let kSquareCellNameHeight: CGFloat = 18.0   // 名字高度
let kSquareCellNameFontSize: CGFloat = 14.0      // 名字字体大小
let kSquareCellNameColor = kColorFromHexA(0x0099ff) // 名字字体颜色

let kSquareCellTimeHeight: CGFloat = 18.0   // 时间高度
let kSquareCellTimeFontSize: CGFloat = 12.0      // 时间字体大小
let kSquareCellTimeColor = kColorFromHexA(0x333333) // 时间字体颜色


let kSquareCellIconTopMargin: CGFloat = 8.0
let kSquareCellIconLeftMargin = kSquareCellTextLeftMargin
let kSquareCellIconHeight = (kSquareCellNameHeight + kSquareCellTimeHeight)

let kSquareCellLikeButtonLeftMargin: CGFloat = 10.0
let kSquareCellLikeButtonMiddleMargin: CGFloat = 5.0
let kSquareCellLikeImageWidth: CGFloat = 20.0

let kSquareCellBorderWidth: CGFloat = 4.0

let kSquareCellWidth = (kScreenWidth - kSquareCellLeftMargin - kSquareCellRightMargin) // cell背景宽度

let kSquareCellContentWidth = (kSquareCellWidth - kSquareCellTextLeftMargin - kSquareCellTextRightMargin) // text 内容宽度

let kSquareCellToolbarHeight: CGFloat = 35

let kSquareCellLikeWidth: CGFloat = 60           // 喜欢按钮 宽度
let kSquareCellFavoriteWidth: CGFloat = 30       // 收藏按钮 宽度
let kSquareCellCommentWidth: CGFloat = 40        // 评论按钮 宽度
let kSquareCellShareWidth: CGFloat = 30          // 分享按钮 宽度


let kSquareCellLikeHeight: CGFloat = 24   // 喜欢高度
let kSquareCellLikeFontSize: CGFloat = 12      // 喜欢字体大小
let kSquareCellLikeNormalColor = kColorFromHexA(0x929292) // 喜欢一般文本色
let kSquareCellLikeHighlightColor = kColorFromHexA(0xdf422d) // 喜欢高亮文本色

let kSquareCellTextFontSize: CGFloat = 15      // 内容字体大小
let kSquareCellTextColor = UIColor.black // 内容字体颜色

let kSquareCellBackgroundColor = kColorFromHexA(0xf2f2f2)    // Cell背景灰色
let kSquareCellHighlightColor = kColorFromHexA(0xf0f0f0)     // Cell高亮时灰色
let kSquareCellLineColor = UIColor(white: 0.000, alpha: 0.09) //线条颜色
let kSquareCellTextHighlightColor = kColorFromHexA(0x527ead) // Link 文本色
let kSquareCellTextHighlightBackgroundColor = kColorFromHexA(0xbfdffe) // Link 点击背景色

let kSquareCellBottomImageWidth: CGFloat = kSquareCellWidth   // cell底部图片宽度
let kSquareCellBottomImageHeight: CGFloat = YYTextCGFloatPixelRound(kSquareCellBottomImageWidth / 305 * 16.0)   // cell底部图片高度

let kSquareCellBestImageWidth: CGFloat = 40   // best reply图片宽度
let kSquareCellBestImageHeight: CGFloat = 40   // best reply 底部图片高度


let kSquareLinkAtName = "at" //NSString

class MLTopicCell: UITableViewCell {
    
    var layout: MLTopicCellLayout!
    var statusView: MLSquareCellBodyView!
    var delegate: MLSquareCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.none;
        self.backgroundView?.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        statusView = MLSquareCellBodyView();
        statusView.cell = self;
        statusView.toolbarView.cell = self;
        self.contentView.addSubview(statusView);
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setInfo(_ layout: MLTopicCellLayout) {
        self.layout = layout;
        self.setHeight(layout.height)
        self.contentView.setHeight(layout.height)
        statusView.setInfo(layout)
    }
    
    class func height(_ layout: MLTopicCellLayout) -> CGFloat {
        return layout.height
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

protocol MLSquareCellDelegate {
    //    @optional
    func topicCell(_ cell: MLTopicCell, didClickInLabel label: YYLabel!, textRange: NSRange);
    func topicCell(_ cell: MLTopicCell, didClickContentWithLongPress longPress: Bool);
    func topicCell(_ cell: MLTopicCell, didClickImageAtIndex index: UInt);

    
    func topicCellDidClickLike(_ cell: MLTopicCell);
    func topicCellDidClickFavorite(_ cell: MLTopicCell);
    func topicCellDidClickShare(_ cell: MLTopicCell);
    func topicCellDidClickComment(_ cell: MLTopicCell);
    func topicCellDidClickOther(_ cell: MLTopicCell);
    func topicCellDidClickName(_ cell: MLTopicCell);
    func topicCellDidClickIcon(_ cell: MLTopicCell);
    
}

extension MLSquareCellDelegate {
    
    /// 点击了评论
    func topicCellDidClickComment(_ cell: MLTopicCell) {
        print("cellDidClickComment")
    }
    
    /// 点击了赞
    func topicCellDidClickLike(_ cell: MLTopicCell) {
        
        let joke = cell.layout.joke;
        
        if (joke?.isLike)! {
            SVProgressHUD.showInfo(withStatus: "您已经点过赞了!")
            return
        }
        
        MLRequestHelper.likeCommentWith(joke!.pid, succeed: { (baseRequest, responseObject) in
            SVProgressHUD.showSuccess(withStatus: "点赞成功!")
            cell.statusView.toolbarView.setLiked(true, animation: true)
            }) { (baseRequest, error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    // 点击了收藏
    func topicCellDidClickFavorite(_ cell: MLTopicCell) {
        
        let joke = cell.layout.joke;
        cell.statusView.toolbarView.setFavorited(!(joke?.isFavorite)!, animation: true)
        
        
        //    [RequestHelper postFavoriteWithCategory:type fid:joke.wid isToFavorite:!joke.isFavorite success:^(id responseObject) {
        //    [self showSuccess:!joke.isFavorite ? @"收藏成功!" : @"已取消收藏"];
        //    [cell.statusView.toolbarView setFavorited:!joke.isFavorite withAnimation:YES];
        //    } failur:^(__kindof TUBaseRequest * _Nonnull baseRequest, NSError * _Nonnull error) {
        //    [self showError:error.localizedDescription];
        //    }];
    }
    
    func topicCell(_ cell: MLTopicCell, didClickContentWithLongPress longPress: Bool) {
        print("长按")
    }
    
    func topicCellDidClickName(_ cell: MLTopicCell) {
        print("cellDidClickName")
        
    }
    
    func topicCellDidClickIcon(_ cell: MLTopicCell) {
        print("cellDidClickIcon")
        
    }
    
    func topicCellDidClickOther(_ cell: MLTopicCell) {
        print("cellDidClickOther")
    }
    
    func topicCellDidClickShare(_ cell: MLTopicCell) {
        print("cellDidClickShare")
        
        //    OSMessage *message = [[OSMessage alloc] init];
        //    message.title = model.wbody;
        //    message.desc = [NSString stringWithFormat:@"来自%@的分享", model.user_name];
        //
        //    [[TWShareView shareView] showShareViewWithMessage:message completionHandler:^(OSMessage *message, NSError *error) {
        //    if (!error) {
        //    [self showSuccess:@"分享成功"];
        //    } else {
        //    [self showError:error.localizedDescription];
        //    }
        //    }];
    }

}

class MLSquareCellBodyView: UIView {
    var contentView: UIView!
    var bottomImageView: UIImageView!
    var iconImageView: YYAnimatedImageView!
    var otherButton: UIButton!
    var nameLabel: YYLabel!
    var timeLabel: YYLabel!
    var textLabel: YYLabel!
    var picView: YYAnimatedImageView!
    var layout: MLTopicCellLayout!
    var cell: MLTopicCell!
    var toolbarView: MLTopicCellToolbarView!
    var picViews: [UIImageView]?
    
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
        contentView.setWidth(kSquareCellWidth)
        contentView.setHeight(1)
        contentView.setLeft(kSquareCellLeftMargin)
        contentView.backgroundColor = UIColor.white
        self.addSubview(contentView)

        nameLabel = YYLabel() ;
        //    nameLabel.setLeft(kSquareCellTextLeftMargin;
        nameLabel.setWidth(kSquareCellContentWidth)
        nameLabel.textAlignment = NSTextAlignment.left;
        nameLabel.displaysAsynchronously = true;
        nameLabel.ignoreCommonProperties = true;
        nameLabel.fadeOnAsynchronouslyDisplay = false;
        nameLabel.fadeOnHighlight = false;
        nameLabel.textTapAction = {[unowned self] (containerView: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) in
            if !self.cell.layout.joke.isAnonymous {
                // 匿名不响应
                self.cell.delegate?.topicCellDidClickName(self.cell)
            }
        };
        contentView.addSubview(nameLabel)
        
        timeLabel = YYLabel() ;
        timeLabel.setTop(nameLabel.frame.maxY)
        timeLabel.setLeft(kSquareCellTextLeftMargin);
        timeLabel.setWidth(kSquareCellContentWidth);
        timeLabel.textAlignment = NSTextAlignment.left;
        timeLabel.displaysAsynchronously = true;
        timeLabel.ignoreCommonProperties = true;
        timeLabel.fadeOnAsynchronouslyDisplay = false;
        timeLabel.fadeOnHighlight = false;
        contentView.addSubview(timeLabel)
        
        textLabel = YYLabel() ;
        textLabel.setTop(timeLabel.frame.maxY);
        textLabel.setLeft(kSquareCellTextLeftMargin);
        textLabel.setWidth(kSquareCellContentWidth);
        textLabel.textVerticalAlignment = YYTextVerticalAlignment.top;
        textLabel.displaysAsynchronously = true;
        textLabel.ignoreCommonProperties = true;
        textLabel.fadeOnAsynchronouslyDisplay = false;
        textLabel.fadeOnHighlight = false;
        
        textLabel.highlightTapAction = {[unowned self] (containerView: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) in
                self.cell.delegate?.topicCell(self.cell, didClickInLabel: containerView as! YYLabel, textRange: range)
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
        
        let likeHeight = kSquareCellLikeHeight;
        
        otherButton = UIButton.init(type: UIButtonType.custom)
        otherButton.setTitle("举报", for: UIControlState())
        otherButton.titleLabel?.font = UIFont.systemFont(ofSize: kSquareCellTimeFontSize)
        otherButton.setTitleColor(kSquareCellTimeColor, for: UIControlState())
        otherButton.isExclusiveTouch = true;
        otherButton.frame.size = CGSize(width: YYTextCGFloatPixelRound(34), height: likeHeight);
        otherButton.frame.origin.y = kSquareCellTopMargin
        otherButton.setRight(kScreenWidth - kSquareCellRightMargin - kSquareCellTextRightMargin)
        contentView.addSubview(otherButton)
        
        otherButton.addTarget(self, action: #selector(clickOther(sender:)), for: .touchUpInside)
        
        picViews = [UIImageView]()
        for _ in 0..<9 {
            let imageView = UIImageView()
            imageView.frame.size = CGSize(width: 100, height: 100);
            imageView.isHidden = true;
            imageView.clipsToBounds = true;
            imageView.backgroundColor = kColorFromHexA(0xf0f0f0);
            imageView.isExclusiveTouch = true;
            imageView.contentMode = UIViewContentMode.scaleAspectFill;
            imageView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapImage(sender:)))

//            let tap = UITapGestureRecognizer.init { [unowned self] (sender) in
//                let sender = sender as! UITapGestureRecognizer
//                if (sender.state == UIGestureRecognizerState.ended) {
//                    let p = sender.location(in: imageView)
//                    if (imageView.bounds.contains(p)) {
//                        self.cell.delegate?.topicCell(self.cell, didClickImageAtIndex: UInt(i));
//                    }
//                }
//            }

            imageView.addGestureRecognizer(tap)
            
            picViews?.append(imageView)
            contentView.addSubview(imageView)
        }
        
        toolbarView = MLTopicCellToolbarView()
        contentView.addSubview(toolbarView)
        
        bottomImageView = UIImageView(image: UIImage(named: "social_list_bottom_305x16_"))
        bottomImageView.frame.origin.x = kSquareCellLeftMargin
        bottomImageView.frame.size = CGSize(width: kSquareCellBottomImageWidth, height: kSquareCellBottomImageHeight)
        self.addSubview(bottomImageView)
        
    }
    
    func tapIcon(sender: UITapGestureRecognizer) {
        //let sender = sender as! UITapGestureRecognizer
        if (sender.state == UIGestureRecognizerState.ended) {
            let p = sender.location(in: iconImageView)
            if (iconImageView.bounds.contains(p)) {
                if !self.cell.layout.joke.isAnonymous {
                    // 匿名不响应
                    self.cell.delegate?.topicCellDidClickIcon(self.cell)
                }
            }
        }
    }
    
    func tapImage(sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.ended) {
            let imageView = sender.view! as! UIImageView
            let p = sender.location(in: imageView)
            if (imageView.bounds.contains(p)) {
                self.cell.delegate?.topicCell(self.cell, didClickImageAtIndex: UInt(picViews!.index(of: imageView)!));
            }
        }

    }
    
    func clickOther(sender: UIButton) {
        self.cell.delegate?.topicCellDidClickOther(self.cell)
    }
    
    func setInfo(_ layout: MLTopicCellLayout) {
        self.layout = layout;
        
        self.setHeight(layout.height);
        contentView.setTop(layout.marginTop);
        contentView.setHeight(layout.height - layout.marginTop - layout.marginBottom - kSquareCellBottomImageHeight);
        
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
        self.setImageAlbum(top)

        top += layout.picViewHeight
        top += layout.picViewHeight == 0 ? 0 : kSquareCellPaddingPic
        
        toolbarView.setTop(top);
        toolbarView.setWithLayout(layout)
        
//        top += layout.toolbarHeight
        bottomImageView.frame.origin.y = layout.height - kSquareCellBottomImageHeight - layout.marginBottom
    }
    
    func _setImageView() {
        
        let imageView = self.iconImageView;
        imageView?.frame = CGRect(x: layout.iconX, y: layout.iconY, width: layout.iconWidth, height: layout.iconHeight);
        imageView?.isHidden = false;
        imageView?.layer.removeAnimation(forKey: "contents")
        
        imageView?.yy_setImage(with: layout.joke.isAnonymous ? nil : layout.joke.uface,
                                     placeholder: UIImage.init(named: layout.joke.randomImage),
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
    
    func setImageAlbum(_ imageTop: CGFloat) {
        let picSize = layout.picSize

        var pics: Array<Any>? = layout.joke.imglist;
        var isImgList = true
        if pics == nil || pics!.count == 0 {
            pics = layout.joke.thumb_small;
            isImgList = false
        }
        
        let picsCount = pics == nil ? 0 : pics!.count;

        for i in 0..<9 {
            let imageView = self.picViews![i]
            if i >= picsCount {
                imageView.yy_cancelCurrentImageRequest()
                imageView.image = nil
                imageView.isHidden = true
            } else {
                var origin = CGPoint.zero;
                switch picsCount {
                case 1:
                    origin.x = kSquareCellTextLeftMargin;
                    origin.y = imageTop;
                case 4:
                    origin.x = kSquareCellTextLeftMargin + CGFloat(i % 2) * (picSize.width + kSquareCellPaddingPic);
                    origin.y = imageTop + CGFloat(Int(i / 2)) * (picSize.height + kSquareCellPaddingPic);
                default:
                    origin.x = kSquareCellTextLeftMargin + CGFloat(i % 3) * (picSize.width + kSquareCellPaddingPic);
                    origin.y = imageTop + CGFloat(Int(i / 3)) * (picSize.height + kSquareCellPaddingPic);
                }
                
                imageView.frame = CGRect(x: origin.x, y: origin.y, width: picSize.width, height: picSize.height)
                imageView.isHidden = false;
                imageView.layer.removeAnimation(forKey: "contents")

                
                let pic = isImgList ? (pics?[i] as! MLTopicPhotoModel).thumb : URL(string: pics?[i] as! String);
                
                imageView.yy_setImage(with: pic, placeholder: nil, options: YYWebImageOptions.avoidSetImage, completion: { (image, url, from, stage, error) in
                    if (image != nil && stage == YYWebImageStage.finished) {
                        if isImgList {
                            let width = picSize.width;
                            let height = picSize.height;
                            let scale = (height / width) / (imageView.height() / imageView.width());
                            
                            if (scale < 0.99 || scale.isNaN) { // 宽图把左右两边裁掉
                                imageView.contentMode = UIViewContentMode.scaleAspectFill;
                                imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1);
                            } else if (scale > 1) { // 高图只保留顶部
                                imageView.contentMode = UIViewContentMode.scaleToFill;
                                let imageViewScale = imageView.bounds.size.width / imageView.bounds.size.height
                                imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: width / height / imageViewScale);
                            }
                            
                        }
                        
                        
                        imageView.image = image;
                        if (from != YYWebImageFromType.memoryCacheFast) {
                            let transition = CATransition()
                            transition.duration = 0.15;
                            transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
                            transition.type = kCATransitionFade;
                            imageView.layer.add(transition, forKey: "contents")
                        }
                    }
                    
                })
                
            }
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class MLTopicCellToolbarView: UIView {
    var likeButton: UIButton!
    var favoriteButton: UIButton!
    var shareButton: UIButton!
    var commentButton: UIButton!
    
    
    var likeImageView: UIImageView!
    var favoriteImageView: UIImageView!
    var shareImageView: UIImageView!
    var commentImageView: UIImageView!
    
    var commentLabel: YYLabel!
    var likeLabel: YYLabel!
    
    var cell: MLTopicCell?
    
    let favoriteImage: UIImage = UIImage(named: "favicon_btn_listpage_select")!;
    let unFavoriteImage: UIImage = UIImage(named: "favicon_btn_listpage")!;
    let likeImage: UIImage = UIImage(named: "digupicon_btn_listpage_select")!;
    let unlikeImage: UIImage = UIImage(named: "digupicon_btn_listpage")!;
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        var frame = frame
        if (frame.size.width == 0 && frame.size.height == 0) {
            frame.size.width = kSquareCellContentWidth;
            frame.size.height = kSquareCellToolbarHeight;
            frame.origin.x = kSquareCellTopMargin;
        }
        super.init(frame: frame)
        
        self.isExclusiveTouch = true;
        
        let selfH = YYTextCGFloatPixelRound(self.height() - 12);
        let selfTop = YYTextCGFloatPixelRound(6);
        
        likeButton = UIButton(type: UIButtonType.custom)
        likeButton.isExclusiveTouch = true;
        likeButton.setTop(selfTop);
        likeButton.frame.size = CGSize(width: YYTextCGFloatPixelRound(kSquareCellLikeWidth), height: selfH);
        likeButton.setBackgroundImage(UIImage(named: "digbtn_listpage_press"), for: UIControlState.highlighted)
        likeButton.setBackgroundImage(UIImage(named: "digbtn_listpage"), for: UIControlState())
        
        
        commentButton = UIButton(type: UIButtonType.custom)
        commentButton.isExclusiveTouch = true;
        commentButton.setTop(selfTop);
        commentButton.frame.size = CGSize(width: YYTextCGFloatPixelRound(kSquareCellCommentWidth), height: selfH + 5);
        commentButton.setRight(YYTextCGFloatPixelRound(kSquareCellContentWidth));
        commentButton.setBackgroundImage(UIImage(named: "commentbtn_listpage_press"), for: UIControlState.highlighted)
        commentButton.setBackgroundImage(UIImage(named: "commentbtn_listpage"), for: UIControlState())
        
        
        shareButton = UIButton(type: UIButtonType.custom)
        shareButton.isExclusiveTouch = true;
        shareButton.setTop(selfTop);
        shareButton.frame.size = CGSize(width: YYTextCGFloatPixelRound(kSquareCellShareWidth), height: selfH);
        shareButton.setRight(YYTextCGFloatPixelRound(commentButton.left() - kSquareCellTopMargin));
        shareButton.setBackgroundImage(UIImage(named: "digbtn_listpage_press"), for: UIControlState.highlighted)
        shareButton.setBackgroundImage(UIImage(named: "digbtn_listpage"), for: UIControlState())
        
        favoriteButton = UIButton(type: UIButtonType.custom)
        favoriteButton.isExclusiveTouch = true;
        favoriteButton.setTop(selfTop);
        favoriteButton.frame.size = CGSize(width: YYTextCGFloatPixelRound(kSquareCellFavoriteWidth), height: selfH);
        favoriteButton.setRight(YYTextCGFloatPixelRound(shareButton.left() - kSquareCellTopMargin));
        favoriteButton.setBackgroundImage(UIImage(named: "digbtn_listpage_press"), for: UIControlState.highlighted)
        favoriteButton.setBackgroundImage(UIImage(named: "digbtn_listpage"), for: UIControlState())
        
        
        shareImageView = UIImageView(image:UIImage(named: "reposticon_btn_listpage"))
        shareImageView.center.y = shareButton.height() / 2;
        shareImageView.center.x = shareButton.width() / 2;
        shareButton.addSubview(shareImageView)
        
        //favicon_btn_listpage_select
        favoriteImageView = UIImageView(image:UIImage(named: "favicon_btn_listpage"))
        favoriteImageView.center.y = favoriteButton.height() / 2;
        favoriteImageView.center.x = favoriteButton.width() / 2;
        favoriteButton.addSubview(favoriteImageView)
        
        likeImageView = UIImageView(image:UIImage(named: "digupicon_btn_listpage"))
        likeImageView.center.y = likeButton.height() / 2;
        likeButton.addSubview(likeImageView)
        
        commentLabel = YYLabel()
        commentLabel.isUserInteractionEnabled = false;
        commentLabel.setHeight(selfH);
        commentLabel.setWidth(commentButton.width());
        commentLabel.textVerticalAlignment = YYTextVerticalAlignment.center;
        commentLabel.displaysAsynchronously = true;
        commentLabel.ignoreCommonProperties = true;
        commentLabel.fadeOnHighlight = false;
        commentLabel.fadeOnAsynchronouslyDisplay = false;
        commentButton.addSubview(commentLabel)
        
        likeLabel = YYLabel()
        likeLabel.isUserInteractionEnabled = false;
        likeLabel.setHeight(selfH);
        likeLabel.textVerticalAlignment = YYTextVerticalAlignment.center;
        likeLabel.displaysAsynchronously = true;
        likeLabel.ignoreCommonProperties = true;
        likeLabel.fadeOnHighlight = false;
        likeLabel.fadeOnAsynchronouslyDisplay = false;
        likeButton.addSubview(likeLabel)
        
        
        self.addSubview(commentButton)
        self.addSubview(likeButton)
        self.addSubview(favoriteButton)
        self.addSubview(shareButton)
        
        likeButton.addTarget(self, action: #selector(pressOnLike(sender:)), for: UIControlEvents.touchUpInside)
        
        favoriteButton.addTarget(self, action: #selector(pressOnFavorite(sender:)), for: UIControlEvents.touchUpInside)
        shareButton.addTarget(self, action: #selector(pressOnShare(sender:)), for: UIControlEvents.touchUpInside)
        commentButton.addTarget(self, action: #selector(pressOnComment(sender:)), for: UIControlEvents.touchUpInside)
        
    }
    
    //MARK: Action
    func pressOnLike(sender: UITapGestureRecognizer) {
        self.cell?.delegate?.topicCellDidClickLike(self.cell!)

    }
    func pressOnFavorite(sender: UITapGestureRecognizer) {
        self.cell?.delegate?.topicCellDidClickFavorite(self.cell!)

    }
    func pressOnShare(sender: UITapGestureRecognizer) {
        self.cell?.delegate?.topicCellDidClickShare(self.cell!)

    }
    func pressOnComment(sender: UITapGestureRecognizer) {
        self.cell?.delegate?.topicCellDidClickComment(self.cell!)
    }
    
    func setWithLayout(_ layout: MLTopicCellLayout) {
        
        commentLabel.setWidth(layout.toolbarCommentTextWidth);
        commentLabel.textAlignment = NSTextAlignment.center;
        likeLabel.setWidth(layout.toolbarLikeTextWidth);
        
        commentLabel.textLayout = layout.toolbarCommentTextLayout;
        likeLabel.textLayout = layout.toolbarLikeTextLayout;
        
        commentLabel.center.x = YYTextCGFloatPixelRound((commentButton.width())/2);
        
        self.adjustImage(likeImageView, label: likeLabel, in: likeButton)
        
        likeImageView.image = layout.joke.isLike ? likeImage : unlikeImage;
        favoriteImageView.image = layout.joke.isFavorite ? favoriteImage : unFavoriteImage;
    }
    
    
    func adjustImage(_ image: UIImageView, label: YYLabel, in button:UIButton) {
        let imageWidth: CGFloat = image.bounds.size.width;
        let labelWidth: CGFloat = label.width();
        let paddingMid: CGFloat = 5;
        let paddingSide: CGFloat = (button.width() - imageWidth - labelWidth - paddingMid) / 2.0;
        image.center.x = YYTextCGFloatPixelRound((paddingSide + imageWidth / 2));
        label.setRight(YYTextCGFloatPixelRound((button.width() - paddingSide)));
    }
    
    
    func setLiked(_ liked: Bool, animation: Bool) {
        
        
        let layout = cell!.statusView.layout;
        if (layout?.joke.isLike == liked) {return};
        
        let image = liked ? likeImage : unlikeImage;
        var newCount = (layout!.joke.like as NSString).integerValue;
        newCount = liked ? newCount + 1 : newCount - 1;
        if (newCount < 0) {
            newCount = 0
        }
        if (liked && newCount < 1) {
            newCount = 1
        }
        let newCountDesc = newCount > 0 ? JokeHelper.shortedNumberDesc(number: newCount) : "赞";
        
        let font = UIFont.systemFont(ofSize: kSquareCellLikeFontSize)
        let container = YYTextContainer(size: CGSize(width: kScreenWidth, height: kSquareCellToolbarHeight))
        container.maximumNumberOfRows = 1;
        let likeText = NSMutableAttributedString(string: newCountDesc)
        likeText.yy_font = font;
        likeText.yy_color = liked ? kSquareCellLikeHighlightColor : kSquareCellLikeNormalColor;
        let textLayout = YYTextLayout(container: container, text: likeText) as YYTextLayout!
        
        layout?.joke.isLike = liked;
        layout?.joke.like = "\(newCount)";
        layout?.toolbarLikeTextLayout = textLayout;
        
        if (!animation) {
            likeImageView.image = image;
            likeLabel.setWidth(YYTextCGFloatPixelRound(textLayout!.textBoundingRect.size.width));
            likeLabel.textLayout = layout?.toolbarLikeTextLayout;
            self.adjustImage(likeImageView, label: likeLabel, in: likeButton)
            return;
        }
        
        
        let animateOptions = UIViewAnimationOptions.init(rawValue: UIViewAnimationOptions.beginFromCurrentState.rawValue | UIViewAnimationOptions().rawValue)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: animateOptions, animations: {
            self.likeImageView.layer.setValue(1.7, forKeyPath: "transform.scale")
        }) { (finished) in
            self.likeImageView.image = image;
            self.likeLabel.setWidth(YYTextCGFloatPixelRound((textLayout?.textBoundingRect.size.width)!));
            self.likeLabel.textLayout = layout?.toolbarLikeTextLayout;
            self.adjustImage(self.likeImageView, label: self.likeLabel, in: self.likeButton)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: animateOptions, animations: {
                self.likeImageView.layer.setValue(0.9, forKeyPath: "transform.scale")
                }, completion: { (finished) in
                    UIView.animate(withDuration: 0.2, delay: 0, options: animateOptions, animations: {
                        self.likeImageView.layer.setValue(1.0, forKeyPath: "transform.scale")
                        }, completion: { (finished) in
                    })
            })
        }
        
    }
    
    
    
    func setFavorited(_ favorited: Bool, animation: Bool) {
        
        let layout = cell!.statusView.layout;
        if (layout?.joke.isFavorite == favorited) {return};
        
        let image = favorited ? favoriteImage : unFavoriteImage
        
        layout?.joke.isFavorite = favorited;
        
        if (!animation) {
            favoriteImageView.image = image;
            return;
        }
        
        let animateOptions = UIViewAnimationOptions.init(rawValue: UIViewAnimationOptions.beginFromCurrentState.rawValue | UIViewAnimationOptions().rawValue)
        UIView.animate(withDuration: 0.2, delay: 0, options: animateOptions, animations: {
            self.favoriteImageView.layer.setValue(1.7, forKeyPath: "transform.scale")
        }) { (finished) in
            self.favoriteImageView.image = image;
            UIView.animate(withDuration: 0.2, delay: 0, options: animateOptions, animations: {
                self.favoriteImageView.layer.setValue(0.9, forKeyPath: "transform.scale")
                }, completion: { (finished) in
                    UIView.animate(withDuration: 0.2, delay: 0, options: animateOptions, animations: {
                        self.favoriteImageView.layer.setValue(1.0, forKeyPath: "transform.scale")
                        }, completion: { (finished) in
                    })
            })
        }
        
    }
    
    
}
