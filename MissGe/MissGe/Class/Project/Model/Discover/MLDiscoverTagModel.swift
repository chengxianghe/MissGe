//
//  MLDiscoverTagModel.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/13.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import ObjectMapper

class MLDiscoverTagModel: Mappable {
    var tag_id: String?
    var tag_name: String?

    var tag_img: URL?
    var sequence: Int = 0

	required init?(map: Map) {

	}

	func mapping(map: Map) {
		tag_id               <- map["tag_id"]
		tag_name             <- map["tag_name"]
		tag_img              <- (map["tag_img"], transfromOfURLAndString())
		sequence             <- map["sequence"]
	}
}
