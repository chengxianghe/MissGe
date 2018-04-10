//
//  MLDiscoverCell.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/20.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class MLDiscoverCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setInfo(_ url: URL?) {
        iconImageView.yy_setImage(with: url!, placeholder: UIImage(named: "banner_default_320x170_"), options: .setImageWithFadeAnimation, completion: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
