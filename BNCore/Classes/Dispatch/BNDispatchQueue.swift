//
//  BNDispatchQueue.swift
//  BNCore
//
//  Created by gary on 2020/4/26.
//

import Foundation

enum BNDispatchQueueType {
    case Serial
    case Concurrent
}

/**
    轻量级任务队列，任务加入队列后会自动执行
 
    用法：
    -1- let serialQueue = BNDispatchQueue.init()
    -2- serialQueue.schedule(repeating: 2) // 开启任务队列RunLoop，每2秒提取一个任务执行
    -3- serialQueue.push(workItem: xxx) // 添加任务到队列
 */
public class BNDispatchQueue {
    
    //处理内部任务的队列
    private let serialQueue = DispatchQueue.init(label: "com.bngrp.innerSerial.DispatchQueue.\(Date().timeIntervalSince1970)")
    private var workItems = [DispatchWorkItem]()
    private var pollingTimer: DispatchSourceTimer?
    var repeatSeconds:Double = 0.5 //runloop间隔时间
    var maxCount:Int = 100 //最大任务数
    private(set) var running = false
    
    public func push(workItem: DispatchWorkItem) {
        serialQueue.async { [weak self] in
            if self != nil {
                if self!.workItems.count >= self!.maxCount {
                    self!.workItems.remove(at: 0)
                }
                self!.workItems.append(workItem)
            }
            
        }
    }
    
    public func top() -> DispatchWorkItem? {
        var item:DispatchWorkItem?
        objc_sync_enter(self)
        if workItems.count > 0 {
            item = workItems.first
            workItems.remove(at: 0)
        }
        objc_sync_exit(self)
        return item
    }
    
    public func clear() {
        objc_sync_enter(self)
        if workItems.count > 0 {
            workItems.removeAll()
        }
        objc_sync_exit(self)
    }
    
    public func stopRunLoop() {
        pollingTimer?.cancel()
        pollingTimer = nil
        running = false
    }
}

extension BNDispatchQueue {
    
    //启动定时器，按时间间隔开始执行队列里的任务
    public func schedule(wallDeadline: DispatchWallTime = .now(), repeating seconds: Double) {
        pollingTimer = DispatchSource.makeTimerSource(queue: serialQueue)
        pollingTimer!.setEventHandler(handler: { [weak self] in
//            print("---------------- runloop ----------------")
            if self != nil {
                let workItem = self!.top()
                
                if workItem != nil {
                    self!.serialQueue.async(execute: workItem!)
                }
                
//                if self!.workItems.count <= 0 || workItem == nil {
//                    self!.stopRunLoop()
//                }
            }
        })
        pollingTimer?.schedule(wallDeadline: wallDeadline, repeating: seconds)
        pollingTimer?.resume()
        running = true
    }
    
}
