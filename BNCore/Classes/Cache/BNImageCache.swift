//
//  BNImageCache.swift
//  BNCore
//
//  Created by gary on 2020/4/27.
//

import Foundation
import UIKit
import ImageIO

let LongDefaultSize = 256

public class BNImageCache {
    
    public static let shared = BNImageCache()
    
    var imageKeysArray = [String]()
    var imagesDictionary = [String:UIImage]()
    
    var mutexLock = pthread_mutex_t()
    
    init() {
        pthread_mutex_init(&mutexLock, nil)
    }
    
    public func storeImageCache(data: Data, for key: String, toDisk disk:Bool) {
        if key.count <= 0 || data.count <= 0 { return }
        
        let image = UIImage.init(data: data)
        if image != nil {
            let md5Key = key.md5()
            setImage(image: image!, for: md5Key)
            BNCache.shared.storeCache(data: data, for: md5Key, inMemary: false, toDisk: true)
        }
    }
    
    public func getImageCache(for key: String) -> UIImage? {
        
        let md5Key = key.md5()
        var image: UIImage? = getImage(for: md5Key)
        
        if image != nil {
            return image
        }
        
        let data = BNCache.shared.getCache(for: md5Key)
        guard let _ = data else {
            return nil
        }
        image = UIImage.init(data: data!)
        setImage(image: image!, for: key)
        
        return image
    }
    
    public func clearAllImageCache() {
        imagesDictionary.removeAll()
        imageKeysArray.removeAll()
    }
    
    //:Mark -- private
    private func setImage(image: UIImage, for key: String) {
        
        pthread_mutex_lock(&mutexLock)
        
        if imageKeysArray.count > LongDefaultSize {
            let lastKey = imageKeysArray.last!
            imagesDictionary.removeValue(forKey: lastKey)
            imageKeysArray.removeLast()
            
            imagesDictionary[key] = image
            imageKeysArray.insert(key, at: 0)
        } else {
            if imagesDictionary.keys.contains(key) {
                imageKeysArray.removeAll([key])
            }
            
            imagesDictionary[key] = image
            imageKeysArray.insert(key, at: 0)
        }
        
        pthread_mutex_unlock(&mutexLock)
    }
    
    private func getImage(for key: String) -> UIImage? {
        
        var image: UIImage?
        
        pthread_mutex_lock(&mutexLock)
        
        image = imagesDictionary[key]
        
        pthread_mutex_unlock(&mutexLock)
        return image
    }
    
    
    private func typeOfImage(imageData: Data) -> String? {
        var c: UInt8 = 0
        imageData.copyBytes(to: &c, count: 1)
        switch c {
        case 0xFF:
            return "image/jpeg";
        case 0x89:
            return "image/png";
        case 0x47:
            return "image/gif";
        case 0x49,0x4D:
            return "image/tiff";
        case 0x52:
            // R as RIFF for WEBP
            if imageData.count < 12 {
                return nil
            }
            let type = String.init(data: imageData.subdata(in: 0..<12), encoding: String.Encoding.ascii)
            if type != nil && type!.hasPrefix("RIFF") && type!.hasSuffix("WEBP") {
                return "image/webp"
            }
            return nil
        default:
            return nil
        
        }
    }
}
