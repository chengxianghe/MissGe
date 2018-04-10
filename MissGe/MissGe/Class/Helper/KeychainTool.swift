//
//  KeychainTool.swift
//  MissGe
//
//  Created by chengxianghe on 2017/4/12.
//  Copyright © 2017年 cn. All rights reserved.
//

import Foundation
import KeychainAccess

class KeychainTool {
        
    static func save(service: String, data: String?) {
        let keychain = Keychain(service: service)
        keychain[service] = data
    }
    
    static func load(_ service: String) -> String? {
        let keychain = Keychain(service: service)
        let token = keychain[service]
        return token
    }
    
    static func delete(service: String) {
        let keychain = Keychain(service: service)
        do {
            try keychain.remove(service)
        } catch let error {
            print("keychain delete error: \(error)")
        }
    }
}
