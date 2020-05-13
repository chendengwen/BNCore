//
//  BNRequestManager.swift
//  BNCore
//
//  Created by gary on 2020/4/26.
//

import Foundation

let sharedSession = URLSession.shared

public class BNRequestManager: NSObject {
    
    public static let shared = BNRequestManager()
    
    let serialQueue = BNDispatchQueue.init()
    var requestDic = [String: BNSessionTask]()
    var mutexLock = pthread_mutex_t()
    
    private let sessionDelegate = BNSessionDelegate()
    let customSession: URLSession!
    
    override init() {
        pthread_mutex_init(&mutexLock, nil)
        serialQueue.schedule(repeating: 0.2) // 开启任务队列RunLoop
        
        let sessionConfig = URLSessionConfiguration.`default`
        if #available(iOS 11.0, *) {
            sessionConfig.waitsForConnectivity = true
        } else {
            // Fallback on earlier versions
        }
        customSession = URLSession.init(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
//        customSession = URLSession.init(configuration: sessionConfig, delegate: sessionDelegate, delegateQueue: nil)
//        let url2 = URL(string: "http://static.tvmaze.com/uploads/images/medium_portrait/1/3603.jpg")
//        let backgroundTask = customSession.downloadTask(with: url2!)
//        backgroundTask.resume()
    }
    
    deinit {
        pthread_mutex_destroy(&mutexLock)
    }
    
    public func request(type: BNRequestType = .Get, url: String, headers: [String:String] = [:], params: [String:Any] = [:], data: Data? = nil, timeout: TimeInterval = 10, progress: @escaping ((Int64, Int64) -> ()) = { a,b in }, completion: @escaping (Serializable?, BNRequestError?) -> Void) {
        
        let request = URLRequest.init(type: type, url: url, headers: headers)
        
        let sessionTask = BNSessionTask.init(request: request)
        let semaphore = DispatchSemaphore(value: 0)
        
        switch type {
        case .Get, .Post:
            sessionTask.generateRequestTask { [weak self] (data, response, error) in

                print(error ?? response!)
                
                if error != nil || data == nil || response == nil {
                    completion(nil, .custom(message: error?.localizedDescription ?? String.errorMessage(msg: "error = nil", other: "Get/Post")))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        completion(nil, BNRequestError.UnKnown)
                        return
                }
                
                if let mimeType = httpResponse.mimeType, mimeType == "application/json", // text/html
                let data = data {
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                        if let _ :Array<Any> = jsonObj as? Array<Any> {
                            completion(jsonObj as! Array<Any>, nil)
                        } else if let _ :[String : Any] = jsonObj as? [String : Any] {
                            completion(jsonObj as! [String : Any], nil)
                        } else if let _ :Data = jsonObj as? Data {
                            completion(jsonObj as! Data, nil)
                        } else {
                            completion(nil, BNRequestError.custom(message: String.errorMessage(msg: "数据格式异常", other: "Get/Post")))
                        }
                    } else {
                        completion(nil, BNRequestError.DataParseError)
                    }
                }
                
                self?._removeRequest(request: sessionTask, withKey: url)
                semaphore.signal()
            }
            
        case .Download:
            sessionTask.generateDownloadTask(session: customSession, progressHandler: { (total, now) in
                progress(total, now)
            }) { [weak self] ( location, response, error) in
                print(error ?? response!)
                
                guard error == nil else {
                    completion(nil, .custom(message: error?.localizedDescription ?? String.errorMessage(msg: "error = nil", other: "Download")))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        completion(nil, .UnKnown)
                        return
                }
                
                //输出下载文件原来的存放目录
                print("location:\(location?.description ?? "nil")")
                
                guard let _ = location else {
                    completion(nil, .UnKnown)
                    return
                }
                let imageData = try! Data.init(contentsOf: location!)
                BNImageCache.shared.storeImageCache(data: imageData, for: url, toDisk: true)
                
                completion(["code": 200, "msg": "成功"], nil)
                
                self?._removeRequest(request: sessionTask, withKey: url)
                semaphore.signal()
            }
            
        case .Upload:
            if data != nil {
                sessionTask.generateUploadTask(session: customSession, data: data!) { (total, now) in
                    
                }
            } else {
                fatalError("上传数据为空，请检查")
            }
            
        }
        
        let task = sessionTask
        serialQueue.push(workItem: DispatchWorkItem.init(block: {
            task.start()
            self._setRequest(request: task, withKey: url)

            if semaphore.wait(timeout: .now() + timeout) == .timedOut {
                task.cancel()
                task.invalid()
            } else {
                task.invalid()
            }
        }))
    }
    
    public func cancelRequestWithUrl(url: String) {
        pthread_mutex_lock(&mutexLock)
        if let value = requestDic[url] {
            let sessionTask = value as BNSessionTask
            sessionTask.cancel()
        }
        pthread_mutex_unlock(&mutexLock)
    }
    
    //mark: ---- private method
    private func _setRequest(request: BNSessionTask, withKey url: String) {
        pthread_mutex_lock(&mutexLock)
        requestDic[url] = request
        pthread_mutex_unlock(&mutexLock)
    }
    
    private func _removeRequest(request: BNSessionTask, withKey url: String) {
        pthread_mutex_lock(&mutexLock)
        requestDic[url] = nil
        pthread_mutex_unlock(&mutexLock)
    }
}

