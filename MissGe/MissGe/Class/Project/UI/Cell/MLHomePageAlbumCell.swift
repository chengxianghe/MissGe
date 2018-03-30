//
//  MLHomePageAlbumCell.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/20.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import YYWebImage

let kMLHomePageAlbumCellHeight: CGFloat = ceil((kScreenWidth - 25 - 6 * 2) / 3.0 * 0.7 + 74)

class MLHomePageAlbumCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setInfo(_ model: MLHomePageModel) {

        titleLabel.text = model.title
        countLabel.text = "\(model.album?.count ?? 0)张图片"
        timeLabel.text = model.showTime

        if model.album != nil && model.album!.count >= 3 {
            let albums = model.album!

            imageView1.yy_setImage(with: albums[0].url, placeholder: UIImage(named: "cell_img_default_70x70_"), options: YYWebImageOptions.setImageWithFadeAnimation, completion: nil)
            imageView2.yy_setImage(with: albums[1].url, placeholder: UIImage(named: "cell_img_default_70x70_"), options: YYWebImageOptions.setImageWithFadeAnimation, completion: nil)
            imageView3.yy_setImage(with: albums[2].url, placeholder: UIImage(named: "cell_img_default_70x70_"), options: YYWebImageOptions.setImageWithFadeAnimation, completion: nil)
        }

    }

    class func height(_ model: MLHomePageModel) -> CGFloat {
        return kMLHomePageAlbumCellHeight
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
