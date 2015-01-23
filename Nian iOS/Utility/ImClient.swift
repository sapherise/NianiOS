//
//  ImClient.swift
//  test
//
//  Created by vizee on 14/12/22.
//  Copyright (c) 2014年 nian. All rights reserved.
//

import Foundation

func go(justdoit: () -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), justdoit)
}

func back(justdoit: () -> Void) {
    dispatch_async(dispatch_get_main_queue(), justdoit)
}

func httpParams(params: [String: String]) -> String {
    var first = true
    let legalURLCharactersToBeEscaped: CFStringRef = "=\"#%/<>?@\\^`{|}&+"
    var s = NSMutableString()
    for (k, v) in params {
        if first {
            // s.appendString("?")
            first = false
        } else {
            s.appendString("&")
        }
        s.appendString(k)
        s.appendString("=")
        s.appendString(CFURLCreateStringByAddingPercentEscapes(nil, v, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue))
    }
    return s
}

func httpGet(requestURL: String, params: String) -> AnyObject? {
    var url = NSURL(string: requestURL + (params != "" ? "?" + params : ""))
    var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
    var json: AnyObject? = nil
    if data != nil {
        json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
    }
    return json
}

func httpPost(requestURL: String, params: String) -> AnyObject? {
    var request = NSMutableURLRequest()
    request.URL = NSURL(string: requestURL)
    request.HTTPMethod = "POST"
    if params != "" {
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
    }
    var response: NSURLResponse?
    var error: NSError?
    var data = NSURLConnection.sendSynchronousRequest(request, returningResponse : &response, error: &error)
    var json: AnyObject? = nil
    if data != nil {
        json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
    }
    return json
}

class taskQueue {
    
    private class task {
        
        private var m_task: () -> Void
        private var m_done: () -> Void
        
        init(onTask: () -> Void, onDone: () -> Void) {
            m_task = onTask
            m_done = onDone
        }
    }
    
    private var m_state = 0
    private var m_tasks = [task]()
    
    private func doneTask(t: task) {
        assert(NSThread.currentThread().isMainThread, "bad thread")
        t.m_done()
        assert(t === m_tasks[0], "bad task")
        m_tasks.removeAtIndex(0)
        if m_tasks.count > 0 {
            runTask()
        } else {
            m_state = 0
        }
    }
    
    private func runTask() {
        assert(NSThread.currentThread().isMainThread, "bad thread")
        if m_tasks.count > 0 {
            var t = m_tasks[0]
            go {
                t.m_task()
                back {
                    self.doneTask(t)
                }
            }
        }
    }
    
    private func addTask(t: task) {
        assert(NSThread.currentThread().isMainThread, "bad thread")
        m_tasks.append(t)
        if m_state == 0 {
            m_state = 1
            runTask()
        }
    }
    
    func exec(onTask: () -> Void, onDone: () -> Void) {
        var t = task(onTask: onTask, onDone: onDone)
        if !NSThread.currentThread().isMainThread {
            back {
                // 主线程同步大法好
                // 天灭线程死锁, 退lock保平安
                // 人在做天在看, 资源竞争留祸患
                self.addTask(t)
            }
        } else {
            self.addTask(t)
        }
    }
}

class ImClient {
    
    private enum states {
        case unauth
        case authing
        case authed
    }
    
    private let statusSuccess = 0
    private let statusTimeOut = 1
    private let statusFailed = 2
    private let statusUnauthenticated = 3
    private let statusBadUser = 4
    
    private let m_loginServer: String = "http://121.41.78.240:6426/"
    private let m_landServer: String = "http://121.41.78.240:6426/"
    
    private var m_queue = taskQueue()
    
    private var m_pollHandler: (AnyObject? -> Void)? = nil
    
    private var m_state: states = .unauth
    private var m_polling = false
    
    private var m_uid: String = ""
    private var m_shell: String = ""
    private var m_sid: String = ""
    
    private func peekStatus(obj: AnyObject) -> Int {
        return obj["status"] as Int
    }
    
    private func polling() {
        while m_polling {
            if m_state == .unauth {
                // 客户端重新登录
                var r = enter(m_uid, shell: m_shell)
                if r == 1 {
                    m_pollHandler!(nil)
                    break
                }
            } else if m_state == .authed {
                // 客户端已经登录, 开始拉取消息
                var r: AnyObject? = httpGet(m_landServer + "poll", httpParams(["uid": m_uid, "sid": m_sid]))
                if r == nil {
                    break
                }
                var status = peekStatus(r!)
                switch status {
                case statusSuccess:
                    m_pollHandler!(r)
                case statusUnauthenticated:
                    // 服务端要求重新登录
                    m_state = .unauth
                case statusTimeOut:
                    // 服务端超时重新拉取
                    continue
                default:
                    NSThread.sleepForTimeInterval(500)
                    break
                }
            } else {
                // 客户端登录中
                NSThread.sleepForTimeInterval(500)
            }
        }
        m_polling = false
    }
    
    func leave() {
        if m_state == .authed {
            m_state = .authing
            pollEnd()
            httpPost(m_landServer + "leave", httpParams(["uid": m_uid, "sid": m_sid]))
            m_sid = ""
            m_state = .unauth
        }
    }
    
    func enter(uid: String, shell: String) -> Int {
        if m_state == .authing {
            return 2
        }
        leave()
        m_state = .authing
        var json: AnyObject? = httpPost(m_loginServer + "enter", httpParams(["uid": uid, "shell": shell]))
        if json != nil {
            var status = peekStatus(json!)
            if status == statusSuccess {
                m_uid = uid
                m_shell = shell
                m_sid = json!["sid"] as String
                m_state = .authed
                return 0
            }
        }
        m_state = .unauth
        return 1
    }
    
    func pollBegin(handler: AnyObject? -> Void) {
        if m_polling || m_sid == "" {
            return
        }
        m_polling = true
        m_pollHandler = handler
        go {
            self.polling()
        }
    }
    
    func pollEnd() {
        m_polling = false
    }
    
    func sendGroupMessage(gid: Int, msgtype: Int, msg: String) -> AnyObject? {
        var json: AnyObject? = httpPost(m_landServer  + "gmsg", httpParams(["uid": m_uid, "sid": m_sid, "to": "\(gid)", "type": "\(msgtype)", "msg": msg]))
        return json
    }
}
