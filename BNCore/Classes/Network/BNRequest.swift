//
//  BNRequest.swift
//  BNCore
//
//  Created by gary on 2020/4/26.
//

import Foundation

let defaultTimeOut: TimeInterval = 10

public enum BNRequestType:String {
    case Get = "get"
    case Post = "post"
    case Download = "download"
    case Upload = "upload"
}

public enum BNRequestError: Error {

    case UnKnown
    case DataParseError
    case Timeout
    case custom(message: String)
    
    var description: String {
        switch self {
        case .UnKnown:
            return "未知错误"
        case .DataParseError:
            return "数据解析错误"
        case .Timeout:
            return "请求超时"
        case .custom(let message):
            return message
        }
    }
}


extension String {
    
    enum BNMessageType : String {
        case error = "error"
        case warning = "warning"
        case info = "info"
    }
    
    private static func message(type: BNMessageType, msg: String, other: String = "") -> String {
        let typeStr = type.rawValue
        return "\(typeStr):  \(#file) - \(#function) :: \(msg) : \(other)"
    }
    
    static func errorMessage(msg: String, other: String = "") -> String {
        message(type: .error, msg: msg, other: other)
    }
    
    static func warningMessage(msg: String, other: String = "") -> String {
        message(type: .warning, msg: msg, other: other)
    }
    
    static func infoMessage(msg: String, other: String = "") -> String {
        message(type: .info, msg: msg, other: other)
    }
}

extension URLRequest {
    
    init(type: BNRequestType, url: String, headers: [String:String]?, data: Serializable?, timeout: TimeInterval = defaultTimeOut) {
        let url : NSURL =  NSURL.init(string: url)!
        self.init(url: url as URL)
        
        let cachePolicy = (type == .Download ? URLRequest.CachePolicy.returnCacheDataElseLoad : URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData)
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeout
        if type == .Get || type == .Post {
            self.httpMethod = type.rawValue
        }
        
        if type == .Post {
            var _data:Data = Data()
            if let _ :Array<Any> = data as? Array<Any> {
                let temp = try! JSONSerialization.data(withJSONObject: data!, options: [])
                _data = temp
            } else if let _ :[String : Any] = data as? [String : Any] {
                let temp = try! JSONSerialization.data(withJSONObject: data!, options: [])
                _data = temp
            } else if let _ :Data = data as? Data {
                _data = data as! Data
            }
            
            self.httpBody = _data
        }
        self.allHTTPHeaderFields = headers
    }
}
