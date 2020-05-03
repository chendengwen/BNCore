//
//  StringExtension.swift
//  BNOA
//
//  Created by Cary on 2019/11/8.
//  Copyright © 2019 BNIC. All rights reserved.
//

import UIKit
import CommonCrypto

public extension String {
    func substring(from index: Int) -> String {
        if self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[startIndex..<self.endIndex]
            return String(subString)
        } else {
            return self
        }
    }
    
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize(count: 32)
        
        return String(format: hash as String)
    }

}

/** 字符串的MD5加密测试
 加密前：我是要加密的字符串
 加密后：7fbdc46a4e51335d3cf567ecfc1eb2f5
 加密前：55555555555
 加密后：9079b6ee1d5ca04ab00e44e877a222ee
 */
