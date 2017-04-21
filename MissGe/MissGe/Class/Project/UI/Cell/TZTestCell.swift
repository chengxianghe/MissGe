//
//  TZTestCell.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/17.
//  Copyright © 2017年 cn. All rights reserved.
//

import UIKit
import TZImagePickerController
import AssetsLibrary

class TZTestCell: UICollectionViewCell {
    var imageView: UIImageView!
    var videoImageView: UIImageView!
    
    var deleteBtn: UIButton!
    var row: NSInteger = 0 {
        didSet {
            self.deleteBtn.tag = row;
        }
    }
    var asset: AnyObject? {
        willSet{
            if (newValue?.isKind(of: PHAsset.classForCoder()))! {
                let phAsset: PHAsset = newValue as! PHAsset
                self.videoImageView.isHidden = phAsset.mediaType != PHAssetMediaType.video;

            } else if (newValue?.isKind(of: ALAsset.classForCoder()))! {
                let alAsset = newValue as! ALAsset;
                let type = alAsset.value(forProperty: ALAssetPropertyType) as! String
                self.videoImageView.isHidden = type != ALAssetTypeVideo
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

        
        deleteBtn = UIButton()
        deleteBtn.setImage(UIImage.init(named: "photo_delete"), for: .normal)
        deleteBtn.frame = CGRect.init(x: self.tz_width - 36, y: 0, width: 36, height: 36);
        deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -10);
        deleteBtn.alpha = 0.6;
        self.addSubview(deleteBtn)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds;
        let width = self.tz_width / 3.0;
        videoImageView.frame = CGRect(x: width, y: width, width: width, height: width);
    
    }
    
    func snapshotView() -> UIView {
        
        let snapshotView = UIView()
        
        var cellSnapshotView: UIView! = nil
        
        if self.responds(to: #selector(snapshotView(afterScreenUpdates:))) {
            cellSnapshotView = self.snapshotView(afterScreenUpdates: false)
        } else {
            let size = CGSize(width: self.bounds.size.width + 20, height: self.bounds.size.height + 20);
            UIGraphicsBeginImageContextWithOptions(size, self.isOpaque, 0);
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let cellSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            cellSnapshotView = UIImageView(image: cellSnapshotImage)
        }
        
        
        snapshotView.frame = CGRect(x: 0, y: 0, width: cellSnapshotView.frame.size.width, height: cellSnapshotView.frame.size.height);
        cellSnapshotView.frame = CGRect(x: 0, y: 0, width: cellSnapshotView.frame.size.width, height: cellSnapshotView.frame.size.height);
        
        snapshotView.addSubview(cellSnapshotView)
        return snapshotView;
    }
}
