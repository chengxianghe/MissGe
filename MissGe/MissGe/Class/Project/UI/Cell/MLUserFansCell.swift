//
//  MLUserFansCell.swift
//  MissLi
//
//  Created by CXH on 2016/10/11.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class MLUserFansCell: UITableViewCell {

    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var followButton: TUIBButton!
    @IBOutlet weak var descLabel: UILabel!

    var onFollowButtonTapClosure: kBlankActionClosure?
    var onIconButtonTapClosure: kBlankActionClosure?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setInfo(model: MLUserModel) {
        self.iconButton.yy_setImage(with: model.avatar, for: UIControlState.normal, placeholder: nil)
        self.nameButton.setTitle(model.nickname ?? model.username, for: .normal)
        self.descLabel.text = model.autograph
        self.followButton.isSelected = model.relation == 1
    }

    @IBAction func onFollowButton(_ sender: TUIBButton) {
        self.onFollowButtonTapClosure?(sender)
    }
    
    @IBAction func onIconButton(_ sender: UIButton) {
        self.onIconButtonTapClosure?(sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
