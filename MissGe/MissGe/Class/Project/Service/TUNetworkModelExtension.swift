//
//  LLToModelExtension.swift
//  LLProgramFrameworkSwift
//
//  Created by 奥卡姆 on 2017/9/7.
//  Copyright © 2017年 aokamu. All rights reserved.
//

import Foundation

import RxSwift
import Moya
import ObjectMapper


extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
 
    /// Maps data received from the signal into a JSON object. If the conversion fails, the signal errors.
    public func mapParseJSON(failsOnEmptyData: Bool = true) -> Single<Any> {
        return flatMap { response -> Single<Any> in
            return Single.just(try response.mapParseJSON(failsOnEmptyData: failsOnEmptyData))
        }
    }
    
    /// Maps data received from the signal into an object
    /// which implements the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil, keyPath: String? = nil) -> Single<T> {
        return flatMap { response -> Single<T> in
            return Single.just(try response.mapObject(type, context: context, keyPath: keyPath))
        }
    }
    
    /// Maps data received from the signal into an array of objects
    /// which implement the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil, keyPath: String? = nil) -> Single<[T]> {
        return flatMap { response -> Single<[T]> in
            return Single.just(try response.mapArray(type, context: context, keyPath: keyPath))
        }
    }
    
}
extension Response {

    /// Maps data received from the signal into a JSON object.
    public func mapParseJSON(failsOnEmptyData: Bool = true) throws -> Any {
        var resultObject:Any? = nil
        do {
            resultObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            if data.count < 1 && !failsOnEmptyData {
                return NSNull()
            }
            throw MoyaError.jsonMapping(self)
        }
        guard let dict = resultObject as? [String : Any] else{
            throw RxSwiftMoyaError.ParseJSONError
        }
        //后台的数据每次会返回code只有是200才会表示逻辑正常执行
        if let code = dict["result"] as? String {
            if code != "200" {
                var msg = ""
                if let message = dict["msg"] as? String {
                    msg = message
                }
                let error = NSError(domain: "Network", code: Int(code)!, userInfo: [NSLocalizedDescriptionKey: msg])
                print(error)
                throw RxSwiftMoyaError.OtherError
            }
        }
        return resultObject!
    }
    
    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil, keyPath: String? = nil) throws -> T {
        if keyPath != nil {
            guard let object = Mapper<T>(context: context).map(JSONObject: (try mapJSON() as? NSDictionary)?.value(forKeyPath: keyPath!)) else {
                throw MoyaError.jsonMapping(self)
            }
            return object
        } else {
            guard let object = Mapper<T>(context: context).map(JSONObject: try mapJSON()) else {
                throw MoyaError.jsonMapping(self)
            }
            return object
        }
    }
    
    /// Maps data received from the signal into an array of objects which implement the Mappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil, keyPath: String? = nil) throws -> [T] {
        if keyPath != nil {
            let result = try mapJSON() as? NSDictionary
            guard let array = (result?.value(forKeyPath: keyPath!)) as? [[String : Any]] else {
                if (result?["result"] as? String) ?? "0" == "200" {
                    throw RxSwiftMoyaError.DataEmpty
                } else {
                    throw MoyaError.jsonMapping(self)
                }
            }
            return Mapper<T>(context: context).mapArray(JSONArray: array)
        } else {
            guard let array = try mapJSON() as? [[String : Any]] else {
                throw MoyaError.jsonMapping(self)
            }
            return Mapper<T>(context: context).mapArray(JSONArray: array)
        }

    }
}

enum RxSwiftMoyaError: String {
    case ParseJSONError
    case DataEmpty
    case OtherError
}

extension RxSwiftMoyaError: Swift.Error {
    
}

extension RxSwiftMoyaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .ParseJSONError:
            return "Failed to map data to JSON."
        case .DataEmpty:
            return "NO Data."
        case .OtherError:
            return "Failed."
        }
    }
}


