//
//  BNFileCache.swift
//  BNCore
//
//  Created by gary on 2020/4/28.
//

import Foundation

public enum BNFileType: String {
    case none = ""
    case TXT = ".txt"
    case Plist = ".plist"
    case Json = "json"
    case Html = ".html"
}

let DefaultBngrpCacheFilePath = "/Documents/BNCache/File"

public class BNFileCache {
    
    public static let shared = BNFileCache()
    
    var diskCachePath:String = "\(NSHomeDirectory())\(DefaultBngrpCacheFilePath)"
    
    public func storeObject(object: Serializable, fileName name: String, type: BNFileType, result block:@escaping (Bool)->Void) {
        let dictionary = object as? Dictionary<String, Any>
        let array = object as? Array<Any>
        
        guard (dictionary != nil && dictionary!.keys.count > 0) || (array != nil && array!.count > 0) else {
            block(false)
            return
        }
        
        let data = try? JSONSerialization.data(withJSONObject: object, options: [])
        guard let tempData:Data = data else {
            block(false)
            return
        }
        
        DispatchQueue.global().async { [unowned self] in
            let filePath = "\(self.diskCachePath)/\(name).\(type.rawValue)"
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: filePath) {
                try! fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
            }
            
            let result: ()? = try? tempData.write(to: URL.init(fileURLWithPath: filePath), options: .atomic)
            if result != nil {
                block(true)
            } else {
                block(false)
            }
        }
    }
    
    public func getObject<T>(fileName name: String, type: BNFileType, dataType: T.Type, result block:@escaping (T?)->Void) where T : Serializable {
        if name.count <= 0 {
            block(nil)
        } else {
            let filePath = "\(self.diskCachePath)/\(name).\(type.rawValue)"
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                DispatchQueue.global().async {
                    if dataType == Dictionary<String, Any>.self {
                        let dictionary = NSDictionary.init(contentsOf: URL.init(string: "file://\(filePath)")!)
                        if dictionary == nil {
                            block(nil)
                        } else {
                            let dic:Dictionary<String, Any> = dictionary as! Dictionary<String, Any>
                            block(dic as? T)
                        }
                    } else if dataType == Array<Any>.self || dataType == Array<Dictionary<String,Any>>.self {
                        let data = try? Data.init(contentsOf: URL.init(string: "file://\(filePath)")!)
                        if data == nil {
                            block(nil)
                        } else {
                            let array = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                            if array != nil {
                                block(array as? T)
                            } else {
                                block(nil)
                            }
//                            let arr:Array<Any> = array as! Array<Any>
//                            block(arr as? T)
                        }
                    } else if dataType == Data.self {
                        let data = try? Data.init(contentsOf: URL.init(string: "file://\(filePath)")!)
                        if let _:Data = data {
                            block(data as? T)
                        } else {
                            block(nil)
                        }
                    } else {
                        block(nil)
                    }
                }
            } else {
                block(nil)
            }
        }
    }
    
}
