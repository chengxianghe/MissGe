//
//  MLHomePageModel.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/13.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import ObjectMapper

class MLHomePageModel: Mappable {
    var uid: String = ""
    var tid: String = ""

    var uname: String = ""
    var avatar: String = ""

    var summary: String = ""
    var title: String = ""
    var date: String = ""
    var showTime: String = ""

    var cover: URL?
    var tag: String = ""
    var showTag: String?
    var views: String = ""

    var index_recommend: String = ""
    var column_recommend: String = ""

    var album: Array<MLHomeAlbumModel>? // [MLHomeAlbumModel]

    var show_title: String = ""

    var forward: Int = 0
    var reply: Int = 0
    var like: Int = 0
    var model: Int = 0
    var is_special: Bool = false

    /** 1 普通文章， 5 美图 4问答*/
    var type: Int = 0

    // subject
    var sequence: String = ""
    var is_top: Bool = false
    var link_url: URL?

	required init?(map: Map) {

        if let tags = map.JSON["tag"] as? [String] {
            if tags.count > 0 {
                showTag = tags.first!
            }
        }
	}

	func mapping(map: Map) {
		uid                  <- map["uid"]
		tid                  <- map["tid"]
		uname                <- map["uname"]
		avatar               <- map["avatar"]
		summary              <- map["summary"]
		title                <- map["title"]
		date                 <- map["date"]
		showTime             <- (map["date"], transfromOfDateStringCustom())
		cover                <- (map["cover"], transfromOfURLAndString())
		//showTag              <- (map["tag"], transfromOfShowTag())
		tag                  <- map["tag"]
		views                <- map["views"]
		index_recommend      <- map["index_recommend"]
		column_recommend     <- map["column_recommend"]
		album                <- map["album"]
		show_title           <- map["show_title"]
		forward              <- map["forward"]
		reply                <- map["reply"]
		like                 <- map["like"]
		model                <- map["model"]
		is_special           <- map["is_special"]
		type                 <- map["type"]
		sequence             <- map["sequence"]
		is_top               <- map["is_top"]
		link_url             <- (map["link_url"], transfromOfURLAndString())
	}
}

class MLHomeAlbumModel: Mappable {
    var url: URL?

    var width: String = ""
    var height: String = ""
    var ext: String = ""
    var size: String = ""

    var alt: String = ""
    var brief: String = ""

	required init?(map: Map) {

	}

	func mapping(map: Map) {
		url                  <- (map["url"], transfromOfURLAndString())
		width                <- map["width"]
		height               <- map["height"]
		ext                  <- map["ext"]
		size                 <- map["size"]
		alt                  <- map["alt"]
		brief                <- map["brief"]
	}
}

class MLHomeBannerModel: Mappable, Codable {
    var path: URL?

    var width: String? = ""
    var height: String? = ""
    var ext: String? = ""
    var size: String? = ""
    var slide_info: String? = ""
    var weibo_type: Int? = 0
    var weibo_id: String? = ""
    var link_url: String? = ""
    var sid: String? = ""

	required init?(map: Map) {

	}

	func mapping(map: Map) {
		path                 <- (map["path"], transfromOfURLAndString())
		width                <- map["width"]
		height               <- map["height"]
		ext                  <- map["ext"]
		size                 <- map["size"]
		slide_info           <- map["slide_info"]
		weibo_type           <- map["weibo_type"]
		weibo_id             <- map["weibo_id"]
		link_url             <- map["link_url"]
		sid                  <- map["sid"]
	}
}
