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
let BN_NavHeight:CGFloat = UIDevice.iPhoneX ? 70.0 : 64.0

//tabbar高度
let BN_TabHeight:CGFloat = UIDevice.iPhoneX ? (49 + 34) : 49

public extension UIDevice {

    // 判断是否为刘海屏
    class var iPhoneX: Bool {
        var isPhoneX = false
        if #available(iOS 11.0, *) {
            isPhoneX = (UIApplication.shared.delegate?.window!!.safeAreaInsets.bottom)! > 0.0
        }
        return isPhoneX
    }
    
}
