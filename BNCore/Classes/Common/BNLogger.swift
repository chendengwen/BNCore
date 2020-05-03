//
//  BNLogger.swift
//  BNCore
//
//  Created by 陈登文 on 2020/5/3.
//

import Foundation

public func Log(_ message: String) {
    #if DEBUG
    print(message, separator: " ", terminator: "\n")
    #endif
}

public func Log(items: Any...) {
    #if DEBUG
    debugPrint(items, separator: " ", terminator: "\n")
    #endif
}

public func LogWithDetail<T>(_ message: T, file: String = #file, function: String = #function, lineNumber: Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("[\(fileName):funciton:\(function):line:\(lineNumber)]- \(message)")
    #endif
}
