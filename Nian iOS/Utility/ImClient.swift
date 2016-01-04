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
    let s = NSMutableString()
    for (k, v) in params {
        if first {
            // s.appendString("?")
            first = false
        } else {
            s.appendString("&")
        }
        s.appendString(k)
        s.appendString("=")
        s.appendString(CFURLCreateStringByAddingPercentEscapes(nil, v, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String)
    }
    return s as String
}

func httpGet(requestURL: String, params: String) -> AnyObject? {
    let request = NSMutableURLRequest()
    request.URL = NSURL(string: requestURL + (params != "" ? "?" + params : ""))
    request.timeoutInterval = NSTimeInterval(300)
    var response: NSURLResponse?
    var data: NSData?
    do {
        data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
    } catch _ as NSError {
        data = nil
    }
    var json: AnyObject? = nil
    if data != nil {
        json = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
    }
    return json
}

func httpPost(requestURL: String, params: String) -> AnyObject? {
    let request = NSMutableURLRequest()
    request.URL = NSURL(string: requestURL)
    request.HTTPMethod = "POST"
    if params != "" {
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
    }
    var response: NSURLResponse?
    var data: NSData?
    do {
        data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
    } catch _ as NSError {
        data = nil
    }
    var json: AnyObject? = nil
    if data != nil {
        json = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
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
            let t = m_tasks[0]
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
        let t = task(onTask: onTask, onDone: onDone)
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
        case live
    }
    
    private let statusSuccess = 0
    private let statusTimeOut = 1
    private let statusFailed = 2
    private let statusUnauthenticated = 3
    private let statusOldVersion = 4
    
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
        return obj.objectForKey("status") as! Int
    }
    
    private func setState(state: State) {
        if m_state != state {
            m_state = state
            let callback = m_onState
            if callback != nil {
                back {
                    callback!(state)
                }
            }
        }
    }
    
    /*
    prev_nil
    0:  初始
    1:  成功
    2:  心跳
    */
    private var prev_nil = 0
    
    private func polling() {
        while m_polling {
            if m_state == .unconnect {
                enter(m_uid, shell: m_shell)
            } else if m_state == .authed {
                var r: AnyObject? = nil
                if prev_nil == 0 {
                    r  = httpGet(m_landServer + "poll", params: "")
                    if r != nil {
                        //                        m_onState?(.live)
                        r = httpGet(m_landServer + "poll", params: httpParams(["uid": m_uid, "sid": m_sid]))
                    }
                } else if prev_nil == 2 {
                    r  = httpGet(m_landServer + "poll", params: "")
                    if r != nil {
                        m_onState?(.live)
                        r = httpGet(m_landServer + "poll", params: httpParams(["uid": m_uid, "sid": m_sid]))
                    }
                }else {
                    r = httpGet(m_landServer + "poll", params: httpParams(["uid": m_uid, "sid": m_sid]))
                }
                if r != nil {
                    prev_nil = 1
                    m_repollDelay = 0.5
                    let status = peekStatus(r!)
                    switch status {
                    case statusSuccess:
                        m_onPull?(r)
                        break
                    case statusUnauthenticated:
                        setState(.unconnect)
                        break
                    default:
                        break
                    }
                } else {
                    prev_nil = 2
                    if m_repollDelay >= 60 {
                        setState(.unconnect)
                    }
                    m_repollDelay = m_repollDelay + 0.5
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
            httpPost(m_landServer + "leave", params: httpParams(["uid": m_uid, "sid": m_sid]))
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
        let json: AnyObject? = httpPost(m_loginServer + "enter", params: httpParams(["uid": uid, "shell": shell, "ver": "1000"]))
        if json != nil {
            let status = peekStatus(json!)
            if status == statusSuccess {
                m_uid = uid
                m_shell = shell
                m_sid = json!.objectForKey("sid") as! String
                setState(.authed)
                return 0
            }
        }
        setState(.unconnect)
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
        _ = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        
        let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        //        var safeuid = Sa.objectForKey("uid") as! String
        let safename = Sa.objectForKey("user") as! String
        
        let json: AnyObject? = httpPost(m_landServer  + "gmsg", params: httpParams(["uid": m_uid, "sid": m_sid, "to": "\(gid)", "type": "\(msgtype)", "msg": msg, "uname": safename, "cid": "\(cid)", "msgid": "1"]))
        
        return json
    }
    
    func sendMessage(gid: Int, msgtype: Int, msg: String, cid: Int) -> AnyObject? {
        
        let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        //        var safeuid = Sa.objectForKey("uid") as! String
        let safename = Sa.objectForKey("user") as! String
        let json: AnyObject? = httpPost(m_landServer  + "msg", params: httpParams(["uid": m_uid, "sid": m_sid, "to": "\(gid)", "type": "\(msgtype)", "msg": msg, "uname": safename, "msgid": "1"]))
        return json
        // gmsg 变成 msg，cid 删除掉
    }
    
    func getSid() -> String {
        return m_sid
    }
}
