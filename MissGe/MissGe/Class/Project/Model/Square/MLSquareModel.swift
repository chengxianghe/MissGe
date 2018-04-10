//
//  MLSquareModel.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/13.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import ObjectMapper

class MLSquareModel : Mappable {
    var pid: String = ""
    var fid: String = ""
    var uid: String = ""
    var tid: String = ""
    
    var fname: String?
    var nickname: String?
    var uname: String?

    var uface: URL?
    var verify: String?
    var verify_img: String?
    var verify_img_width: Int = 0
    var verify_img_height: Int = 0

    var subject: String?
    var content: String?
    var thumb: Array<String>?
    var thumb_small: Array<String>?
    
//    var add_date: String?
//    var date: String?
    var digest: String = ""
    var top: String = ""
    var like: String = ""
    var replies: String = ""
    var views: String = ""
    
    var showTime: String?
    var isAnonymous: Bool = false // 是否匿名
    var isLike: Bool = false
    var isFavorite: Bool = false

    
    // 详情Model需要的
    var closed: Bool = false
    var imglist: [MLTopicPhotoModel]? // [MLTopicPhotoModel]

    var randomImage: String = ""

	required init?(map: Map) {
        if self.nickname == nil {
            if let uname = map.JSON["uname"] as? String {
                self.nickname = uname
            }
        }
        
        if let date = map.JSON["date"] as? String {
            showTime = NSDate(fromStringOrNumber:(date)).customTimeDescription()
        } else if let add_date = map.JSON["add_date"] as? String {
            showTime = NSDate(fromStringOrNumber:(add_date)).customTimeDescription()
        }
        
        // 0-6
        self.randomImage = "anonymous_" + "\(arc4random() % 7)" + "_32x32_"
	}

	func mapping(map: Map) {
		pid                  <- map["pid"]
		fid                  <- map["fid"]
		uid                  <- map["uid"]
		tid                  <- map["tid"]
		fname                <- map["fname"]
		nickname             <- map["nickname"]
		uname                <- map["uname"]
		uface                <- (map["uface"], transfromOfURLAndString())
		verify               <- map["verify"]
		verify_img           <- map["verify_img"]
		verify_img_width     <- map["verify_img_width"]
		verify_img_height    <- map["verify_img_height"]
		subject              <- map["subject"]
		content              <- (map["content"], transfromOfEmojiAndString())
		thumb                <- map["thumb"]
		thumb_small          <- map["thumb_small"]
//		add_date             <- (map["add_date"], transfromOfDateStringCustom())
		digest               <- map["digest"]
		top                  <- map["top"]
		like                 <- map["like"]
		replies              <- map["replies"]
		views                <- map["views"]
//		date                 <- (map["date"], transfromOfDateStringCustom())
		isAnonymous          <- (map["anonymous"], transfromOfBoolAndString())
		isLike               <- map["isLike"]
		isFavorite           <- map["isFavorite"]
		closed               <- map["closed"]
		imglist              <- map["imglist"]
	}
}

class MLTopicPhotoModel : Mappable {
    var thumb: URL?
    
    var width: String = ""
    var height: String = ""
    var ext: String = ""
    var path: String = ""
    
    var alt: String = ""
    var desc: String = ""


	required init?(map: Map) {

	}

	func mapping(map: Map) {
		thumb                <- (map["thumb"], transfromOfURLAndString())
		width                <- map["width"]
		height               <- map["height"]
		ext                  <- map["ext"]
		path                 <- map["path"]
		alt                  <- map["alt"]
		desc                 <- map["desc"]
	}
}
