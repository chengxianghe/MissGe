//
//  MLDiscoverHeaderCell.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/20.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

let kTagListResource: [String : String] = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "TagList", ofType: "plist")!) as! [String : String]

class MLDiscoverHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setInfo(_ model: MLDiscoverTagModel) {
        
        if model.tag_name == nil {
            iconImageView.image = nil
            return
        }
        
        iconImageView.image = UIImage(named: (kTagListResource[model.tag_name!] ?? ""))

    }
    
}
