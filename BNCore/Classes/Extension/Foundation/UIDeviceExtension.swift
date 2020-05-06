//
//  UIDeviceExtension.swift
//  Example02
//
//  Created by gary on 2020/5/6.
//  Copyright © 2020 gary. All rights reserved.
//

import Foundation
import UIKit

// 屏幕宽度与高度
let BN_SCREEN_WIDTH:CGFloat = UIScreen.main.bounds.width
let BN_SCREEN_HEIGHT:CGFloat = UIScreen.main.bounds.height

// 导航栏高度
let NavHeight:CGFloat = UIDevice.iPhoneX ? 70.0 : 64.0

//tabbar高度
let TabHeight:CGFloat = UIDevice.iPhoneX ? (49 + 34) : 49

extension UIDevice {
    
    // 判断是否为iPhone X 系列 -- 方式一
    class var iPhoneX: Bool {
        if BN_SCREEN_HEIGHT == 812 || BN_SCREEN_HEIGHT == 896 {
            return true
        }
        return false
    }
    
    // 判断是否为iPhone X 系列 -- 方式二
    public func isPhoneX() -> Bool {
        var isPhoneX = false
        if #available(iOS 11.0, *) {
            isPhoneX = UIApplication.shared.delegate?.window!?.safeAreaInsets.bottom as! CGFloat > 0.0
        }
        return isPhoneX
    }
    
}
