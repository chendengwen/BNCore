//
//  Serializable.swift
//  Example02
//
//  Created by gary on 2020/4/30.
//  Copyright © 2020 gary. All rights reserved.
//

import Foundation

public protocol Serializable {
    
}

extension Dictionary: Serializable {
    public typealias Key = String
    public typealias Value = Any
    
    
}

extension Array: Serializable {
    public typealias Element = Any
}

extension Data: Serializable {}
