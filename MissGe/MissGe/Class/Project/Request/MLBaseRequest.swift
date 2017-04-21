//
//  MLBaseRequest.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/19.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import TUNetworking

class MLBaseRequest: TUBaseRequest {
    override func requestConfig() -> TUNetworkConfigProtocol {
        return MLNetConfig.config()
    }
}
