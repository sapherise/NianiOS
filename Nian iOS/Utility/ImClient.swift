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
    
    enum State {
        case unconnect
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
    
    private var m_onPull: (AnyObject? -> Void)? = nil
    private var m_onState: (State -> Void)? = nil
    
    private var m_lock = NSLock()
    private var m_state: State = .unconnect
    private var m_polling = false
    private var m_repollDelay: NSTimeInterval = 0.5
    
    private var m_uid: String = ""
    private var m_shell: String = ""
    private var m_sid: String = ""
    
    private func casState(old: State, to: State) -> Bool {
        var r = false
        m_lock.lock()
        if m_state == old {
            setState(to)
            r = true
        }
        m_lock.unlock()
        return r
    }
    
    private func peekStatus(obj: AnyObject) -> Int {
        return obj["status"] as Int
    }
    
    private func setState(state: State) {
        if m_state != state {
            m_state = state
            var callback = m_onState
            if callback != nil {
                back {
                    callback!(state)
                }
            }
        }
    }
    
    private func polling() {
        while m_polling {
            // 如果客户端处于无连接状态
            if m_state == .unconnect {
                // 尝试重新登录
                var r = enter(m_uid, shell: m_shell)
                if r == 1 {
                    // 登录失败, poll结束
                    m_onPull!(nil)
                    break
                }
            } else if m_state == .authed {
                // 客户端已经登录, 开始拉取消息
                var r: AnyObject? = httpGet(m_landServer + "poll", httpParams(["uid": m_uid, "sid": m_sid]))
                // 数据拉取失败
                if r != nil {
                    m_repollDelay = 0.5
                    var status = peekStatus(r!)
                    switch status {
                    case statusSuccess:
                        m_onPull!(r)
                        break
                    case statusUnauthenticated:
                        // 服务端要求重新登录
                        setState(.unconnect)
                        break
                    default:
                        break
                    }
                } else {
                    if m_repollDelay >= 60 {
                        setState(.unconnect)
                    }
                    // 扩大延时
                    m_repollDelay = m_repollDelay + m_repollDelay
                }
            }
            NSThread.sleepForTimeInterval(m_repollDelay)
        }
        m_polling = false
    }
    
    func setOnState(handler: State -> Void) {
        m_onState = handler
    }
    
    func leave() {
        if casState(.authed, to: .authing)  {
            httpPost(m_landServer + "leave", httpParams(["uid": m_uid, "sid": m_sid]))
            pollEnd()
            m_sid = ""
            setState(.unconnect)
        }
    }
    
    func enter(uid: String, shell: String) -> Int {
        // 仅unconnect状态下可以连接
        leave()
        if !casState(.unconnect, to: .authing) {
            return 2
        }
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
        m_state = .unconnect
        return 1
    }
    
    func pollBegin(handler: AnyObject? -> Void) {
        if m_polling || m_sid == "" {
            return
        }
        m_polling = true
        m_onPull = handler
        go {
            self.polling()
        }
    }
    
    func pollEnd() {
        m_polling = false
    }
    
    func sendGroupMessage(gid: Int, msgtype: Int, msg: String, cid: Int) -> AnyObject? {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safename = Sa.objectForKey("user") as String
        var json: AnyObject? = httpPost(m_landServer  + "gmsg", httpParams(["uid": m_uid, "sid": m_sid, "to": "\(gid)", "type": "\(msgtype)", "msg": msg, "uname": safename, "cid": "\(cid)"]))
        return json
    }
}
