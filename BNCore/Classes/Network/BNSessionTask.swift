//
//  BNRequest.swift
//  BNCore
//
//  Created by gary on 2020/4/26.
//

import Foundation

//(Int64,Int64)->() => { a,b in }
//()->(Int64,Int64) => {(0,0)}

private let SendDataKeyPath = NSStringFromSelector(#selector(getter: URLSessionTask.countOfBytesSent))
private let ReceivedDataKeyPath = NSStringFromSelector(#selector(getter: URLSessionTask.countOfBytesReceived))

public class BNSessionTask:NSObject {
    
    private var request: URLRequest!
    
    
    var task: URLSessionTask?
    
    var dataHandler: ((Int64, Int64)->Void)? // 数据上传/下载进度回调
    var keyPath: String?
    
    init(request req: URLRequest) {
        request = req
    }
    
    //此任务用于HTTP GET请求，以将数据从服务器检索到内存
    func generateRequestTask(session: URLSession = sharedSession, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        task = session.dataTask(with: request, completionHandler: completionHandler)
    }
    
    //此任务将文件从远程服务下载到临时文件位置
    func generateDownloadTask(session: URLSession, progressHandler:  @escaping (Int64, Int64) -> Void, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) {
        task = session.downloadTask(with: request, completionHandler: completionHandler)
        dataHandler = progressHandler
        keyPath = ReceivedDataKeyPath
        task?.addObserver(self, forKeyPath: keyPath!, options: .new, context: nil)
    }
    
    //此任务通常通过 POST或PUT方法将文件从磁盘上传到Web服务
    func generateUploadTask(session: URLSession, data: Data, progressHandler:  @escaping (Int64?, Int64?) -> Void) {
        
        task = session.uploadTask(with: request, from: Data())
        dataHandler = progressHandler
        keyPath = SendDataKeyPath
        task?.addObserver(self, forKeyPath: keyPath!, options: .new, context: nil)
    }
    
    func start() {
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
    }
    
    func invalid() {
        guard let _ = keyPath else {
            return
        }
        
        task?.removeObserver(self, forKeyPath: keyPath!)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath?.elementsEqual(ReceivedDataKeyPath))! {
            let task = object as! URLSessionDownloadTask
            let total = task.countOfBytesExpectedToReceive >= task.countOfBytesReceived ? task.countOfBytesExpectedToReceive : task.countOfBytesReceived
            dataHandler!(total, task.countOfBytesReceived)
        } else if (keyPath?.elementsEqual(SendDataKeyPath))! {
            let task = object as! URLSessionUploadTask
            let total = task.countOfBytesExpectedToSend >= task.countOfBytesSent ? task.countOfBytesExpectedToSend : task.countOfBytesSent
            dataHandler!(total, task.countOfBytesSent)
        }
    }
    
}

extension BNSessionTask {
    public override var hash: Int {
        return task.hashValue
    }
    
    static func ==(lhs: BNSessionTask, rhs: BNSessionTask) -> Bool {
        return lhs.task == rhs.task
    }
}
