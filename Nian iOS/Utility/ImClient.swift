////
////  ImClient.swift
////  test
////
////  Created by vizee on 14/12/22.
////  Copyright (c) 2014年 nian. All rights reserved.
////
//
//import Foundation
//
//// 后台进行
//func go(justdoit: () -> Void) {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), justdoit)
//}
//
//// 主线程返回
//func back(justdoit: () -> Void) {
//    dispatch_async(dispatch_get_main_queue(), justdoit)
//}
//
//// 给发送的句子加改变
//func httpParams(params: [String: String]) -> String {
//    var first = true
//    let legalURLCharactersToBeEscaped: CFStringRef = "=\"#%/<>?@\\^`{|}&"
//    var s = NSMutableString()
//    for (k, v) in params {
//        if first {
//            // s.appendString("?")
//            first = false
//        } else {
//            s.appendString("&")
//        }
//        s.appendString(k)
//        s.appendString("=")
//        s.appendString(CFURLCreateStringByAddingPercentEscapes(nil, v, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue))
//    }
//    return s
//}
//
//// 发送值，返回一个 json
//func httpGet(requestURL: String, params: String) -> AnyObject? {
//    var url = NSURL(string: requestURL + (params != "" ? "?" + params : ""))
//    var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
//    var json: AnyObject? = nil
//    if data != nil {
//        json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
//    }
//    return json
//}
//
//// 发送值，返回一个 json
//func httpPost(requestURL: String, params: String) -> AnyObject? {
//    var request = NSMutableURLRequest()
//    request.URL = NSURL(string: requestURL)
//    request.HTTPMethod = "POST"
//    if params != "" {
//        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
//    }
//    var response: NSURLResponse?
//    var error: NSError?
//    var data = NSURLConnection.sendSynchronousRequest(request, returningResponse : &response, error: &error)
//    var json: AnyObject? = nil
//    if data != nil {
//        json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
//    }
//    return json
//}
//
//// 异步任务队列, 不支持取消操作
//class taskQueue {
//    
//    private class task {
//        
//        private var m_task: () -> Void
//        private var m_done: () -> Void
//        
//        init(onTask: () -> Void, onDone: () -> Void) {
//            m_task = onTask
//            m_done = onDone
//        }
//    }
//    
//    private var m_state = 0
//    private var m_tasks = [task]()
//    
//    private func doneTask(t: task) {
//        assert(NSThread.currentThread().isMainThread, "bad thread")
//        t.m_done()
//        assert(t === m_tasks[0], "bad task")
//        m_tasks.removeAtIndex(0)
//        if m_tasks.count > 0 {
//            runTask()
//        } else {
//            m_state = 0
//        }
//    }
//    
//    private func runTask() {
//        assert(NSThread.currentThread().isMainThread, "bad thread")
//        if m_tasks.count > 0 {
//            var t = m_tasks[0]
//            go {
//                t.m_task()
//                back {
//                    self.doneTask(t)
//                }
//            }
//        }
//    }
//    
//    private func addTask(t: task) {
//        assert(NSThread.currentThread().isMainThread, "bad thread")
//        m_tasks.append(t)
//        if m_state == 0 {
//            m_state = 1
//            runTask()
//        }
//    }
//    
//    func exec(onTask: () -> Void, onDone: () -> Void) {
//        var t = task(onTask: onTask, onDone: onDone)
//        if !NSThread.currentThread().isMainThread {
//            back {
//                // 主线程同步大法好
//                // 天灭线程死锁, 退lock保平安
//                // 人在做天在看, 资源竞争留祸患
//                self.addTask(t)
//            }
//        } else {
//            self.addTask(t)
//        }
//    }
//}
//
//class ImClient {
//    
//    private let statusSuccess = 0
//    private let statusTimeOut = 1
//    private let statusFailed = 2
//    private let statusSessionClosed = 3
//    
//    private let m_loginServer: String = "http://192.168.0.108:6426/"
//    private let m_landServer: String = "http://192.168.0.108:6426/"
//    
//    private var m_queue = taskQueue()
//    
//    private var m_entering = false
//    private var m_polling = false
//    private var m_pollHandler: (AnyObject? -> Void)? = nil
//    
//    private var m_uid: String = ""
//    private var m_shell: String = ""
//    private var m_sid: String = ""
//    
//    private func peekStatus(obj: AnyObject) -> Int {
//        return obj["status"] as Int
//    }
//    
//    private func polling() {
//        var badsid = false
//        while m_polling {
//            if badsid {
//                var r = enter(m_uid, shell: m_shell)
//                if r == 1 {
//                    m_pollHandler!(nil)
//                    break
//                } else if r == 2 {
//                    NSThread.sleepForTimeInterval(500)
//                }
//            } else {
//                // 开始拉取
//                var r: AnyObject? = httpGet(m_landServer + "poll", httpParams(["uid": m_uid, "sid": m_sid]))
//                if r == nil {
//                    break
//                }
//                var status = peekStatus(r!)
//                switch status {
//                case statusSuccess:
//                    m_pollHandler!(r)
//                case statusSessionClosed:
//                    badsid = true
//                case statusTimeOut:
//                    continue
//                default:
//                    NSThread.sleepForTimeInterval(500)
//                    break
//                }
//            }
//        }
//        m_polling = false
//    }
//    
//    func enter(uid: String, shell: String) -> Int {
//        // 已经进入了
//        if m_entering {
//            return 2
//        }
//        // 还未进入
//        m_entering = true
//        // 发送进入的参数
//        var json: AnyObject? = httpPost(m_loginServer + "enter", httpParams(["uid": uid, "shell": shell]))
//        if json != nil {
//            var status = peekStatus(json!)
//            if status == statusSuccess {
//                m_uid = uid
//                m_shell = shell
//                // 返回了进入的 sid
//                m_sid = json!["sid"] as String
//                m_entering = false
//                return 0
//            }
//        }
//        // 加入失败
//        m_entering = false
//        return 1
//    }
//    
//    func pollBegin(handler: AnyObject? -> Void) {
//        // 如果没有进程，退出
//        if m_polling || m_sid == "" {
//            return
//        }
//        // 有进程，开始拉取
//        m_polling = true
//        m_pollHandler = handler
//        go {
//            self.polling()
//        }
//    }
//    
//    func pollEnd() {
//        m_polling = false
//    }
//    
//    func sendGroupMessage(gid: Int, msgtype: Int, msg: String) -> AnyObject? {
//        var json: AnyObject? = httpPost(m_landServer  + "gmsg", httpParams(["uid": m_uid, "sid": m_sid, "to": "\(gid)", "type": "\(msgtype)", "msg": msg]))
//        return json
//    }
//}
