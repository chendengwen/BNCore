//
//  UIImageViewExtension.swift
//  Example02
//
//  Created by gary on 2020/4/30.
//  Copyright © 2020 gary. All rights reserved.
//

import Foundation
import UIKit

/**
 图片必须为png格式
 */
public enum BNPlaceHolderImage {
    case default_large
    case default_small
    case custom(imageName:String) //自定义图
    
    var description: String {
        switch self {
        case .default_large:
            return "holderImage_large"
        case .default_small:
            return "holderImage_small"
        case .custom(let imageName):
            return imageName
        }
    }
}

public extension UIImageView {
    
    func setImage(for url:String, placeHolder holderImage:BNPlaceHolderImage?) {
        setImage(for: url, placeHolder: holderImage, loadCacheImage: true)
    }
    
    func setImageNoCache(for url:String, placeHolder holderImage:BNPlaceHolderImage?) {
        setImage(for: url, placeHolder: holderImage, loadCacheImage: false)
    }
    
    func setImage(for url:String, placeHolder holderImage:BNPlaceHolderImage?, loadCacheImage cache:Bool) {
        DispatchQueue.default.async {
            let image = BNImageCache.shared.getImageCache(for: url)
            if !cache || image  == nil {
                if holderImage != nil {
                    DispatchQueue.global().async {
                        let bundle_framework = Bundle.init(for: BNCache.self)
                        let bundle_bundle = Bundle.path(forResource: "BNCore", ofType: "bundle", inDirectory: "\(bundle_framework.bundlePath)")
                        let bundle = Bundle.init(path: bundle_bundle!)

                        var tmpImage:UIImage?
                        
                        switch holderImage {
                        case .default_large, .default_small:
                            tmpImage = UIImage.init(named: holderImage!.description, in: bundle, compatibleWith: nil)
                        case .custom(let _name):
                            tmpImage = UIImage.init(named:_name)
                        case .none:
                            tmpImage = nil
                        }
                        
                        DispatchQueue.main.sync {
                            self.image = tmpImage
                        }
                    }
                }
            } else if cache {
                DispatchQueue.main.sync {
                    self.image = image
                }
            }
        }
        
        if image == nil {
            BNRequestManager.shared.request(type: .Download, url: url) { (dict, error) in
                if error != nil {
                    print(error!)
                } else {
                    let image = BNImageCache.shared.getImageCache(for: url)
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
        
    }
    
}
