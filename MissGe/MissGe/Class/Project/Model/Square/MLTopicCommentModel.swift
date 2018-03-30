//
//  MLTopicCommentModel.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/13.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import ObjectMapper

class MLTopicCommentModel: Mappable {
    var pid: String = ""
    var uid: String = ""
    var tid: String = ""

    var nickname: String?
    var uname: String?

    var uface: URL?
    var verify: String?
    var verify_img: String?
    var verify_img_width: String?
    var verify_img_height: String?

    var subject: String?
    var content: String?
    var status: String?
    var type: String?
    var date: String?

    var quote: MLTopicCommentModel?
    var showTime: String?

    var isAnonymous: Bool = false // 是否匿名
    var best_reply: Bool = false

    /// homeComment
    var cid: String = ""

    var randomImage: String = ""

	required init?(map: Map) {

        if self.uface == nil {
            if let avatar = map.JSON["avatar"] as? String {
                self.uface = URL.init(string: avatar)
            }
        }

        if self.content == nil {
            if let detail = map.JSON["detail"] as? String {
                self.content = detail
            }
        }

        if self.quote == nil {
            if let quot = map.JSON["quot"] as? [String: Any] {
                self.quote = MLTopicCommentModel(JSON: quot)
            }
        }

        // 0-6
        self.randomImage = "anonymous_" + "\(arc4random() % 7)" + "_32x32_"
	}

	func mapping(map: Map) {
		pid                  <- map["pid"]
		uid                  <- map["uid"]
		tid                  <- map["tid"]
		nickname             <- map["nickname"]
		uname                <- map["uname"]
		uface                <- (map["uface"], transfromOfURLAndString())
		verify               <- map["verify"]
		verify_img           <- map["verify_img"]
		verify_img_width     <- map["verify_img_width"]
		verify_img_height    <- map["verify_img_height"]
		subject              <- map["subject"]
		content              <- (map["content"], transfromOfEmojiAndString())
		status               <- map["status"]
		type                 <- map["type"]
		date                 <- map["date"]
		quote                <- map["quote"]
		showTime             <- (map["date"], transfromOfDateStringCustom())
		isAnonymous          <- (map["anonymous"], transfromOfBoolAndString())
		best_reply           <- map["best_reply"]
		cid                  <- map["cid"]
	}
}
