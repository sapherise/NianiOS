//
//  Nian.swift
//  Nian iOS
//
//  Created by vizee on 14/11/7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//i

import UIKit

struct Api {
    
    private static var s_load = false
    private static var s_uid: String!
    private static var s_shell: String!
    
    private static func loadCookies() {
        if (!s_load) {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            s_uid = Sa.objectForKey("uid") as String
            s_shell = Sa.objectForKey("shell") as String
            s_load = true
        }
    }
    
    static func requestLoad() {
        s_load = false
    }
    
    static func getCookie() -> (String, String) {
        loadCookies()
        return (s_uid, s_shell)
    }
    
    static func getUserMe(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user.php?uid=\(s_uid)&myuid=\(s_uid)", callback: callback)
    }
    
    static func getCoinDetial(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/coindes.php?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func getExploreFollow(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_fo.php?page=\(page)&uid=\(s_uid)", callback: callback)
    }
    
    static func getExploreDynamic(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_like.php?page=\(page)&uid=\(s_uid)", callback: callback)
    }
    
    static func getExploreHot(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_hot.php", callback: callback)
    }
    
    static func getExploreNew(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_all.php?page=\(page)", callback: callback)
    }
    
    static func postReport(type: String, id: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/a.php", content: "uid=\(s_uid)&&shell\(s_shell)", callback: callback)
    }
    
    static func getFriendFromWeibo(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/weibo.php?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func getFriendFromTag(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/friend_tag.php?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func postLikeStep(sid: String, like: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/like_query.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&step=\(sid)&&like=\(like)", callback)
    }
    
    static func postFollow(uid: String, follow: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/fo.php", content: "uid=\(uid)&&myuid=\(s_uid)&&shell=\(s_shell)&&fo=\(follow)", callback: callback)
    }
    
    static func getLevelCalendar(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/calendar.php?uid=\(s_uid)", callback: callback)
    }
    
    static func getUserTop(uid:Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user.php?uid=\(uid)&myuid=\(s_uid)", callback: callback)
    }
    
    static func getDreamNewest(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/addstep_dream.php?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func postIapReceipt(data: NSData, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/iap_verify.php", content: "uid=\(s_uid)&shell=\(s_shell)&receipt_data=\(data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros))", callback: callback)
    }
}
