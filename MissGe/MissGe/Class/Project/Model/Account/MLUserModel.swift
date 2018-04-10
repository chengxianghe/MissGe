//
//  MLUserModel.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/12.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import ObjectMapper

class MLUserModel: Mappable {
    var username: String?
    var nickname: String?
    var autograph: String?
    var uid: String = ""

    var verify_img_width: Int = 0
    var verify_img_height: Int = 0

    var relation: Int = 0 // 1 是好友
    
    var avatar: URL?
    
    var verify: String?
    var verify_img: String?
    
    // 个人详情页
    var p_bests: Int = 0
    var follow_cnt: Int = 0
    var fans_cnt: Int = 0
    var gender: Int = 0

    var birthday: String?
    var location: String?

    
    // 登录
    var token: String?
    
    required init?(map: Map) {
        if self.username == nil || self.username?.length == 0 {
            if let uname = map.JSON["uname"] as? String {
                self.username = uname
            }
        }
    }
    
    // Mappable
    func mapping(map: Map) {
        username            <- map["username"]
        nickname            <- map["nickname"]
        autograph           <- (map["autograph"], transfromOfEmojiAndString())
        uid                 <- map["uid"]
        verify_img_width    <- map["verify_img_width"]
        verify_img_height   <- map["verify_img_height"]
        relation            <- map["relation"]
        avatar              <- (map["avatar"], transfromOfURLAndString())
        verify              <- map["verify"]
        verify_img          <- map["verify_img"]
        p_bests             <- map["p_bests"]
        follow_cnt          <- map["follow_cnt"]
        fans_cnt            <- map["fans_cnt"]
        gender              <- map["gender"]
        location            <- map["location"]
        token               <- map["token"]
        birthday            <- (map["birthday"], transfromOfDateString())
    }
}

//将"yyyy-MM-dd"格式的string转成date
func transfromOfDateString() -> TransformOf<String , String>{
    return TransformOf<String , String>.init(fromJSON: { (JSONString) -> String? in
        if let str = JSONString{
            return NSDate(fromStringOrNumber:(str as AnyObject)).standardChinaTimeDescription()
        }
        return nil
    }, toJSON: { (date) -> String? in
        if let date = date{
            return date
        }
        return nil
    })
}

//将"yyyy-MM-dd"格式的string转成date
func transfromOfDateStringCustom() -> TransformOf<String , String>{
    return TransformOf<String , String>.init(fromJSON: { (JSONString) -> String? in
        if let str = JSONString{
            return NSDate(fromStringOrNumber:(str as AnyObject)).customTimeDescription()
        }
        return nil
    }, toJSON: { (date) -> String? in
        if let date = date{
            return date
        }
        return nil
    })
}

//将"yyyy-MM-dd"格式的string转成date
func transfromOfDateAndString() -> TransformOf<Date , String>{
    return TransformOf<Date , String>.init(fromJSON: { (JSONString) -> Date? in
            if let str = JSONString{
                return DateFormatter.default().date(from: str)!
            }
            return nil
        }, toJSON: { (date) -> String? in
            if let date = date{
                return DateFormatter.default().string(from: date as Date)
            }
            return nil
    })
}

//将str转成url
func transfromOfURLAndString() -> TransformOf<URL, String>{
    return TransformOf<URL, String>.init(fromJSON: { (JSONString) -> URL? in
        if let str = JSONString{
            return URL.init(string: str)
        }
        return nil
    }, toJSON: { (url) -> String? in
        if let url = url {
            return url.absoluteString
        }
        return nil
    })
}

func transfromOfBoolAndString() -> TransformOf<Bool, String> {
    return TransformOf<Bool, String>.init(fromJSON: { (JSON) -> Bool in
        if let str = JSON as NSString? {
            return str.boolValue
        }
        return false
    }, toJSON: { (result) -> String? in
        if let result = result {
            return "\(result)"
        }
        return nil
    })
}

func transfromOfEmojiAndString() -> TransformOf<String, String> {
    return TransformOf<String, String>.init(fromJSON: { (JSON) -> String? in
        if let str = JSON {
            return str.emojiUnescapedString
        }
        return nil
    }, toJSON: { (result) -> String? in
        if let result = result {
            return result.emojiEscapedString
        }
        return nil
    })
}
