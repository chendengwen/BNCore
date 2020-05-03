//
//  BNDispatch.swift
//  BNCore
//
//  Created by gary on 2020/4/26.
//

import Foundation

public class BNDispatch {

    private static let DefaultMaxConcurrentCount = 10
    
    //处理添加的任务的队列
    private let serialQueue = DispatchQueue.init(label: "com.bngrp.serial.DispatchQueue.\(Date().timeIntervalSince1970)")
    private let concurrentQueue = DispatchQueue.init(label: "com.bngrp.concurrent.DispatchQueue.\(Date().timeIntervalSince1970)", attributes: [.concurrent])
    //处理内部任务的队列
    private let innerQueue = DispatchQueue.init(label: "com.bngrp.inner.DispatchQueue.\(Date().timeIntervalSince1970)")
    private var pollingTimer: DispatchSourceTimer?
    private var mutexLock = pthread_mutex_t()
    private var semaphore: DispatchSemaphore?
    
    private var workItemQueue = BNDispatchQueue.init()
    private var maxConcurrentCount:Int?
    private var isCancel: Bool = false
    private var cancelTime: TimeInterval = 0
    private var stopLoop: Bool = true
    
    //:Mark init
    init() {
        createQueue(maxCount: BNDispatch.DefaultMaxConcurrentCount)
    }
    
    public init(maxCount: Int) {
       createQueue(maxCount: maxCount)
    }
    
    private func createQueue(maxCount: Int) {
        maxConcurrentCount = maxCount
        semaphore = DispatchSemaphore.init(value: maxConcurrentCount!) //初始化信号量为10
        pthread_mutex_init(&mutexLock, nil)
    }
    
    deinit {
         pthread_mutex_destroy(&mutexLock)
    }
    
    //:Mark public
    public func addTask(workItem: DispatchWorkItem) {
        resetCancel()
        
        var _workItem: DispatchWorkItem? = nil
        _workItem = DispatchWorkItem.init { [weak self] in
            if self != nil {
                if !self!.isCancel {
                    if _workItem?.isCancelled ?? false || self!.isCancel {
                        self?.semaphore?.signal()
                    } else {
                        self?.concurrentQueue.async {
                            workItem.perform()
                            self?.semaphore?.signal()
                        }
                    }
                } else {
                    self!.semaphore?.signal()
                }
            }
        }
        workItemQueue.push(workItem: workItem)
        
        innerQueue.async { [weak self] in
            if self != nil {
                if self!.stopLoop {
                    self!.dealLoop()
                }
            }
        }
    }
    
    public func cancelAll() {
        cancelTime = Date().timeIntervalSince1970
        innerQueue.async { [weak self] in
            if self != nil {
                self!.isCancel = true
                self!.workItemQueue.clear()
            }
        }
    }
    
    //:Mark private
    private func resetCancel() {
        if cancelTime != 0 {
            let now = Date().timeIntervalSince1970
            if now > cancelTime {
                cancelTime = 0
            }
            isCancel = false
        }
    }
    
    //Loop就是一个定时器，定时读取任务执行。 任务执行完以后关闭定时器
    private func dealLoop() {
        //Loop未关闭时不用做处理
        if !stopLoop { return }
        
        //Loop关闭时重新开启定时器
        stopLoop = false
        innerQueue.async { [weak self] in
            if self != nil {
                self?.pollingTimer = DispatchSource.makeTimerSource(queue: self?.innerQueue)
                self?.pollingTimer?.setEventHandler(handler: { [weak self] in
                    if !(self?.stopLoop ?? true) {
                        //信号量减1
                        let ret:DispatchTimeoutResult = self?.semaphore?.wait(wallTimeout: DispatchWallTime.distantFuture) ?? DispatchTimeoutResult.timedOut
                        /**
                         //任务列表为空时，关闭定时器
                         //获取任务失败时，恢复信号量
                         
                         //等不到事件信号时关闭定时器
                         //获取任务失败，恢复信号量
                         */
                        if ret == .success {
                            let workItem = self?.workItemQueue.top()
                            if let item = workItem {
                                self?.serialQueue.async(execute: item)
                            } else {
                                self?.semaphore?.signal()
                                self?.cancelLoop()
                            }
                        } else {
                            self?.semaphore?.signal()
                            self?.cancelLoop()
                        }
                    }
                })
                self?.pollingTimer?.schedule(wallDeadline: DispatchWallTime.now(), repeating: TimeInterval.init(0.05) * Double(NSEC_PER_SEC))
                self?.pollingTimer?.resume()
            }
        }
    }
    
    private func cancelLoop() {
        innerQueue.async { [weak self] in
            if self != nil {
                self?.stopLoop = true
                if self?.pollingTimer != nil {
                    self?.pollingTimer?.cancel()
                    self?.pollingTimer = nil
                }
            }
        }
    }

}
