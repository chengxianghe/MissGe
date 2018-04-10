//
//  MLHomePageCell.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/19.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class MLHomePageCell: UITableViewCell {

    @IBOutlet weak var hotTagImageView: UIImageView!
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setInfo(_ model: MLHomePageModel) {

        iconImageView.yy_setImage(with: model.cover, placeholder: UIImage(named: "cell_img_default_70x70_"))
        titleLabel.text = model.title
        contentLabel.text = model.summary

        likeLabel.text = String(format: "%d", model.like)

        if model.index_recommend == "1" {
            hotTagImageView.isHidden = false
            hotTagImageView.image = UIImage(named: "article_cell_hot_flag_23x23_")
        } else {
            hotTagImageView.isHidden = true
        }
        if model.showTag == nil {
            tagImageView.image = nil
            return
        }
        switch model.showTag! {
        case "高情商":
            tagImageView.image = UIImage(named: "tag_cell_flag_gqs_36x7_")
        case "白骨精":
            tagImageView.image = UIImage(named: "tag_cell_flag_bgj_36x7_")
        case "懂养生":
            tagImageView.image = UIImage(named: "tag_cell_flag_dys_36x9_")
        case "慧生活":
            tagImageView.image = UIImage(named: "tag_cell_flag_hsh_36x7_")
        case "巧搭配":
            tagImageView.image = UIImage(named: "tag_cell_flag_qdp_36x7_")
        case "俏佳人":
            tagImageView.image = UIImage(named: "tag_cell_flag_qjr_36x7_")
        case "享趣味":
            tagImageView.image = UIImage(named: "tag_cell_flag_xqw_36x7_")
        default:
            tagImageView.image = nil
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
