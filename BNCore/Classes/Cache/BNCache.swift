//
//  BNCache.swift
//  BNCore
//
//  Created by gary on 2020/4/27.
//

import Foundation

let DefaultMaxCacheSize: UInt64 = 256 * 256
let DefaultMaxCacheDataSize: UInt64 = 1024 * 1024 * 128
let DefaultBngrpCachePath = "/Documents/BNCache"

public class BNCache {
    
    public static let shared = BNCache()
    
    var mutexLock = pthread_mutex_t()
    let cacheQueue = DispatchQueue.init(label: "com.bncache.queue")
    var cacheQueues = [DispatchQueue]() //用于比较耗时的文件读写操作
    
    var cacheDataDic = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil)
    var diskCachePath:String = "\(NSHomeDirectory())\(DefaultBngrpCachePath)"
    var totalSize:UInt64 = 0
    var maxTotalSize:UInt64 = DefaultMaxCacheSize
    
    init() {
        pthread_mutex_init(&mutexLock, nil)
        
        for index in 0..<5 {
            cacheQueues.append(DispatchQueue.init(label: "com.bncache.queue.\(index)", target: cacheQueue))
        }
    }
    
    deinit {
        pthread_mutex_destroy(&mutexLock)
    }
    
    //:Mark - public
    public func storeCache(data: Data, for key: String) {
        storeCache(data: data, for: key, toDisk: false)
    }
    
    public func storeCache(data: Data, for key: String, toDisk disk: Bool) {
        storeCache(data: data, for: key, inMemary: true, toDisk: disk)
    }
    
    public func storeCache(data: Data, for key: String, inMemary memary: Bool, toDisk disk: Bool) {
        if data.count == 0 || key.count == 0 { return }
        
        pthread_mutex_lock(&mutexLock)
        
        if memary {
            var _key = key, _data = data
            let rawKey = withUnsafePointer(to: &_key, { UnsafeRawPointer($0) })
            let rawValue = withUnsafePointer(to: &_data, { UnsafeRawPointer($0) })
            if !CFDictionaryContainsKey(cacheDataDic, rawKey) {
                CFDictionarySetValue(cacheDataDic, rawKey, rawValue)
                totalSize += UInt64(data.count)
            }
        }
        
        if disk {
            saveCacheToDisk(data: data, for: key)
        }
        
        pthread_mutex_unlock(&mutexLock)
    }
    
    public func getCache(for key: String) -> Data? {
        var data:Data? = nil
        
        pthread_mutex_lock(&mutexLock)
        
        var _key = key
        let rawKey = withUnsafePointer(to: &_key, { UnsafeRawPointer($0) })
        if CFDictionaryContainsKey(cacheDataDic, rawKey) {
            data = CFDictionaryGetValue(cacheDataDic, rawKey)?.load(as: Data.self)
        }
        if data == nil {
            data = getCacheDataFromDisk(for: key)
        }
        
        pthread_mutex_unlock(&mutexLock)
        return data
    }
    
    public func clearCache(for key: String) {
        clearCache(for: key, fromDisk: false)
    }
    
    public func clearCache(for key: String, fromDisk disk: Bool) {
        pthread_mutex_lock(&mutexLock)
        
        removeCacheData(for: key, fromDisk: disk)
        
        pthread_mutex_unlock(&mutexLock)
    }
    
    public func clearAllCache() {
        pthread_mutex_lock(&mutexLock)
        
        CFDictionaryRemoveAllValues(cacheDataDic)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: diskCachePath) {
            try? fileManager.removeItem(atPath: diskCachePath)
        }
        
        pthread_mutex_unlock(&mutexLock)
    }
    
    public func diskFileCount() -> UInt64 {
        var count:UInt64 = 0
        let fileManager = FileManager.default
        cacheQueue.sync {
            let fileEnumerator = fileManager.enumerator(atPath: diskCachePath)
            count = UInt64(fileEnumerator?.allObjects.count ?? 0)
        }
        return count
    }
    
    public func diskSize() -> UInt64 {
        var size:UInt64 = 0
        let fileManager = FileManager.default
        cacheQueue.sync {
            let fileEnumerator = fileManager.enumerator(atPath: diskCachePath)
            while let fileName = fileEnumerator?.nextObject() {
                let filePath = "\(diskCachePath)/\(fileName)"
                let attrs = try? fileManager.attributesOfItem(atPath: filePath)
                if let ats:[FileAttributeKey : Any] = attrs {
                    size += ats[FileAttributeKey.size] as! UInt64
                }
            }
        }
        return size
    }
    
    
    //:Mark - private
    private func saveCacheToDisk(data: Data, for key: String) {
        if data.count == 0 || key.count == 0 { return }
        
        let queueIndex = abs(key.hashValue % 5)
        cacheQueues[queueIndex].async { [weak self] in
            if self != nil {
                
                let fileManager = FileManager.default
                if !fileManager.fileExists(atPath: self!.diskCachePath) {
                    try! fileManager.createDirectory(atPath: self!.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                }
                
                let filePath = self!.getCacheFilePath(for: key)
                try! data.write(to: URL.init(string: "file://\(filePath)")!, options: .atomic)
            }
             
        }
    }
    
    private func removeCacheData(for key: String) {
        removeCacheData(for: key, fromDisk: false)
    }
    
    private func removeCacheData(for key: String, fromDisk disk: Bool) {
        
        var _key = key
        let rawKey = withUnsafePointer(to: &_key, { UnsafeRawPointer($0) })
        CFDictionaryRemoveValue(cacheDataDic, rawKey)
        
        if disk {
            let queueIndex = key.hashValue % 10
            cacheQueues[queueIndex].async { [weak self] in
                if self != nil {
                    let filePath = self!.getCacheFilePath(for: key)
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: filePath) {
                        try? fileManager.removeItem(atPath: filePath)
                    }
                }
            }
        }
        
    }
    
    private func getCacheDataFromDisk(for key: String) -> Data? {
        var result:Data? = nil
        
        let filePath = getCacheFilePath(for: key)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            result = try? Data.init(contentsOf: URL.init(string: "file://\(filePath)")!)
            if let ret:Data = result {
                var _key = key, _data = ret
                let rawKey = withUnsafePointer(to: &_key, { UnsafeRawPointer($0) })
                let rawValue = withUnsafePointer(to: &_data, { UnsafeRawPointer($0) })
                CFDictionarySetValue(cacheDataDic, rawKey, rawValue)
                return ret
            }
        }
        return result
    }
    
    private func getCacheFilePath(for key: String) -> String {
        let md5Key = key.md5()
        return "\(diskCachePath)/\(md5Key)_bncache"
    }
}

/**
 //数据对象转指针存入容器
 let rawKey = withUnsafePointer(to: &key, { UnsafeRawPointer($0)})
 let rawValue = withUnsafePointer(to: &value, { UnsafeRawPointer($0)})
 CFDictionarySetValue(_dic, rawKey, rawValue)
 
 //根据key的指针获取值指针
 let rawPointer = CFDictionaryGetValue(_dic, rawKey)
 print("\(String(describing: rawPointer))")
 
 //获取指针的值
 let xx = rawPointer?.load(as: String.self)
 */
