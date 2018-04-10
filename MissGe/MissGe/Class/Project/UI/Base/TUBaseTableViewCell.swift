//
//  TUBaseTableViewCell.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/19.
//  Copyright © 2017年 cn. All rights reserved.
//

import UIKit

class TUBaseTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        for view in self.subviews {
            if view.isKind(of: UIScrollView.classForCoder()) {
                (view as! UIScrollView).delaysContentTouches = false  // Remove touch delay for iOS 7
                break
            }
        }
        
        self.selectionStyle = .none
        self.backgroundView?.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
