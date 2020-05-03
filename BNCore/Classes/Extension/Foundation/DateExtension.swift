//
//  DateExtension.swift
//  BNCore
//
//  Created by gary on 2020/4/26.
//

import Foundation

let dateFormatter = DateFormatter()

public extension Date {
    
    //时间戳
    //Date().timeIntervalSince1970
    
    /**
    //dateStyle和timeStyle默认都是none，两者至少有一个
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    
    dateStyle(medium和long对中文来说没区别)：
       .short      // 2019/5/10
       .medium     // 2019年5月10日
       .long       // 2019年5月10日
       .full       // 2019年5月10日 星期五
    
    timeStyle：
       .short      // 下午10:22
       .medium     // 下午10:22:22
       .long       // GMT+8 下午10:22:22
       .full       // 中国标准时间 下午10:22:22
    */
    
    func toString(formatter: String) -> String {
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: Date())
    }

    
}
