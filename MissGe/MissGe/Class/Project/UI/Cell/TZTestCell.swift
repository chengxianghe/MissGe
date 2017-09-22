//
//  TZTestCell.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/17.
//  Copyright © 2017年 cn. All rights reserved.
//

import UIKit
import TU_TZImagePickerController
import AssetsLibrary

class TZTestCell: UICollectionViewCell {
    var imageView: UIImageView!
    var videoImageView: UIImageView!
    var gifLable: UILabel!
    var deleteBtn: UIButton!
    var deleteClickClosure: kBlankActionClosure?

    var model: TZAssetModel? {
        willSet{
            if newValue?.type == TZAssetModelMediaTypePhotoGif {
                self.gifLable.isHidden = false
                self.videoImageView.isHidden = true
            } else if newValue?.type == TZAssetModelMediaTypeVideo {
                self.gifLable.isHidden = true
                self.videoImageView.isHidden = false

            } else {
                self.gifLable.isHidden = true
                self.videoImageView.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        imageView = UIImageView()
        imageView.backgroundColor = UIColor(white: 1.000, alpha: 0.500)
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        self.addSubview(imageView)
        self.clipsToBounds = true
        
        videoImageView = UIImageView()
        videoImageView.image = UIImage.init(namedFromMyBundle: "MMVideoPreviewPlay")
        videoImageView.contentMode = UIViewContentMode.scaleAspectFill;
        videoImageView.isHidden = true
        self.addSubview(videoImageView)

        gifLable = UILabel();
        gifLable.text = "GIF";
        gifLable.textColor = UIColor.white;
        gifLable.backgroundColor = UIColor(white: 0, alpha: 0.800);
        gifLable.textAlignment = NSTextAlignment.center;
        gifLable.font = UIFont.systemFont(ofSize: 10)
        gifLable.frame = CGRect.init(x: self.tz_width - 25, y: self.tz_height - 14, width: 25, height: 14)
        self.addSubview(gifLable)

        deleteBtn = UIButton()
        deleteBtn.setImage(UIImage.init(named: "photo_delete"), for: .normal)
        deleteBtn.frame = CGRect.init(x: self.tz_width - 36, y: 0, width: 36, height: 36);
        deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -10);
        deleteBtn.alpha = 0.6;
        deleteBtn.addTarget(self, action: #selector(onDeleteBtnPressed(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(deleteBtn)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds;
        let width = self.xh_width / 3.0;
        videoImageView.frame = CGRect(x: width, y: width, width: width, height: width);
    }
    
    @objc func onDeleteBtnPressed(sender: UIButton) {
        self.deleteClickClosure?(sender)
    }
}
