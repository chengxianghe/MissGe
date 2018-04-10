//
//  MLHomeModel.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/12.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import ObjectMapper

class MLHomeDetailModel: Mappable {
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
    var views: String = ""
    var show_title: Bool = false
    var forward: Int = 0
    var reply: Int = 0
    var like: Int = 0
    var model: Int = 0
    var is_special: Bool = false
    var type: Int = 0

    var author: String = ""
    var source: String = ""
    var detail: String = ""
    var allow_comment: Bool = false
    var is_collect: Bool = false
    var link_url: URL?
    var imglist: Array<String>?
    var goods: Array<String>?

    required init?(map: Map) {

    }

    // Mappable
    func mapping(map: Map) {
        uid         <- map["uid"]
        tid         <- map["tid"]
        uname       <- map["uname"]
        avatar      <- map["avatar"]
        summary     <- map["summary"]
        title       <- map["title"]
        date        <- map["date"]
        showTime    <- (map["date"], transfromOfDateStringCustom())
        cover       <- (map["cover"], transfromOfURLAndString())
        tag         <- map["tag"]
        views       <- map["views"]
        show_title  <- map["show_title"]
        forward     <- map["forward"]
        reply       <- map["reply"]
        like        <- map["like"]
        model       <- map["model"]
        is_special  <- map["is_special"]
        type        <- map["type"]
        author      <- map["author"]
        source      <- map["source"]
        detail      <- map["detail"]
        allow_comment  <- map["allow_comment"]
        is_collect  <- map["is_collect"]

        link_url    <- (map["link_url"], transfromOfURLAndString())
        imglist     <- map["imglist"]
        goods       <- map["goods"]

    }
}

/*
{
    "result": "200",
    "content": {
        "tid": "8297",
        "uid": 0,
        "uname": 0,
        "avatar": "",
        "summary": "双陈婚礼上，最美伴娘团的阿娇，一双又细又长的腿引起了网友们的注意~",
        "title": "阿娇，你的小粗腿又亮了啊",
        "author": "",
        "source": "",
        "detail": "ddddddd"
        "cover": "http://img.gexiaojie.com/article/2016/0721/160721163316P605860V47.jpg",
        "tag": "享趣味",
        "views": "695",
        "forward": 0,
        "reply": 0,
        "like": 364,
        "date": "1469149200",
        "model": 1,
        "allow_comment": "1",
        "imglist": [],
        "is_collect": 0,
        "link_url": "http://t.gexiaojie.com/index.php?m=mobile&c=index&a=content&aid=8297",
        "show_title": "1",
        "type": 1,
        "goods": []
    },
    "msg": "正确返回"
}
*/
