//
//  BNDownloader.swift
//  Example02
//
//  Created by gary on 2020/4/29.
//  Copyright © 2020 gary. All rights reserved.
//

import Foundation

class BNSessionDelegate: NSObject {


}

extension BNSessionDelegate: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("当前下载 = \(bytesWritten), 已经下载 = \(totalBytesWritten), 总共需要下载 = \(totalBytesExpectedToWrite)")
        print("\(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) * 100)%")
        print(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
        DispatchQueue.main.async {
            
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("fileOffset = \(fileOffset), expectedTotalBytes = \(expectedTotalBytes)")
    }
}

extension BNSessionDelegate: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust  {
            let credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        }
    }
}
